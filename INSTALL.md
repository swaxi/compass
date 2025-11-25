# Installation Instructions - QField Orientation Capture Plugin

## 📦 What You Have

- **qfield_orientation_plugin.zip** - Complete plugin package
- **qfield_orientation_plugin/** - Unzipped plugin files

## 🎯 Choose Your Installation Method

### Method 1: Project-Specific Plugin (Recommended for iPhone)

**Best for:** Single project or QFieldCloud users

**Steps:**

1. **Unzip the plugin package**
   - Extract `qfield_orientation_plugin.zip`

2. **Rename the main plugin file**
   - Find `main.qml` in the extracted folder
   - Rename it to match your QGIS project file
   - Example: If your project is `tree_survey.qgs`, rename to `tree_survey.qml`

3. **Place alongside your project**
   - Put the renamed `.qml` file in the same directory as your `.qgs` project file
   - Your folder should look like:
     ```
     /my_project/
       ├── tree_survey.qgs
       ├── tree_survey.qml  ← Plugin
       ├── data.gpkg
       └── ...
     ```

4. **For QFieldCloud users:**
   - Upload your project to QFieldCloud as normal
   - Upload the `.qml` file to the same cloud project folder
   - QField will automatically detect and offer to activate it

5. **For direct transfer to iPhone:**
   - Use iTunes File Sharing or iCloud
   - Copy the entire project folder including the `.qml` file
   - Open in QField

### Method 2: App-Wide Plugin

**Best for:** Using across multiple projects

**iOS/iPhone Steps:**

Since iOS has restrictions on file system access, you'll need to:

1. **Use QFieldCloud** (easier):
   - Create a "plugins" folder in your QFieldCloud projects
   - Upload the plugin folder
   - Configure QField to sync this location

2. **Or use iTunes File Sharing**:
   - Connect iPhone to computer
   - Open iTunes/Finder
   - Go to File Sharing → QField
   - Add the plugin folder to: `QField/plugins/orientation_capture/`
   - Structure should be:
     ```
     QField/
       └── plugins/
           └── orientation_capture/
               ├── main.qml
               ├── metadata.txt
               └── compass_icon.svg
     ```

3. **Enable in QField**:
   - Open QField
   - Go to Settings → Plugins
   - Find "Spatial Orientation Capture"
   - Enable it

## 🔧 QGIS Project Configuration

Before going to the field:

1. **Open your project in QGIS**

2. **Add orientation fields to your layer**:
   - Open Layer Properties for your point layer
   - Go to Fields tab
   - Add new fields:
     - `azimuth` (Decimal, 10.2)
     - `pitch` (Decimal, 10.2)
     - `roll` (Decimal, 10.2)
   
   *OR use single field:*
     - `orientation_data` (Text, 500 chars)

3. **Configure the form** (optional but recommended):
   - Go to Attributes Form tab
   - For each field:
     - Set appropriate widget (Text Edit for JSON, or Range/Spin Box for decimals)
     - Consider making them read-only if you only paste data
     - Set up constraints if needed

4. **Save and sync to QField**

## ✅ Verify Installation

1. **Open your project in QField**

2. **Look for plugin prompt**:
   - On first load, you should see permission request
   - Grant permission (choose "Always" for convenience)

3. **Check for toolbar buttons**:
   - Green 📍 button = Capture Orientation
   - Blue ℹ️ button = Info/Help
   
   If you see these, you're ready!

4. **Test sensors**:
   - Tap the blue ℹ️ button
   - Check that it shows:
     - ✓ Compass: Active
     - ✓ Accelerometer: Active
   - If not, check device permissions

## 🔍 Troubleshooting Installation

### Plugin doesn't load

**Check:**
- File is named correctly (matches project name for project plugins)
- File is in correct location
- File has `.qml` extension (not `.qml.txt`)

### Permission denied

**iOS:**
- Go to iPhone Settings
- Privacy & Security → Motion & Fitness
- Enable for QField

**QField Settings:**
- Allow plugin activation when prompted
- Check Settings → Plugins

### Buttons don't appear

**Solutions:**
- Restart QField
- Check plugin is enabled in Settings → Plugins
- Verify `main.qml` has no syntax errors
- Check console log for errors

## 📱 Device Requirements

### Minimum Requirements:
- **iPhone:** iOS 13 or later
- **QField:** Version 3.0 or later
- **Sensors:** Magnetometer (compass) and accelerometer
  - All iPhones have these sensors
  - Most iPads have them (check your model)

### Recommended:
- **QField:** Latest version (3.3+)
- **iOS:** Latest available for your device
- **Storage:** At least 100MB free for QField + projects

## 🎓 Next Steps

1. **Read the Quick Start Guide** (`QUICKSTART.md`)
2. **Review the full README** for detailed usage
3. **Set up a test project** to practice
4. **Calibrate your compass** before fieldwork

## 💡 Tips for iPhone Users

1. **Battery Life**: Sensors consume power, consider:
   - Bringing external battery
   - Reducing screen brightness
   - Disabling unused features

2. **Accuracy**: For best compass accuracy:
   - Calibrate before use (figure-8 motion)
   - Keep away from magnets and metal
   - Remove magnetic phone cases during use

3. **Workflow**: 
   - Capture orientation first
   - Then add/edit feature
   - Paste from clipboard
   - Much faster than typing!

## 📞 Support

If you encounter issues:

1. Check the troubleshooting sections in README.md
2. Verify all requirements are met
3. Test with QField desktop version first
4. Check QField documentation: https://docs.qfield.org
5. Review Qt Sensors documentation for platform-specific info

## 📄 Files Included

- `main.qml` - Main plugin code
- `metadata.txt` - Plugin information
- `compass_icon.svg` - Plugin icon
- `README.md` - Full documentation
- `QUICKSTART.md` - Quick start guide
- `example_layer_setup.sql` - Example database setup
- This file - Installation instructions

Happy mapping! 📍🧭
