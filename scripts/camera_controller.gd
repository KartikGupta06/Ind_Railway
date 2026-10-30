class_name CameraController2D
extends Camera2D

## CameraController2D
## Handles smooth panning, cursor-anchored zooming, and world boundary clamping.

@export var min_zoom: float = GameConfig.MIN_ZOOM
@export var max_zoom: float = GameConfig.MAX_ZOOM
@export var zoom_factor: float = GameConfig.ZOOM_FACTOR

func _ready() -> void:
	name = "WorldCamera"
	position = GameConfig.DEFAULT_CAMERA_POS
	zoom = GameConfig.DEFAULT_CAMERA_ZOOM
	
	# Configure world boundary limits
	limit_left = 0
	limit_top = 0
	limit_right = int(GameConfig.WORLD_WIDTH)
	limit_bottom = int(GameConfig.WORLD_HEIGHT)
	limit_smoothed = true
	
	position_smoothing_enabled = true
	position_smoothing_speed = 12.0
	reset_smoothing()
	make_current()

func pan(relative_motion: Vector2) -> void:
	position -= relative_motion / zoom
	_clamp_to_bounds()

func zoom_at_cursor(inward: bool) -> void:
	var factor: float = zoom_factor if inward else (1.0 / zoom_factor)
	var old_mouse_world: Vector2 = get_global_mouse_position()
	
	var new_zoom: Vector2 = (zoom * factor).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	if new_zoom == zoom:
		return
	zoom = new_zoom
	
	# Shift position so the point under the cursor remains under the cursor
	var new_mouse_world: Vector2 = get_global_mouse_position()
	position += (old_mouse_world - new_mouse_world)
	_clamp_to_bounds()

func reset_view() -> void:
	position = GameConfig.DEFAULT_CAMERA_POS
	zoom = GameConfig.DEFAULT_CAMERA_ZOOM
	reset_smoothing()

func _clamp_to_bounds() -> void:
	# Ensure camera position stays within world coordinates
	position.x = clampf(position.x, float(limit_left), float(limit_right))
	position.y = clampf(position.y, float(limit_top), float(limit_bottom))

