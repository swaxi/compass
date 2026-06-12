import QtQuick
import QtQuick.Controls
import QtSensors
import org.qfield
import QtCore

Item {
    id: root
    
    // Field name mappings — add your own layer field names to any list
    property var azimuthFieldNames:      ["azimuth", "azimut", "heading"]
    property var rollFieldNames:         ["roll"]
    property var pitchFieldNames:        ["pitch"]
    property var dipFieldNames:          ["dip", "dip_angle", "pendage", "dip_ref"]
    property var dipDirectionFieldNames: ["dip_direction", "dipdirection", "dip_dir", "dipdir_ref"]
    property var strikeFieldNames:       ["strike_rhr", "strike", "strike_ref"]
    property var plungeFieldNames:       ["plunge", "plongement"]
    property var skipFieldNames:         ["fid", "id", "objectid"]

    property var mainWindow: iface.mainWindow()
    property var overlayFeatureFormDrawer: iface.findItemByObjectName('overlayFeatureFormDrawer')

    // Persistent settings — edited via the ⚙ button in QField's plugin manager
    Settings {
        id: pluginSettings
        category: "CompassPlugin"
        property real magneticDeclination: -1.5
        property bool southernHemisphere: true
    }

    function configure() {
        configDialog.open()
    }

    Dialog {
        id: configDialog
        parent: iface.mainWindow().contentItem
        anchors.centerIn: parent
        visible: false
        modal: true
        title: "Compass Plugin Settings"
        standardButtons: Dialog.Ok | Dialog.Cancel

        Column {
            spacing: 16
            width: 300
            topPadding: 8

            Column {
                width: parent.width
                spacing: 4
                Text {
                    text: "Magnetic Declination (°)"
                    font.pixelSize: 14
                }
                TextField {
                    id: declinationField
                    width: parent.width
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    placeholderText: "e.g. -1.5"
                }
            }

            Row {
                spacing: 12
                Text {
                    text: "Southern Hemisphere"
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }
                Switch {
                    id: hemisphereSwitch
                }
            }
        }

        onOpened: {
            declinationField.text = pluginSettings.magneticDeclination.toString()
            hemisphereSwitch.checked = pluginSettings.southernHemisphere
        }

        onAccepted: {
            var dec = parseFloat(declinationField.text)
            if (!isNaN(dec)) pluginSettings.magneticDeclination = dec
            pluginSettings.southernHemisphere = hemisphereSwitch.checked
        }
    }
    
    Compass {
        id: compass
        active: true
        dataRate: 10
        property real currentAzimuth: 0
        onReadingChanged: {
            if (reading) currentAzimuth = reading.azimuth
        }
    }
    
    Accelerometer {
        id: accelerometer
        active: true
        dataRate: 10
        property real currentPitch: 0
        property real currentRoll: 0
        property real currentX: 0
        property real currentY: 0
        property real currentZ: 0
        
        onReadingChanged: {
            if (reading) {
                currentX = reading.x
                currentY = reading.y
                currentZ = reading.z
                currentRoll = Math.atan2(reading.y, Math.sqrt(reading.x * reading.x + reading.z * reading.z)) * 180 / Math.PI
                currentPitch = Math.atan2(-reading.x, Math.sqrt(reading.y * reading.y + reading.z * reading.z)) * 180 / Math.PI
            }
        }
    }
    
    property bool autoFillEnabled: true
    property bool formWasVisible: false
    property bool hasAttemptedPopulate: false
    
    function calculateGeologicalDip(azimuth) {
        // DIRECT METHOD: Use gravity vector and transform by compass only
        // Gravity in phone frame
        var gx = accelerometer.currentX
        var gy = accelerometer.currentY
        var gz = accelerometer.currentZ
        
        var g_mag = Math.sqrt(gx*gx + gy*gy + gz*gz)
        if (g_mag < 1.0) {
            return { dip: 0, dipDirection: 0, strike: 0 }
        }
        
        // Normalize
        gx /= g_mag
        gy /= g_mag
        gz /= g_mag
        
        // Dip angle from vertical
        var dip = Math.acos(Math.abs(gz)) * 180 / Math.PI
        
        // Transform gravity horizontal component to world coordinates
        // Phone frame: +X=right, +Y=top, +Z=out of screen
        // Compass tells us where +Y points
        var azRad = azimuth * Math.PI / 180
        
        // The downslope direction in phone frame is toward (gx, gy)
        // But +Y points toward azimuth, and +X points 90° right of that
        
        // World frame transformation:
        // If phone Y-axis points toward azimuth, then:
        // North component = gy * cos(az) + gx * cos(az + 90°)
        //                 = gy * cos(az) - gx * sin(az)
        // East component  = gy * sin(az) + gx * cos(az + 90°) 
        //                 = gy * sin(az) + gx * cos(az)
        
        var g_north = gy * Math.cos(azRad) - gx * Math.sin(azRad)
        var g_east = gy * Math.sin(azRad) + gx * Math.cos(azRad)
        
        // Dip direction is where gravity's horizontal projection points
        var dipDirection = Math.atan2(g_east, g_north) * 180 / Math.PI

        dipDirection = dipDirection + pluginSettings.magneticDeclination
        if (pluginSettings.southernHemisphere) dipDirection=(dipDirection+180)%360
        if (dipDirection < 0) dipDirection += 360


        var strike = dipDirection - 90
        if (strike < 0) strike += 360
        
        return { dip: dip, dipDirection: dipDirection, strike: strike }
    }
    
    function getPlunge() {
        // Plunge = tilt of phone's long axis (Y-axis, top-to-bottom)
        // This is the component of gravity along the Y-axis
        var gx = accelerometer.currentX
        var gy = accelerometer.currentY
        var gz = accelerometer.currentZ
        
        var g_mag = Math.sqrt(gx*gx + gy*gy + gz*gz)
        if (g_mag < 1.0) return 0
        
        // Normalize
        gy = gy / g_mag
        gz = gz / g_mag
        
        // Plunge is angle from horizontal along Y-axis
        // When gy is large (gravity toward top/bottom), plunge is large
        // When gz is large (gravity perpendicular to screen), plunge is small
        var plunge = Math.asin(Math.abs(gy)) * 180 / Math.PI
        
        return plunge
    }
    
    function getOrientationData() {
        var azimuth = compass.currentAzimuth
        var pitch = accelerometer.currentPitch
        var roll = accelerometer.currentRoll
        var plunge = getPlunge()
        var geo = calculateGeologicalDip(azimuth)
        var geoPitch = (270+Math.atan2(accelerometer.currentX,accelerometer.currentY)*180/Math.PI)%180

        if (pluginSettings.southernHemisphere) azimuth=(azimuth+180)%360
        return {
            azimuth: azimuth,
            pitch: pitch,
            roll: roll,
            plunge: plunge,
            dip: geo.dip,
            dipDirection: geo.dipDirection,
            strike: geo.strike,
            geoPitch: geoPitch
        }
    }
    
    function tryAutoFill(orientation) {
        try {
            if (!overlayFeatureFormDrawer || !overlayFeatureFormDrawer.visible) return false
            if (!overlayFeatureFormDrawer.featureModel) return false
            var feature = overlayFeatureFormDrawer.featureModel.feature
            if (!feature) return false
            
            var fieldNames = feature.fields.names
            var populated = false
            
            for (var i = 0; i < fieldNames.length; i++) {
                var fieldName = fieldNames[i].toLowerCase()
                if (skipFieldNames.indexOf(fieldName) !== -1) continue

                if (azimuthFieldNames.indexOf(fieldName) !== -1) {
                    feature.setAttribute(i, Math.round(orientation.azimuth))
                    populated = true
                }
                else if (rollFieldNames.indexOf(fieldName) !== -1) {
                    feature.setAttribute(i, Math.round(orientation.roll))
                    populated = true
                }
                else if (pitchFieldNames.indexOf(fieldName) !== -1) {
                    feature.setAttribute(i, Math.round(orientation.geoPitch))
                    populated = true
                }
                else if (dipFieldNames.indexOf(fieldName) !== -1) {
                    feature.setAttribute(i, Math.round(orientation.dip))
                    populated = true
                }
                else if (dipDirectionFieldNames.indexOf(fieldName) !== -1) {
                    feature.setAttribute(i, Math.round(orientation.dipDirection))
                    populated = true
                }
                else if (strikeFieldNames.indexOf(fieldName) !== -1) {
                    feature.setAttribute(i, Math.round(orientation.strike))
                    populated = true
                }
                else if (plungeFieldNames.indexOf(fieldName) !== -1) {
                    feature.setAttribute(i, Math.round(orientation.plunge))
                    populated = true
                }
            }
            
            if (populated) {
                overlayFeatureFormDrawer.featureModel.feature = feature
                return true
            }
            return false
        } catch (e) {
            return false
        }
    }
    
    Timer {
        id: formMonitor
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            if (!overlayFeatureFormDrawer) {
                overlayFeatureFormDrawer = iface.findItemByObjectName('overlayFeatureFormDrawer')
                return
            }
            var formIsVisible = overlayFeatureFormDrawer.visible
            if (formIsVisible && !formWasVisible && autoFillEnabled) {
                hasAttemptedPopulate = false
                autoFillTimer.start()
            }
            if (!formIsVisible && formWasVisible) {
                hasAttemptedPopulate = false
            }
            formWasVisible = formIsVisible
        }
    }
    
    Timer {
        id: autoFillTimer
        interval: 800
        repeat: false
        onTriggered: {
            if (hasAttemptedPopulate) return
            if (!overlayFeatureFormDrawer || !overlayFeatureFormDrawer.visible) return
            hasAttemptedPopulate = true
            var orientation = getOrientationData()
            var success = tryAutoFill(orientation)
            if (success) {
                mainWindow.displayToast("✓ Auto-filled!")
            }
        }
    }
    
    Component {
        id: settingsButtonComponent
        Button {
            width: 40
            height: 40
            background: Rectangle {
                color: parent.pressed ? "#455A64" : "#607D8B"
                radius: 9
                border.color: "#37474F"
                border.width: 2
            }
            contentItem: Text {
                text: "⚙"
                font.pixelSize: 20
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: configDialog.open()
        }
    }

    Component {
        id: mainButtonComponent
        Button {
            width: 90
            height: 135
            
            background: Rectangle {
                color: parent.pressed ? "#C62828" : (autoFillEnabled ? "#F44336" : "#9E9E9E")
                radius: 9
                border.color: autoFillEnabled ? "#B71C1C" : "#757575"
                border.width: 3
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 4
                    width: 24
                    height: 24
                    radius: 9
                    color: autoFillEnabled ? "#4CAF50" : "#757575"
                    border.color: "white"
                    border.width: 2
                    Text {
                        anchors.centerIn: parent
                        text: autoFillEnabled ? "A" : "M"
                        font.pixelSize: 8
                        font.bold: true
                        color: "white"
                    }
                }
            }
            contentItem: Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: "🧭"
                    font.pixelSize: 28
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 1
                    Text {
                        text: {
                            var data = getOrientationData()
                            return "Az:" + Math.round(data.azimuth) + "°"
                        }
                        font.pixelSize: 10
                        font.bold: true
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: {
                            var data = getOrientationData()
                            return "Strike:" + Math.round(data.azimuth+270)%360 + "°"
                        }
                        font.pixelSize: 10
                        font.bold: true
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: {
                            var data = getOrientationData()
                            return "Pitch:" + Math.round(data.geoPitch) + "°"
                        }
                        font.pixelSize: 10
                        font.bold: true
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }                     
                    Text {
                        text: {
                            var data = getOrientationData()
                            return "Plunge:" + Math.round(data.plunge) + "°"
                        }
                        font.pixelSize: 10
                        font.bold: true
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: {
                            var data = getOrientationData()
                            return "Dip:" + Math.round(data.dip) + "°"
                        }
                        font.pixelSize: 10
                        font.bold: true
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: {
                            var data = getOrientationData()
                            return "Dip Dir:" + Math.round(data.dipDirection) + "°"
                        }
                        font.pixelSize: 10
                        font.bold: true
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            onClicked: {
                var orientation = getOrientationData()
                if (overlayFeatureFormDrawer && overlayFeatureFormDrawer.visible) {
                    tryAutoFill(orientation)
                }
            }
            onPressAndHold: {
                autoFillEnabled = !autoFillEnabled
            }
        }
    }
    
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {}
    }
    
    Component.onCompleted: {
        console.log("=== GRAVITY DIRECT METHOD ===")
        Qt.callLater(function() {
            overlayFeatureFormDrawer = iface.findItemByObjectName('overlayFeatureFormDrawer')
            var mainBtn = mainButtonComponent.createObject(root)
            if (mainBtn) {
                iface.addItemToPluginsToolbar(mainBtn)
            }
            var settingsBtn = settingsButtonComponent.createObject(root)
            if (settingsBtn) {
                iface.addItemToPluginsToolbar(settingsBtn)
            }
            mainWindow.displayToast("✓ Gravity Method")
        })
    }
}
