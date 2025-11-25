# QField Spatial Orientation Capture Plugin

A QField plugin for iPhone (and other mobile devices) that records the spatial orientation of your device when saving data points.

## What It Captures

This plugin captures three key orientation measurements:

1. **Azimuth** - Compass heading in degrees from magnetic north (0-360°)
   - 0° = North
   - 90° = East
   - 180° = South
   - 270° = West

2. **Pitch** - Forward/backward tilt relative to horizontal (-90° to +90°)
   - 0° = Device held horizontally
   - Positive values = Device tilted forward/down
   - Negative values = Device tilted backward/up

3. **Roll** - Left/right tilt relative to horizontal (-90° to +90°)
   - 0° = Device level side-to-side
   - Positive values = Device tilted right
   - Negative values = Device tilted left

## Installation

### For Project-Specific Plugin

1. Name your plugin file to match your project:
   - If your project is `fieldwork.qgs`, name the plugin `fieldwork.qml`

2. Place the plugin file in the same directory as your QGIS project file

3. If using QFieldCloud:
   - Upload the `.qml` file to your cloud project folder
   - The plugin will automatically deploy to devices

### For App-Wide Plugin

1. Copy the plugin directory to your QField plugins folder:
   - iOS: Via iTunes File Sharing or cloud storage
   - Android: `/sdcard/Android/data/ch.opengis.qfield/files/QField/plugins/`

2. Enable the plugin in QField's plugin manager

## QGIS Project Setup

Before using this plugin in the field, set up your vector layer in QGIS:

### Method 1: Separate Fields (Recommended)

Add these fields to your point layer:

```
- azimuth (Decimal/Real, length 10, precision 2)
- pitch (Decimal/Real, length 10, precision 2)
- roll (Decimal/Real, length 10, precision 2)
- orientation_timestamp (Text/String, length 30)
```

### Method 2: JSON Field

Add a single field to store all orientation data:

```
- orientation_data (Text/String, length 500)
```

### Setting Default Values (Optional)

You can set up automatic population using QGIS expressions:

1. Open Layer Properties → Attributes Form
2. For each orientation field, set the default value to:
   - This requires manual paste, but you can set up expressions if integrating with positioning

## Usage in QField

### Basic Workflow

1. Open your project in QField
2. Grant permission to activate the plugin when prompted
3. You'll see two new buttons in the plugins toolbar:
   - 📍 Green button: Capture Orientation
   - ℹ️ Blue button: Show Info/Help

### Capturing Orientation

**Option A: Manual Capture**
1. Position your device at the desired orientation
2. Tap the green "Capture Orientation" button
3. Orientation data is copied to your clipboard as JSON
4. Create/edit a feature
5. Paste the orientation data into the appropriate attribute field(s)

**Option B: During Digitizing**
1. Enter digitizing mode
2. Add your point feature
3. Before saving, tap "Capture Orientation"
4. In the attribute form, paste the captured data
5. Save the feature

## Understanding the Data

### JSON Format

When you capture orientation, the data is formatted as JSON:

```json
{
  "azimuth": 45.23,
  "pitch": 12.50,
  "roll": -3.75,
  "calibration": 0.85,
  "timestamp": "2024-11-24T12:34:56.789Z"
}
```

### Calibration Level

The `calibration` value (0.0 to 1.0) indicates compass accuracy:
- 1.0 = Fully calibrated, highest accuracy
- 0.5 = Partially calibrated
- 0.0 = Not calibrated, readings may be inaccurate

**Tip:** If calibration is low, move your device in a figure-8 pattern to calibrate the compass.

## Use Cases

### Photography/Documentation
Record the direction you were facing when taking site photos

### Forestry/Ecology
Document tree lean direction and angle

### Geology
Record strike and dip measurements when combined with specialized tools

### Utilities/Infrastructure
Document the orientation of installed equipment

### Surveying
Add orientation metadata to survey points

## Troubleshooting

### Sensors Not Available

**Problem:** "Compass/Accelerometer not available" message

**Solutions:**
- Ensure location permissions are granted to QField
- Check that your device has a magnetometer (compass) sensor
- Restart QField
- On iOS, check Settings → Privacy → Motion & Fitness

### Inaccurate Compass Readings

**Problem:** Azimuth values seem wrong

**Solutions:**
- Calibrate compass by moving device in figure-8 pattern
- Move away from magnetic interference (metal objects, electronics)
- Check calibration level in the info dialog

### Values Not Saving

**Problem:** Orientation data doesn't persist in features

**Solutions:**
- Ensure your layer has the correct attribute fields configured
- Check field types match (text/string for JSON, decimal for numbers)
- Verify the layer is editable
- Make sure you're pasting into the correct field

## Limitations

1. **Manual Capture**: Current version requires manual button press
   - Future versions may support automatic capture on feature save

2. **Compass Accuracy**: 
   - Requires device calibration
   - Affected by magnetic interference
   - Reports magnetic north, not true north

3. **Platform Support**:
   - Requires Qt Sensors support
   - Most modern smartphones supported
   - Some tablets may lack magnetometer

## Technical Details

### Dependencies
- Qt Quick 2.x
- QtSensors 5.x
- QField 3.x or later

### Sensor Update Rate
- 10 Hz (10 updates per second)
- Provides smooth real-time readings

### Coordinate System
- Azimuth: 0-360° clockwise from magnetic north
- Pitch/Roll: Standard aerospace convention
- All angles in degrees

## Advanced: Expression-Based Population

For advanced users, you can create QGIS expressions to auto-populate fields:

```python
# This would require plugin modification to expose orientation to expressions
# Future enhancement possibility
```

## Support & Contributions

- Issues: Report bugs or request features
- QField Docs: https://docs.qfield.org
- Qt Sensors: https://doc.qt.io/qt-5/qtsensors-index.html

## Version History

### Version 1.0
- Initial release
- Compass azimuth capture
- Accelerometer pitch/roll capture
- Manual orientation capture
- Clipboard integration
- Info dialog with sensor status

## License

This plugin is provided as-is for use with QField.
