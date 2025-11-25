# Quick Start Guide - Orientation Capture Plugin

## ⚡ 5-Minute Setup

### 1. Prepare Your QGIS Project (2 minutes)

In QGIS, add these fields to your point layer:

| Field Name   | Type    | Length | Precision |
|--------------|---------|--------|-----------|
| azimuth      | Decimal | 10     | 2         |
| pitch        | Decimal | 10     | 2         |
| roll         | Decimal | 10     | 2         |

**OR** use a single field:
- `orientation_data` (Text, 500 characters)

### 2. Install Plugin (1 minute)

**For project-specific use:**
- Rename `main.qml` to match your project name
  - Example: `myproject.qgs` → `myproject.qml`
- Place in same folder as your QGIS project

**For QFieldCloud:**
- Upload the `.qml` file to your cloud project

### 3. Use in Field (2 minutes)

1. Open project in QField on your iPhone
2. Grant plugin permission when prompted
3. See the green 📍 button? You're ready!
4. Tap it to capture orientation
5. Paste the data into your feature attributes

## 📱 What You'll See

### On First Load
```
✓ Orientation Capture Plugin ready!

Tap the info button (ℹ️) for instructions.
```

### When Capturing
```
Orientation captured!
Azimuth: 127.5° | Pitch: 15.2° | Roll: -3.1°

JSON copied to clipboard.
Paste into your feature attributes.
```

## 🎯 Real-World Example

**Scenario:** Recording tree lean direction

1. Stand at the tree
2. Point phone towards lean direction
3. Tap green 📍 button
4. Add your tree point in QField
5. In the form, paste orientation data
6. Save!

Result: You now have:
- `azimuth`: 245° (tree leans SW)
- `pitch`: 12° (12° lean from vertical)
- `roll`: 2° (slightly twisted)

## ❓ Quick Troubleshooting

**"Compass not available"**
→ Check Settings → Privacy → Motion & Fitness on iPhone

**Numbers seem wrong**
→ Wave phone in figure-8 to calibrate compass
→ Move away from metal objects

**Can't paste data**
→ Check field type is Text or Decimal
→ Ensure layer is editable

## 🔧 Pro Tips

1. **Calibrate First**: Wave device in figure-8 before starting fieldwork
2. **Check Calibration**: Tap blue ℹ️ button to see sensor status
3. **Consistent Hold**: Hold device same way for all measurements
4. **Metal Warning**: Stay away from vehicles, fences, tools

## 📊 Data Format

The captured JSON looks like this:
```json
{"azimuth":127.5,"pitch":15.2,"roll":-3.1,"calibration":0.89,"timestamp":"2024-11-24T14:23:45.123Z"}
```

If using separate fields, extract:
- `azimuth` → 127.5
- `pitch` → 15.2
- `roll` → -3.1

## ✅ That's It!

You're now ready to capture spatial orientation with every point you save!

For detailed info, see the full README.md
