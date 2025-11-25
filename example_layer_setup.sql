-- Example GeoPackage Layer Setup for Orientation Capture
-- Run this in QGIS DB Manager or use it as a guide

-- Create a simple point layer with orientation fields
CREATE TABLE observation_points (
    fid INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    description TEXT,
    photo_path TEXT,
    azimuth REAL,
    pitch REAL,
    roll REAL,
    orientation_data TEXT,
    captured_datetime TEXT,
    geom POINT
);

-- If you want to add the geometry column properly:
-- SELECT gpkgAddGeometryColumn('observation_points', 'geom', 'POINT', 0, 0, 4326);

-- Alternative: Single JSON field approach
CREATE TABLE observation_points_simple (
    fid INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    description TEXT,
    orientation_data TEXT,  -- Stores full JSON
    captured_datetime TEXT,
    geom POINT
);

/* 
NOTES:
1. The 'fid' field is required as a primary key for QField/QGIS
2. Set geometry type to POINT with your desired CRS (4326 = WGS84)
3. Azimuth, pitch, roll should be REAL (decimal) type
4. orientation_data can store the full JSON if preferred

QGIS FORM SETUP:
1. Open Layer Properties → Attributes Form
2. For orientation fields:
   - Set widget type to "Text Edit" or "Range" (for numeric)
   - For JSON field: set to "Text Edit" with multiline enabled
3. Optional: Set default values using expressions
4. Optional: Make fields read-only if auto-populating
*/
