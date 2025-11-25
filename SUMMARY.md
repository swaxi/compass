# QField Spatial Orientation Capture Plugin - Summary

## 📱 What This Plugin Does

This QField plugin captures your iPhone's spatial orientation when you save data points, recording:

1. **Azimuth** (0-360°) - Compass heading relative to magnetic north
2. **Pitch** (-90° to +90°) - Forward/backward tilt from horizontal  
3. **Roll** (-90° to +90°) - Left/right tilt from horizontal

## 🎯 Key Features

- ✅ Real-time sensor readings from iPhone compass and accelerometer
- ✅ One-tap capture of orientation data
- ✅ Automatic clipboard copy of orientation values
- ✅ Visual feedback and sensor status display
- ✅ JSON format for easy attribute storage
- ✅ Works offline - no internet required
- ✅ Integrates seamlessly with QField digitizing workflow

## 📦 Package Contents

```
qfield_orientation_plugin/
├── main.qml                    # Main plugin code
├── metadata.txt                # Plugin metadata
├── compass_icon.svg            # Plugin icon
├── README.md                   # Full documentation
├── QUICKSTART.md              # 5-minute setup guide
├── INSTALL.md                 # Detailed installation instructions
└── example_layer_setup.sql    # Database setup example
```

## ⚡ Quick Start (3 Steps)

### 1. Prepare QGIS Layer
Add these fields to your point layer:
- `azimuth` (Decimal 10.2)
- `pitch` (Decimal 10.2)  
- `roll` (Decimal 10.2)

### 2. Install Plugin
- Rename `main.qml` to match your project (e.g., `myproject.qml`)
- Place it next to your `.qgs` project file
- If using QFieldCloud: upload both files together

### 3. Use in Field
- Open project in QField on iPhone
- Grant plugin permission
- Tap green 📍 button to capture orientation
- Paste into feature attributes when saving

## 🎬 Usage Example

**Scenario: Recording a leaning tree**

1. Stand at tree, point iPhone toward lean direction
2. Tap 📍 "Capture Orientation" button
3. See: `Azimuth: 245° | Pitch: 12° | Roll: 2°`
4. Add tree point in QField
5. In attribute form, paste captured orientation
6. Save feature

**Result:** Tree orientation permanently recorded!

## 📊 Data Format

**Captured as JSON:**
```json
{
  "azimuth": 245.5,
  "pitch": 12.3,
  "roll": 2.1,
  "calibration": 0.87,
  "timestamp": "2024-11-24T14:30:00.000Z"
}
```

**Parse into separate fields or store as single text field.**

## 🔧 Technical Requirements

**Device:**
- iPhone with iOS 13+
- Built-in compass (magnetometer)
- Built-in accelerometer
- All iPhones have these sensors

**Software:**
- QField 3.0 or later (3.3+ recommended)
- QGIS 3.x for project preparation

**Project:**
- Point layer with appropriate orientation fields
- Editable vector layer (GeoPackage recommended)

## 💡 Use Cases

| Field | Application |
|-------|------------|
| **Forestry** | Tree lean direction and angle |
| **Photography** | Camera/photo orientation metadata |
| **Geology** | Strike/dip measurements |
| **Utilities** | Equipment installation orientation |
| **Archaeology** | Artifact orientation documentation |
| **Surveying** | Instrument setup orientation |
| **Biology** | Plant growth direction |

## ⚠️ Important Notes

### Compass Calibration
- **Always calibrate** before fieldwork
- Wave phone in figure-8 pattern
- Check calibration value (aim for >0.7)
- Re-calibrate if readings seem off

### Accuracy Factors
- **Magnetic interference** - Stay away from:
  - Metal objects (fences, vehicles, tools)
  - Electronics (power lines, equipment)
  - Magnetic phone cases
- **Device orientation** - Hold consistently
- **Movement** - Be still when capturing

### Limitations
- Records **magnetic north**, not true north
  - Apply magnetic declination correction if needed
  - Your location: Perth, WA has ~0° declination (minimal correction needed)
- Manual capture currently (tap button)
- Requires stable device position

## 📱 iPhone-Specific Tips

1. **Permissions**: Grant Motion & Fitness access
   - Settings → Privacy & Security → Motion & Fitness → QField
   
2. **Battery**: Sensors use power
   - Bring external battery for long sessions
   - Consider airplane mode if not using cloud sync

3. **Case**: Remove magnetic cases during use

4. **Calibration**: Happens automatically with movement
   - Figure-8 motion forces calibration
   - Check calibration level in plugin info (ℹ️)

## 📚 Documentation Files

| File | Purpose | When to Read |
|------|---------|--------------|
| **INSTALL.md** | Installation steps | Before setup |
| **QUICKSTART.md** | Fast setup guide | First time use |
| **README.md** | Complete documentation | Reference |
| **This file** | Overview | Right now! |

## 🚀 Getting Started Path

```
1. Read INSTALL.md → Install plugin
2. Read QUICKSTART.md → Configure QGIS project  
3. Test in QField → Practice capturing
4. Use README.md → Detailed reference as needed
```

## ✅ Success Checklist

Before going to the field:

- [ ] Plugin installed in QField
- [ ] QGIS layer has orientation fields
- [ ] Tested plugin activation (permission granted)
- [ ] Verified sensors working (ℹ️ button shows active)
- [ ] Calibrated compass (figure-8 motion)
- [ ] Practiced capture workflow
- [ ] External battery charged
- [ ] Project synced to device

## 🎓 Learning Resources

- **QField Docs**: https://docs.qfield.org
- **Qt Sensors**: https://doc.qt.io/qt-5/qtsensors-index.html
- **Plugin Framework**: https://docs.qfield.org/reference/plugins/

## 💬 Common Questions

**Q: Do I need internet?**
A: No! Plugin works completely offline.

**Q: Will this drain my battery?**
A: Sensors use some power, but modern iPhones handle it well. Bring backup battery for extended use.

**Q: Can I use with iPad?**
A: Yes, if iPad has compass (most cellular iPads do, WiFi-only models may not).

**Q: What about true north vs magnetic north?**
A: Plugin records magnetic north. In Perth, WA, declination is near 0° so difference is minimal.

**Q: Can I capture while moving?**
A: Best results when stationary. Moving causes sensor fluctuations.

**Q: How accurate is it?**
A: Typical accuracy: ±5° for compass, ±2° for tilt (when calibrated and away from interference).

## 🐛 Troubleshooting Quick Reference

| Problem | Solution |
|---------|----------|
| "Sensor not available" | Check iOS privacy settings |
| Inaccurate readings | Calibrate compass (figure-8) |
| Plugin won't load | Verify filename matches project |
| Can't paste data | Check field is Text or Decimal type |
| Numbers jump around | Move away from metal/interference |

## 📞 Need Help?

1. Check troubleshooting in README.md
2. Verify requirements in INSTALL.md
3. Review QField plugin documentation
4. Check sensor access in iOS settings

---

## Version Information

- **Plugin Version**: 1.0
- **Release Date**: November 2024
- **QField Compatibility**: 3.0+
- **iOS Compatibility**: 13.0+

---

**Ready to capture spatial orientation data in the field? Start with INSTALL.md!** 🧭📍
