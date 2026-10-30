class_name GameConfig
extends RefCounted

## GameConfig
## Centralized game parameters, coordinates, colors, and visual styling definitions.

# World Dimensions
const WORLD_WIDTH: float = 2800.0
const WORLD_HEIGHT: float = 1600.0

# Station Locations & Metadata
const STATION_A_NAME: String = "ASHA NAGAR"
const STATION_A_NAME_HINDI: String = "आशा नगर"
const STATION_A_POS: Vector2 = Vector2(470.0, 820.0)
const STATION_A_COLOR: Color = Color("#e8b45c")

const STATION_B_NAME: String = "NADI GAON"
const STATION_B_NAME_HINDI: String = "नदी गाँव"
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

# Train Settings & Consist Dimensions
const TRAIN_SPEED: float = 110.0
const LOCOMOTIVE_LENGTH: float = 72.0
const LOCOMOTIVE_WIDTH: float = 26.0
const COACH_LENGTH: float = 78.0
const COACH_WIDTH: float = 24.0
const COUPLER_GAP: float = 10.0
const NUM_COACHES: int = 2

# Track Dimensions
const TRACK_GAUGE: float = 11.0 # Distance between rails
const RAIL_WIDTH: float = 2.4
const BALLAST_WIDTH: float = 26.0
const SLEEPER_SPACING: float = 15.0
const SLEEPER_LENGTH: float = 22.0
const SLEEPER_WIDTH: float = 4.2

# River & Bridge Zone
const RIVER_MIN_X: float = 960.0
const RIVER_MAX_X: float = 1440.0

# Build Mode Constraints
const MIN_STATION_DISTANCE: float = 90.0
const MAX_WAYPOINTS: int = 10
const MAP_BOUNDARY_PADDING: float = 80.0

# Color Palette — Indian Railway Inspired
const COLOR_BALLAST_BASE: Color = Color("#8c7f73")
const COLOR_BALLAST_EDGE: Color = Color("#6e6359")
const COLOR_BALLAST_SHADOW: Color = Color(0.15, 0.12, 0.1, 0.25)
const COLOR_SLEEPER: Color = Color("#453b34")
const COLOR_SLEEPER_CONCRETE: Color = Color("#b0aaa2")
const COLOR_RAIL_BASE: Color = Color("#3e4448")
const COLOR_RAIL_HEAD: Color = Color("#d8e0e5")
const COLOR_RAIL_SPECULAR: Color = Color("#ffffff")

# Bridge Colors
const COLOR_BRIDGE_PIER: Color = Color("#8a8276")
const COLOR_BRIDGE_PIER_DARK: Color = Color("#655e54")
const COLOR_BRIDGE_GIRDER: Color = Color("#9e3d2f") # Classic Indian Railways oxide red
const COLOR_BRIDGE_GIRDER_DARK: Color = Color("#6f291e")
const COLOR_BRIDGE_TIE: Color = Color("#2e2620")

# Train Livery Colors (Classic IR Blue & Cream)
const COLOR_LOCO_BODY: Color = Color("#1d4a7a") # IR Deep Blue
const COLOR_LOCO_STRIPE: Color = Color("#f4d06f") # Cream / Yellow stripe
const COLOR_LOCO_ROOF: Color = Color("#37424d")
const COLOR_LOCO_CAB_WINDOW: Color = Color("#8ae1f0")
const COLOR_LOCO_HEADLIGHT: Color = Color("#fff8db")
const COLOR_COACH_BODY: Color = Color("#22578c") # ICF Blue
const COLOR_COACH_STRIPE: Color = Color("#f5eedb") # Cream cheatline
const COLOR_COACH_ROOF: Color = Color("#b3bcc2")
const COLOR_TRAIN_SHADOW: Color = Color(0.08, 0.1, 0.12, 0.35)

# Station Palette
const COLOR_STATION_BOARD_BG: Color = Color("#ffcf33") # Iconic Indian Railways mustard yellow
const COLOR_STATION_BOARD_BORDER: Color = Color("#181818")
const COLOR_STATION_BOARD_TEXT: Color = Color("#181818")
const COLOR_PLATFORM_SURFACE: Color = Color("#ded8c7")
const COLOR_PLATFORM_EDGE: Color = Color("#e5b638") # Yellow safety line
const COLOR_PLATFORM_CURB: Color = Color("#a19b8c")
const COLOR_BUILDING_WALL: Color = Color("#e5dfce")
const COLOR_BUILDING_ROOF: Color = Color("#b84c37") # Terracotta roof tiles
