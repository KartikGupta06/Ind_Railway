extends Node2D

## Main Coordinator — Idle Railway Empire (Phase V1 Visual Overhaul)
## Coordinates camera, environment renderer, track renderer, station renderer,
## train renderer, HUD controller, build mode, economy, and train simulation.

@onready var camera: CameraController2D = $WorldCamera
@onready var world_renderer: WorldRenderer = $WorldRenderer
@onready var track_renderer: TrackRenderer = $TrackRenderer
@onready var station_renderer: StationRenderer = $StationRenderer
@onready var train_renderer: TrainRenderer = $TrainRenderer
@onready var hud: HUDController = $HUD

var build_mode: bool = false
var is_panning: bool = false
var route_points: PackedVector2Array = PackedVector2Array()
var tracks: Array[PackedVector2Array] = []
var coins: int = GameConfig.STARTING_COINS
var train_distance: float = 0.0
var train_direction: float = 1.0
var train_speed: float = GameConfig.TRAIN_SPEED
var last_touch_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if is_instance_valid(hud):
		hud.build_pressed.connect(_on_build_pressed)
		hud.finish_pressed.connect(_on_finish_pressed)
		hud.cancel_pressed.connect(_on_cancel_pressed)
		hud.reset_view_pressed.connect(_on_reset_view_pressed)
	
	_update_hud()
	
	if is_instance_valid(track_renderer):
		track_renderer.update_tracks(tracks)
		track_renderer.update_build_preview(false, route_points)

func _process(delta: float) -> void:
	if not tracks.is_empty():
		var path: PackedVector2Array = tracks[0]
		var total_length: float = _path_length(path)
		if total_length > 0.0:
			train_distance += train_speed * delta * train_direction
			if train_distance >= total_length:
				train_distance = total_length
				train_direction = -1.0
			elif train_distance <= 0.0:
				train_distance = 0.0
				train_direction = 1.0
			
			if is_instance_valid(train_renderer):
				train_renderer.update_train(path, train_distance, train_direction)

func _on_build_pressed() -> void:
	if not tracks.is_empty():
		_set_status("Prototype supports one connection. The first route is already built!")
		return
	build_mode = true
	is_panning = false
	route_points = PackedVector2Array([GameConfig.STATION_A_POS])
	
	if is_instance_valid(track_renderer):
		track_renderer.update_build_preview(true, route_points)
	
	_update_hud()
	_update_build_cost_preview()
	_set_status("BUILD MODE: Click the landscape to add bends, then choose Finish Route. The route connects to Nadi Gaon.")

func _on_finish_pressed() -> void:
	if not build_mode:
		_set_status("Click Build Track first to begin planning a route.")
		return
	
	var raw_path: PackedVector2Array = route_points.duplicate()
	raw_path.append(GameConfig.STATION_B_POS)
	var smooth_path: PackedVector2Array = _smooth_path(raw_path)
	var length: float = _path_length(smooth_path)
	var cost: int = int(ceil(length * GameConfig.TRACK_COST_PER_WORLD_UNIT))
	
	if cost > coins:
		_set_status("Not enough coins! Route costs %s coins; you have %s." % [_format_number(cost), _format_number(coins)])
		return
	
	coins -= cost
	tracks.append(smooth_path)
	build_mode = false
	is_panning = false
	route_points.clear()
	train_distance = 0.0
	train_direction = 1.0
	
	if is_instance_valid(track_renderer):
		track_renderer.update_tracks(tracks)
		track_renderer.update_build_preview(false, route_points)
	
	if is_instance_valid(train_renderer):
		train_renderer.update_train(smooth_path, train_distance, train_direction)
	
	_update_hud()
	_set_status("Route complete! Asha Nagar is connected to Nadi Gaon across the Sahyadri River. Your passenger train is in service.")

func _on_cancel_pressed() -> void:
	build_mode = false
	is_panning = false
	route_points.clear()
	
	if is_instance_valid(track_renderer):
		track_renderer.update_build_preview(false, route_points)
	
	_update_hud()
	_set_status("Build mode cancelled. Landscape is unchanged.")

func _on_reset_view_pressed() -> void:
	if is_instance_valid(camera):
		camera.reset_view()
	_set_status("View reset. Drag the map to explore and use the mouse wheel to zoom.")

