extends Node2D

# Idle Railway Empire — Prototype v0.2 (Phase 1 Refactored)
# Focus: Modular architecture with decoupled CameraController2D, HUDController,
# GameConfig data isolation, exact spline preview, and bidirectional train orientation.

@onready var camera: CameraController2D = $WorldCamera
@onready var hud: HUDController = $HUD

var build_mode: bool = false
var is_panning: bool = false
var route_points: PackedVector2Array = PackedVector2Array()
var tracks: Array[PackedVector2Array] = []
var coins: int = GameConfig.STARTING_COINS
var built_route_length: float = 0.0
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
	queue_redraw()

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
	queue_redraw()

func _draw() -> void:
	_draw_world()
	_draw_river_and_terrain_features()
	_draw_roads()
	_draw_locked_areas()
	_draw_tracks()
	_draw_station(GameConfig.STATION_A_POS, GameConfig.STATION_A_NAME, GameConfig.STATION_A_COLOR, true)
	_draw_station(GameConfig.STATION_B_POS, GameConfig.STATION_B_NAME, GameConfig.STATION_B_COLOR, false)
	if build_mode:
		_draw_build_preview()
	if not tracks.is_empty():
		var train_pos: Vector2 = _point_on_path(tracks[0], train_distance)
		var track_angle: float = _angle_on_path(tracks[0], train_distance)
		# Face travel direction when shuttling
		var train_facing: float = track_angle if train_direction >= 0.0 else track_angle + PI
		_draw_train(train_pos, train_facing)
	_draw_map_labels()

func _draw_world() -> void:
	# Base land and soft terrain blocks.
	draw_rect(Rect2(Vector2.ZERO, Vector2(GameConfig.WORLD_WIDTH, GameConfig.WORLD_HEIGHT)), Color("#b4d78a"), true)
	var field_colors: Array[Color] = [Color("#c7df97"), Color("#a9cf7c"), Color("#d6e5a4"), Color("#bddd8d")]
	for row in range(9):
		for col in range(15):
			var x: float = 70.0 + float(col) * 190.0 + float((row % 2) * 30)
			var y: float = 80.0 + float(row) * 175.0
			var w: float = 145.0 + float((col % 3) * 10)
			var h: float = 104.0 + float((row % 2) * 12)
			var rect: Rect2 = Rect2(Vector2(x, y), Vector2(w, h))
			draw_rect(rect, field_colors[(row + col) % field_colors.size()], true)
			draw_rect(rect, Color("#91b96d"), false, 2.0)
			# Furrows give fields a little texture without external art assets.
			for line_index in range(1, 4):
				var line_y: float = y + float(line_index) * h / 4.0
				draw_line(Vector2(x + 8.0, line_y), Vector2(x + w - 8.0, line_y), Color(0.45, 0.61, 0.31, 0.24), 2.0)
	# Small groves, kept away from the immediate station footprints.
	for i in range(95):
		var tx: float = 100.0 + fmod(float(i * 193), GameConfig.WORLD_WIDTH - 180.0)
		var ty: float = 70.0 + fmod(float(i * 127), GameConfig.WORLD_HEIGHT - 140.0)
		if Vector2(tx, ty).distance_to(GameConfig.STATION_A_POS) > 170.0 and Vector2(tx, ty).distance_to(GameConfig.STATION_B_POS) > 170.0:
			_draw_tree(Vector2(tx, ty), 0.72 + float(i % 4) * 0.1)

func _draw_river_and_terrain_features() -> void:
	var river: PackedVector2Array = PackedVector2Array([
		Vector2(1020, -20), Vector2(990, 170), Vector2(1080, 320),
		Vector2(1240, 435), Vector2(1190, 575), Vector2(1300, 720),
		Vector2(1250, 875), Vector2(1385, 1040), Vector2(1320, 1220), Vector2(1430, 1620)
	])
	draw_polyline(river, Color("#7fbac1"), 125.0, true)
	draw_polyline(river, Color("#9bd4d6"), 105.0, true)
	draw_polyline(river, Color("#b8e2df"), 4.0, true)
	# Riverbank grasses and stones.
	for i in range(34):
		var px: float = 930.0 + fmod(float(i * 91), 520.0)
		var py: float = 90.0 + fmod(float(i * 157), 1390.0)
		draw_circle(Vector2(px, py), 4.0 + float(i % 3), Color("#779b61"))
	# Distant hill clusters in the north-east.
	for i in range(8):
		var hx: float = 1780.0 + float(i) * 120.0
		var hy: float = 95.0 + float((i * 53) % 125)
		draw_colored_polygon(PackedVector2Array([
			Vector2(hx - 85, hy + 105), Vector2(hx - 35, hy + 20),
			Vector2(hx + 15, hy + 55), Vector2(hx + 68, hy - 5),
			Vector2(hx + 110, hy + 105)
		]), Color("#8dbb79"))
		draw_line(Vector2(hx - 35, hy + 20), Vector2(hx + 15, hy + 55), Color("#d7e9b0"), 3.0)

