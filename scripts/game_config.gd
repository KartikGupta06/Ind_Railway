class_name GameConfig
extends RefCounted

# World Dimensions
const WORLD_WIDTH: float = 2800.0
const WORLD_HEIGHT: float = 1600.0

# Station Locations & Visual Metadata
const STATION_A_NAME: String = "ASHA NAGAR"
const STATION_A_POS: Vector2 = Vector2(470.0, 820.0)
const STATION_A_COLOR: Color = Color("#e8b45c")

const STATION_B_NAME: String = "NADI GAON"
const STATION_B_POS: Vector2 = Vector2(2240.0, 700.0)
const STATION_B_COLOR: Color = Color("#6ea6df")

# Economy Constants
const STARTING_COINS: int = 5000
const TRACK_COST_PER_WORLD_UNIT: float = 1.55

# Camera Settings
const DEFAULT_CAMERA_POS: Vector2 = Vector2(1350.0, 800.0)
const DEFAULT_CAMERA_ZOOM: Vector2 = Vector2(0.78, 0.78)
const MIN_ZOOM: float = 0.45
const MAX_ZOOM: float = 1.35
const ZOOM_FACTOR: float = 1.08

# Train Settings
const TRAIN_SPEED: float = 100.0

# Build Mode Constraints
const MIN_STATION_DISTANCE: float = 90.0
const MAX_WAYPOINTS: int = 10
const MAP_BOUNDARY_PADDING: float = 80.0

