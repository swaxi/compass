import QtQuick
import QtQuick.Controls
import QtSensors
import org.qfield

Item {
    id: root
    
    // =========================================================================
    // QFIELD INTERFACE
    // =========================================================================
    
    property var mainWindow: iface.mainWindow()
    property var overlayFeatureFormDrawer: iface.findItemByObjectName('overlayFeatureFormDrawer')
    
    // =========================================================================
    // SENSORS
    // =========================================================================
    
    Compass {
        id: compass
        active: true
        dataRate: 10
        
        property real currentAzimuth: 0
        
        onReadingChanged: {
            if (reading) {
                currentAzimuth = reading.azimuth
            }
        }
    }
    
    Accelerometer {
        id: accelerometer
        active: true
        dataRate: 10
        
        property real currentPitch: 0
        property real currentRoll: 0
        
        onReadingChanged: {
            if (reading) {
                var x = reading.x
                var y = reading.y
                var z = reading.z
                
                currentRoll = Math.atan2(y, Math.sqrt(x * x + z * z)) * 180 / Math.PI
                currentPitch = Math.atan2(-x, Math.sqrt(y * y + z * z)) * 180 / Math.PI
            }
        }
    }
    
    // =========================================================================
    // STATE
    // =========================================================================
    
    property bool autoFillEnabled: true
    property bool formWasVisible: false
    property bool hasAttemptedPopulate: false
    
    // =========================================================================
    // GEOLOGICAL CALCULATIONS
    // =========================================================================
    
    function calculateGeologicalDip(azimuth, pitch, roll) {
        var azRad = azimuth * Math.PI / 180
        var pitchRad = pitch * Math.PI / 180
        var rollRad = roll * Math.PI / 180
        
        var nx = Math.sin(pitchRad)
        var ny = -Math.sin(rollRad) * Math.cos(pitchRad)
        var nz = Math.cos(rollRad) * Math.cos(pitchRad)
        
        var dip = Math.acos(Math.abs(nz)) * 180 / Math.PI
        
        var dipDirection = azimuth
        if (nz > 0) {
            dipDirection = (azimuth + 180) % 360
        }
        
        var strike = (dipDirection + 90) % 360
        
        return {
            dip: Math.abs(dip),
            dipDirection: dipDirection,
            strike: strike
        }
    }
    
    function getOrientationData() {
        var azimuth = compass.currentAzimuth
        var pitch = accelerometer.currentPitch
        var roll = accelerometer.currentRoll
        
        var geo = calculateGeologicalDip(azimuth, pitch, roll)
        
        return {
            azimuth: azimuth,
            pitch: pitch,
            roll: roll,
            dip: geo.dip,
            dipDirection: geo.dipDirection,
            strike: geo.strike
        }
    }
    
    // =========================================================================
    // AUTO-FILL FUNCTION
    // =========================================================================
    
    function tryAutoFill(orientation) {
        try {
            if (!overlayFeatureFormDrawer || !overlayFeatureFormDrawer.visible) {
                return false
            }
            
            if (!overlayFeatureFormDrawer.featureModel) {
                return false
            }
            
            var feature = overlayFeatureFormDrawer.featureModel.feature
            if (!feature) {
                return false
            }
            
            var fieldNames = feature.fields.names
            var populated = false
            
            for (var i = 0; i < fieldNames.length; i++) {
                var fieldName = fieldNames[i].toLowerCase()
                
                if (fieldName === 'azimuth' || fieldName === 'compass' || fieldName === 'heading') {
                    feature.setAttribute(i, Math.round(orientation.azimuth))
                    populated = true
                }
                else if (fieldName === 'pitch' || fieldName === 'plunge') {
                    feature.setAttribute(i, Math.round(orientation.pitch))
                    populated = true
                }
                else if (fieldName === 'roll') {
                    feature.setAttribute(i, Math.round(orientation.roll))
                    populated = true
                }
                else if (fieldName === 'dip' || fieldName === 'dip_angle') {
                    feature.setAttribute(i, Math.round(orientation.dip))
                    populated = true
                }
                else if (fieldName === 'dip_dir' || fieldName === 'dipdirection' || fieldName === 'dip_dir') {
                    feature.setAttribute(i, Math.round(orientation.dipDirection))
                    populated = true
                }
                else if (fieldName === 'strike_rhr') {
                    feature.setAttribute(i, Math.round(orientation.strike))
                    populated = true
                }
            }
            
            if (populated) {
                overlayFeatureFormDrawer.featureModel.feature = feature
                return true
            }
            
            return false
            
        } catch (e) {
            console.log("Auto-fill error:", e)
            return false
        }
    }
    
    // =========================================================================
    // AUTO-FILL ON FORM OPEN
    // =========================================================================
    
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
    
    // =========================================================================
    // SINGLE BUTTON WITH LIVE DISPLAY
    // =========================================================================
    
    Component {
        id: mainButtonComponent
        
        Button {
            width: 100
            height: 110
            
            background: Rectangle {
                color: parent.pressed ? "#C62828" : (autoFillEnabled ? "#F44336" : "#9E9E9E")
                radius: 12
                border.color: autoFillEnabled ? "#B71C1C" : "#757575"
                border.width: 3
                
                // Auto indicator
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 4
                    width: 24
                    height: 24
                    radius: 12
                    color: autoFillEnabled ? "#4CAF50" : "#757575"
                    border.color: "white"
                    border.width: 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: autoFillEnabled ? "A" : "M"
                        font.pixelSize: 12
                        font.bold: true
                        color: "white"
                    }
                }
            }
            
            contentItem: Column {
                anchors.centerIn: parent
                spacing: 4
                
                // Icon
                Text {
                    text: "📍"
                    font.pixelSize: 28
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                // Live values
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
                            return "Plunge:" + Math.round(data.pitch) + "°"
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
                            return "Dip_Dir:" + Math.round(data.dipDirection) + "°"
                        }
                        font.pixelSize: 10
                        font.bold: true
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            // Short press = manual capture
            onClicked: {
                var orientation = getOrientationData()
                var success = false
                
                if (overlayFeatureFormDrawer && overlayFeatureFormDrawer.visible) {
                    success = tryAutoFill(orientation)
                }
                
                if (success) {
                    mainWindow.displayToast("✓ Filled!\n\nDip:" + Math.round(orientation.dip) + "° → " + Math.round(orientation.dipDirection) + "°")
                } else {
                    mainWindow.displayToast("ℹ️ Current values:\n\n" +
                                          "Azimuth: " + Math.round(orientation.azimuth) + "°\n" +
                                          "Plunge: " + Math.round(orientation.pitch) + "°\n" +
                                          "Dip: " + Math.round(orientation.dip) + "°\n" +
                                          "Dip Dir: " + Math.round(orientation.dipDirection) + "°\n" +
                                          "Strike: " + Math.round(orientation.strike) + "°")
                }
            }
            
            // Long press = toggle auto
            onPressAndHold: {
                autoFillEnabled = !autoFillEnabled
                var msg = autoFillEnabled ? 
                         "✓ AUTO-FILL ON\n\nWill auto-fill when form opens" :
                         "⏸ AUTO-FILL OFF\n\nClick button to fill manually"
                mainWindow.displayToast(msg)
            }
        }
    }
    
    // Keep sensors updating for live display
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            // Forces button to update display
        }
    }
    
    // =========================================================================
    // INIT
    // =========================================================================
    
    Component.onCompleted: {
        console.log("=== SIMPLIFIED GEOLOGY VERSION ===")
        
        Qt.callLater(function() {
            try {
                overlayFeatureFormDrawer = iface.findItemByObjectName('overlayFeatureFormDrawer')
                
                var mainBtn = mainButtonComponent.createObject(root)
                if (mainBtn) {
                    iface.addItemToPluginsToolbar(mainBtn)
                }
                
                mainWindow.displayToast("✓ Geology Plugin Ready!\n\n" +
                                      "📍 Shows live values\n" +
                                      "Click = Fill form\n" +
                                      "Hold = Toggle auto\n\n" +
                                      "Auto-fill: ON (green A)")
                
                console.log("=== READY ===")
                
            } catch (e) {
                console.log("ERROR:", e)
            }
        })
    }
}