func _draw_roads() -> void:
	var road_a: PackedVector2Array = PackedVector2Array([
		Vector2(70, 610), Vector2(260, 660), Vector2(470, 625), Vector2(700, 660), Vector2(890, 620)
	])
	var road_b: PackedVector2Array = PackedVector2Array([
		Vector2(1820, 845), Vector2(1970, 800), Vector2(2240, 855), Vector2(2510, 800), Vector2(2730, 820)
	])
	draw_polyline(road_a, Color("#d8cba8"), 19.0, true)
	draw_polyline(road_a, Color("#f2e9d4"), 13.0, true)
	draw_polyline(road_b, Color("#d8cba8"), 19.0, true)
	draw_polyline(road_b, Color("#f2e9d4"), 13.0, true)

func _draw_locked_areas() -> void:
	# Softly indicated expansion zones; these are not interactive yet.
	var locked_rects: Array[Rect2] = [
		Rect2(Vector2(2320, 180), Vector2(370, 260)),
		Rect2(Vector2(80, 1180), Vector2(330, 250)),
		Rect2(Vector2(2100, 1160), Vector2(500, 290))
	]
	for rect in locked_rects:
		draw_rect(rect, Color(0.16, 0.25, 0.28, 0.14), true)
		draw_rect(rect, Color("#849d78"), false, 4.0)
		draw_circle(rect.position + rect.size * 0.5, 22.0, Color("#e4e9d7"))
		draw_circle(rect.position + rect.size * 0.5, 22.0, Color("#90a386"), false, 3.0)
		# Simple lock icon.
		var c: Vector2 = rect.position + rect.size * 0.5
		draw_rect(Rect2(c + Vector2(-10, -2), Vector2(20, 17)), Color("#677d6c"), true)
		draw_arc(c + Vector2(0, -3), 7.0, PI, TAU, 16, Color("#677d6c"), 3.0)

func _draw_tracks() -> void:
	for path in tracks:
		_draw_rail_path(path, false)

func _draw_build_preview() -> void:
	var raw_preview: PackedVector2Array = route_points.duplicate()
	raw_preview.append(GameConfig.STATION_B_POS)
	var preview: PackedVector2Array = _smooth_path(raw_preview)
	if preview.size() >= 2:
		draw_polyline(preview, Color(0.12, 0.2, 0.22, 0.35), 17.0, true)
		draw_polyline(preview, Color("#f6d56f"), 8.0, true)
	for point in route_points:
		draw_circle(point, 8.0, Color("#fff3b0"))
		draw_circle(point, 4.0, Color("#d59e35"))
	draw_circle(GameConfig.STATION_B_POS, 8.0, Color("#a8d5ff"))

func _draw_rail_path(path: PackedVector2Array, preview: bool) -> void:
	if path.size() < 2:
		return
	# Track bed and sleepers.
	draw_polyline(path, Color("#b9a58c"), 21.0, true)
	draw_polyline(path, Color("#776c61"), 15.0, true)
	for i in range(path.size() - 1):
		var a: Vector2 = path[i]
		var b: Vector2 = path[i + 1]
		var segment: Vector2 = b - a
		var length: float = segment.length()
		if length < 0.1:
			continue
		var normal: Vector2 = Vector2(-segment.y, segment.x).normalized()
		var sleepers: int = max(1, int(length / 17.0))
		for s in range(sleepers + 1):
			var p: Vector2 = a.lerp(b, float(s) / float(sleepers))
			draw_line(p - normal * 7.0, p + normal * 7.0, Color("#4d4944"), 3.0)
		# Two steel rails either side of centreline.
		draw_line(a + normal * 4.7, b + normal * 4.7, Color("#d5d9d6"), 3.0)
		draw_line(a - normal * 4.7, b - normal * 4.7, Color("#d5d9d6"), 3.0)

func _draw_station(position: Vector2, station_name: String, accent: Color, is_start: bool) -> void:
	# Basic station footprint only; detailed facilities are not built at start.
	var ground: Rect2 = Rect2(position + Vector2(-100, 28), Vector2(200, 54))
	draw_rect(ground, Color("#e0d9c3"), true)
	draw_rect(ground, Color("#b9b29f"), false, 2.0)
	# Bare platform slab and a small boarding zone marker.
	draw_rect(Rect2(position + Vector2(-87, 14), Vector2(174, 18)), Color("#d0d0c4"), true)
	draw_line(position + Vector2(-87, 14), position + Vector2(87, 14), Color("#f9f3dd"), 3.0)
	draw_rect(Rect2(position + Vector2(-11, 2), Vector2(22, 12)), accent, true)
	draw_circle(position, 17.0, accent)
	draw_circle(position, 8.0, Color("#fff7d5"))
	# Station nameplate.
	var plaque: Rect2 = Rect2(position + Vector2(-122, -68), Vector2(244, 42))
	draw_rect(plaque, Color("#fff3d4"), true)
	draw_rect(plaque, accent.darkened(0.12), false, 3.0)
	draw_string(ThemeDB.fallback_font, plaque.position + Vector2(12, 27), station_name, HORIZONTAL_ALIGNMENT_CENTER, plaque.size.x - 24, 18, Color("#28434b"))
	var subtitle: String = "START STATION" if is_start else "AVAILABLE STATION"
	draw_string(ThemeDB.fallback_font, position + Vector2(-75, 112), subtitle, HORIZONTAL_ALIGNMENT_CENTER, 150, 13, Color("#3f5d52"))