func _update_hud() -> void:
	if is_instance_valid(hud):
		hud.update_coins(coins)
		hud.set_build_mode(build_mode, not tracks.is_empty())

func _update_build_cost_preview() -> void:
	if not build_mode or not is_instance_valid(hud):
		return
	var raw_preview: PackedVector2Array = route_points.duplicate()
	raw_preview.append(GameConfig.STATION_B_POS)
	var preview: PackedVector2Array = _smooth_path(raw_preview)
	var length: float = _path_length(preview)
	var cost: int = int(ceil(length * GameConfig.TRACK_COST_PER_WORLD_UNIT))
	var bends_count: int = max(0, route_points.size() - 1)
	hud.update_build_cost(cost, coins, bends_count)

func _set_status(message: String) -> void:
	if is_instance_valid(hud):
		hud.set_status(message)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP and mouse_button.pressed:
			if is_instance_valid(camera):
				camera.zoom_at_cursor(true)
			return
		if mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse_button.pressed:
			if is_instance_valid(camera):
				camera.zoom_at_cursor(false)
			return
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_button.pressed:
				if build_mode:
					_add_route_waypoint(get_global_mouse_position())
				else:
					is_panning = true
			else:
				is_panning = false
	elif event is InputEventMouseMotion and is_panning:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		if is_instance_valid(camera):
			camera.pan(motion.relative)
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			last_touch_position = touch.position
			if build_mode:
				_add_route_waypoint(get_global_mouse_position())
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if build_mode:
			return
		if is_instance_valid(camera):
			camera.pan(drag.relative)
		last_touch_position = drag.position

func _add_route_waypoint(world_position: Vector2) -> void:
	if not build_mode:
		return
	var pad: float = GameConfig.MAP_BOUNDARY_PADDING
	var safe_position: Vector2 = Vector2(
		clampf(world_position.x, pad, GameConfig.WORLD_WIDTH - pad),
		clampf(world_position.y, pad, GameConfig.WORLD_HEIGHT - pad)
	)
	var min_dist: float = GameConfig.MIN_STATION_DISTANCE
	if safe_position.distance_to(GameConfig.STATION_A_POS) < min_dist or safe_position.distance_to(GameConfig.STATION_B_POS) < min_dist:
		_set_status("Waypoint is too close to a station. Add bends between the two stations, or finish the route.")
		return
	if route_points.size() >= GameConfig.MAX_WAYPOINTS:
		_set_status("This prototype supports up to %d intermediate bends per route." % (GameConfig.MAX_WAYPOINTS - 1))
		return
	
	route_points.append(safe_position)
	
	if is_instance_valid(track_renderer):
		track_renderer.update_build_preview(true, route_points)
	
	_update_build_cost_preview()
	var bends: int = route_points.size() - 1
	_set_status("Waypoint %d added. Continue plotting your route or choose Finish Route to construct." % bends)

func _smooth_path(raw: PackedVector2Array) -> PackedVector2Array:
	if raw.size() < 3:
		return raw.duplicate()
	var result: PackedVector2Array = PackedVector2Array()
	for i in range(raw.size() - 1):
		var p0: Vector2 = raw[max(0, i - 1)]
		var p1: Vector2 = raw[i]
		var p2: Vector2 = raw[i + 1]
		var p3: Vector2 = raw[min(raw.size() - 1, i + 2)]
		var subdivisions: int = 12
		for step in range(subdivisions):
			var t: float = float(step) / float(subdivisions)
			var t2: float = t * t
			var t3: float = t2 * t
			var point: Vector2 = 0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3)
			result.append(point)
	result.append(raw[raw.size() - 1])
	return result

func _path_length(path: PackedVector2Array) -> float:
	var length: float = 0.0
	for i in range(path.size() - 1):
		length += path[i].distance_to(path[i + 1])
	return length

func _format_number(value: int) -> String:
	var digits: String = str(value)
	var result: String = ""
	var counter: int = 0
	for i in range(digits.length() - 1, -1, -1):
		result = digits.substr(i, 1) + result
		counter += 1
		if counter == 3 and i > 0:
			result = "," + result
			counter = 0
	return result