func _draw_train(position: Vector2, angle: float) -> void:
	# Stylised placeholder train. It will later be replaced by authored 2D art.
	draw_set_transform(position, angle, Vector2.ONE)
	draw_rect(Rect2(Vector2(-50, -21), Vector2(100, 42)), Color("#f2f0df"), true)
	draw_rect(Rect2(Vector2(-50, -21), Vector2(100, 11)), Color("#2b76ac"), true)
	draw_rect(Rect2(Vector2(-50, 10), Vector2(100, 7)), Color("#286798"), true)
	for window_index in range(4):
		draw_rect(Rect2(Vector2(-38 + window_index * 20, -7), Vector2(13, 12)), Color("#a9dce5"), true)
	draw_rect(Rect2(Vector2(33, -13), Vector2(14, 26)), Color("#d8e9e6"), true)
	draw_circle(Vector2(-29, 21), 4.0, Color("#494b4a"))
	draw_circle(Vector2(29, 21), 4.0, Color("#494b4a"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_tree(pos: Vector2, scale_value: float) -> void:
	draw_rect(Rect2(pos + Vector2(-2, 2) * scale_value, Vector2(4, 12) * scale_value), Color("#926d4e"), true)
	draw_circle(pos, 9.0 * scale_value, Color("#6eaa60"))
	draw_circle(pos + Vector2(-5, -3) * scale_value, 6.0 * scale_value, Color("#84bd70"))
	draw_circle(pos + Vector2(5, -4) * scale_value, 6.0 * scale_value, Color("#5a9a55"))

func _draw_map_labels() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(300, 300), "SAHYADRI VALLEY", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.19, 0.34, 0.26, 0.75))
	draw_string(ThemeDB.fallback_font, Vector2(1620, 1320), "FUTURE EXPANSION", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.19, 0.34, 0.26, 0.65))

func _on_build_pressed() -> void:
	if not tracks.is_empty():
		_set_status("Prototype supports one connection. The first route is already built!")
		return
	build_mode = true
	is_panning = false
	route_points = PackedVector2Array([GameConfig.STATION_A_POS])
	_update_hud()
	_set_status("BUILD MODE: Tap the map to add bends, then choose Finish Route. The route snaps to Nadi Gaon.")
	queue_redraw()

func _on_finish_pressed() -> void:
	if not build_mode:
		_set_status("Tap Build Track first to begin planning a route.")
		return
	var raw_path: PackedVector2Array = route_points.duplicate()
	raw_path.append(GameConfig.STATION_B_POS)
	var smooth_path: PackedVector2Array = _smooth_path(raw_path)
	var length: float = _path_length(smooth_path)
	var cost: int = int(ceil(length * GameConfig.TRACK_COST_PER_WORLD_UNIT))
	if cost > coins:
		_set_status("Not enough coins. Route costs %s coins; you have %s." % [_format_number(cost), _format_number(coins)])
		return
	coins -= cost
	built_route_length = length
	tracks.append(smooth_path)
	build_mode = false
	is_panning = false
	route_points.clear()
	train_distance = 0.0
	train_direction = 1.0
	_set_status("Route complete! Asha Nagar is now connected to Nadi Gaon. Your first train is running.")
	_update_hud()
	queue_redraw()

func _on_cancel_pressed() -> void:
	build_mode = false
	is_panning = false
	route_points.clear()
	_set_status("Build mode cancelled. Your map is unchanged.")
	_update_hud()
	queue_redraw()

func _on_reset_view_pressed() -> void:
	if is_instance_valid(camera):
		camera.reset_view()
	_set_status("View reset. Drag the map to explore and use the mouse wheel to zoom.")

func _update_hud() -> void:
	if is_instance_valid(hud):
		hud.update_coins(coins)
		hud.set_build_mode(build_mode, not tracks.is_empty())

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
	_set_status("Waypoint added. Keep plotting your route, or choose Finish Route to connect to Nadi Gaon.")
	queue_redraw()

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

func _point_on_path(path: PackedVector2Array, distance: float) -> Vector2:
	if path.is_empty():
		return Vector2.ZERO
	var remaining: float = max(0.0, distance)
	for i in range(path.size() - 1):
		var segment_length: float = path[i].distance_to(path[i + 1])
		if remaining <= segment_length:
			if segment_length <= 0.001:
				return path[i]
			return path[i].lerp(path[i + 1], remaining / segment_length)
		remaining -= segment_length
	return path[path.size() - 1]

func _angle_on_path(path: PackedVector2Array, distance: float) -> float:
	if path.size() < 2:
		return 0.0
	var remaining: float = max(0.0, distance)
	for i in range(path.size() - 1):
		var segment: Vector2 = path[i + 1] - path[i]
		var segment_length: float = segment.length()
		if remaining <= segment_length:
			return segment.angle()
		remaining -= segment_length
	return (path[path.size() - 1] - path[path.size() - 2]).angle()

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
