class_name TrainRenderer
extends Node2D

## TrainRenderer
## Renders a multi-car Indian Railways passenger train consist (WAP/WDM-style locomotive
## and 2 ICF passenger coaches) articulated along the curved track.
## Features authentic liveries, cab windows, headlights with night/evening glow,
## bogies, buffers, cowcatcher, and directional travel orientation.

var active_track: PackedVector2Array = PackedVector2Array()
var train_distance: float = 0.0
var train_direction: float = 1.0

func update_train(track: PackedVector2Array, distance: float, direction: float) -> void:
	active_track = track
	train_distance = distance
	train_direction = direction
	queue_redraw()

func _draw() -> void:
	if active_track.size() < 2:
		return
	
	var total_len: float = _path_length(active_track)
	if total_len <= 0.0:
		return
	
	# Consist configuration:
	# Car 0: Locomotive (length: LOCOMOTIVE_LENGTH)
	# Car 1: Coach 1 (length: COACH_LENGTH)
	# Car 2: Coach 2 (length: COACH_LENGTH)
	var loco_len: float = GameConfig.LOCOMOTIVE_LENGTH
	var coach_len: float = GameConfig.COACH_LENGTH
	var gap: float = GameConfig.COUPLER_GAP
	
	# Determine distance along the route for each car based on direction
	var d_loco: float = train_distance
	var d_coach1: float
	var d_coach2: float
	
	if train_direction >= 0.0:
		# Moving forward (Asha Nagar -> Nadi Gaon): Loco is in front, coaches follow behind
		d_coach1 = clampf(d_loco - (loco_len * 0.5 + gap + coach_len * 0.5), 0.0, total_len)
		d_coach2 = clampf(d_coach1 - (coach_len + gap), 0.0, total_len)
	else:
		# Shuttling in reverse (Nadi Gaon -> Asha Nagar):
		# Locomotive faces and leads the return journey
		d_coach1 = clampf(d_loco + (loco_len * 0.5 + gap + coach_len * 0.5), 0.0, total_len)
		d_coach2 = clampf(d_coach1 + (coach_len + gap), 0.0, total_len)
	
	# Draw Cars from rear to front so locomotive and front details layer cleanly
	# 1. Coach 2
	if d_coach2 >= 0.0 and d_coach2 <= total_len:
		var pos: Vector2 = _point_on_path(active_track, d_coach2)
		var ang: float = _angle_on_path(active_track, d_coach2)
		var facing: float = ang if train_direction >= 0.0 else ang + PI
		_draw_passenger_coach(pos, facing, 2)
	
	# 2. Coach 1
	if d_coach1 >= 0.0 and d_coach1 <= total_len:
		var pos: Vector2 = _point_on_path(active_track, d_coach1)
		var ang: float = _angle_on_path(active_track, d_coach1)
		var facing: float = ang if train_direction >= 0.0 else ang + PI
		_draw_passenger_coach(pos, facing, 1)
	
	# 3. Locomotive (Leader)
	if d_loco >= 0.0 and d_loco <= total_len:
		var pos: Vector2 = _point_on_path(active_track, d_loco)
		var ang: float = _angle_on_path(active_track, d_loco)
		var facing: float = ang if train_direction >= 0.0 else ang + PI
		_draw_locomotive(pos, facing)

func _draw_locomotive(pos: Vector2, angle: float) -> void:
	draw_set_transform(pos, angle, Vector2.ONE)
	
	var half_l: float = GameConfig.LOCOMOTIVE_LENGTH * 0.5
	var half_w: float = GameConfig.LOCOMOTIVE_WIDTH * 0.5
	
	# 1. Ground Drop Shadow
	draw_rect(Rect2(Vector2(-half_l + 2, -half_w + 3), Vector2(half_l * 2, half_w * 2)), GameConfig.COLOR_TRAIN_SHADOW, true)
	
	# 2. Front Headlight Light Beam Cone (projects ahead of the locomotive)
	var light_pts: PackedVector2Array = PackedVector2Array([
		Vector2(half_l, 0),
		Vector2(half_l + 130.0, -42.0),
		Vector2(half_l + 130.0, 42.0)
	])
	draw_colored_polygon(light_pts, Color(1.0, 0.98, 0.75, 0.18))
	
	# 3. Undercarriage Bogies & Steel Wheels
	draw_circle(Vector2(-half_l + 14, half_w + 1), 4.5, Color("#26292b"))
	draw_circle(Vector2(-half_l + 26, half_w + 1), 4.5, Color("#26292b"))
	draw_circle(Vector2(half_l - 26, half_w + 1), 4.5, Color("#26292b"))
	draw_circle(Vector2(half_l - 14, half_w + 1), 4.5, Color("#26292b"))
	
	# 4. Main Locomotive Body (Indian Railways Deep Royal Blue)
	draw_rect(Rect2(Vector2(-half_l, -half_w), Vector2(half_l * 2, half_w * 2)), GameConfig.COLOR_LOCO_BODY, true)
	
	# 5. Roof Fairing & Pantograph / Dynamic Brake Equipment
	draw_rect(Rect2(Vector2(-half_l + 8, -half_w + 3), Vector2(half_l * 2 - 16, half_w * 2 - 6)), GameConfig.COLOR_LOCO_ROOF, true)
	# Pantograph diamond / roof grid
	draw_line(Vector2(-12, -4), Vector2(0, 0), Color("#d4d9de"), 2.0)
	draw_line(Vector2(12, -4), Vector2(0, 0), Color("#d4d9de"), 2.0)
	draw_line(Vector2(-16, -4), Vector2(16, -4), Color("#d4d9de"), 2.2)
	
	# 6. Vibrant Indian Railways Yellow / Cream Speed Stripe
	draw_rect(Rect2(Vector2(-half_l, -3), Vector2(half_l * 2, 6)), GameConfig.COLOR_LOCO_STRIPE, true)
	
	# 7. Aerodynamic Cab Nose & Windscreens (Front is +X)
	# Twin front windscreens
	draw_rect(Rect2(Vector2(half_l - 16, -half_w + 3), Vector2(9, 8)), GameConfig.COLOR_LOCO_CAB_WINDOW, true)
	draw_rect(Rect2(Vector2(half_l - 16, half_w - 11), Vector2(9, 8)), GameConfig.COLOR_LOCO_CAB_WINDOW, true)
	# Center cab divider
	draw_line(Vector2(half_l - 16, 0), Vector2(half_l - 7, 0), Color("#132a42"), 2.0)
	
	# 8. Front Headlamp Fixture & Cowcatcher
	# Headlamp
	draw_circle(Vector2(half_l, 0), 4.0, GameConfig.COLOR_LOCO_HEADLIGHT)
	draw_circle(Vector2(half_l, 0), 2.0, Color("#ffffff"))
	# Front buffers & cowcatcher (cattle guard)
	draw_line(Vector2(half_l, -half_w + 3), Vector2(half_l + 5, -half_w + 3), Color("#303438"), 3.0)
	draw_line(Vector2(half_l, half_w - 3), Vector2(half_l + 5, half_w - 3), Color("#303438"), 3.0)
	draw_line(Vector2(half_l - 2, half_w - 1), Vector2(half_l + 6, 0), Color("#e8412b"), 2.5) # Cowcatcher red accent
	draw_line(Vector2(half_l - 2, -half_w + 1), Vector2(half_l + 6, 0), Color("#e8412b"), 2.5)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_passenger_coach(pos: Vector2, angle: float, coach_num: int) -> void:
	draw_set_transform(pos, angle, Vector2.ONE)
	
	var half_l: float = GameConfig.COACH_LENGTH * 0.5
	var half_w: float = GameConfig.COACH_WIDTH * 0.5
	
	# 1. Ground Drop Shadow
	draw_rect(Rect2(Vector2(-half_l + 2, -half_w + 3), Vector2(half_l * 2, half_w * 2)), GameConfig.COLOR_TRAIN_SHADOW, true)
	
	# 2. Wheel Bogies (Front and Rear 2-axle bogies)
	draw_circle(Vector2(-half_l + 12, half_w + 1), 4.0, Color("#26292b"))
	draw_circle(Vector2(-half_l + 24, half_w + 1), 4.0, Color("#26292b"))
	draw_circle(Vector2(half_l - 24, half_w + 1), 4.0, Color("#26292b"))
	draw_circle(Vector2(half_l - 12, half_w + 1), 4.0, Color("#26292b"))
	
	# 3. Coach Body (Classic ICF Navy Blue)
	draw_rect(Rect2(Vector2(-half_l, -half_w), Vector2(half_l * 2, half_w * 2)), GameConfig.COLOR_COACH_BODY, true)
	
	# 4. White / Light Grey Roof with corrugated ventilation ribs
	draw_rect(Rect2(Vector2(-half_l + 4, -half_w + 3), Vector2(half_l * 2 - 8, half_w * 2 - 6)), GameConfig.COLOR_COACH_ROOF, true)
	for r in range(-3, 4):
		var rx: float = float(r) * 9.0
		draw_line(Vector2(rx, -half_w + 4), Vector2(rx, half_w - 4), Color(0.6, 0.65, 0.7, 0.5), 1.5)
	
	# 5. Dual Cream Window Band Cheatlines
	draw_rect(Rect2(Vector2(-half_l, -half_w + 1), Vector2(half_l * 2, 2.5)), GameConfig.COLOR_COACH_STRIPE, true)
	draw_rect(Rect2(Vector2(-half_l, half_w - 3.5), Vector2(half_l * 2, 2.5)), GameConfig.COLOR_COACH_STRIPE, true)
	
	# 6. Passenger Windows with glass shine
	var num_windows: int = 5
	for w in range(num_windows):
		var wx: float = -half_l + 12.0 + float(w) * 11.5
		# North-side windows
		draw_rect(Rect2(Vector2(wx, -half_w + 2), Vector2(8, 5)), Color("#86d2e0"), true)
		draw_rect(Rect2(Vector2(wx, -half_w + 2), Vector2(8, 5)), Color("#16324d"), false, 1.0)
		# South-side windows
		draw_rect(Rect2(Vector2(wx, half_w - 7), Vector2(8, 5)), Color("#86d2e0"), true)
		draw_rect(Rect2(Vector2(wx, half_w - 7), Vector2(8, 5)), Color("#16324d"), false, 1.0)
	
	# 7. Passenger Doors at Coach Ends
	draw_rect(Rect2(Vector2(-half_l + 2, -half_w), Vector2(5, half_w * 2)), Color("#183d63"), true)
	draw_rect(Rect2(Vector2(half_l - 7, -half_w), Vector2(5, half_w * 2)), Color("#183d63"), true)
	
	# 8. Inter-Coach Vestibule / Gangway Accordion Connection
	draw_rect(Rect2(Vector2(-half_l - 3, -4), Vector2(3, 8)), Color("#1c1c1c"), true)
	draw_rect(Rect2(Vector2(half_l, -4), Vector2(3, 8)), Color("#1c1c1c"), true)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

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
		var seg_len: float = path[i].distance_to(path[i + 1])
		if remaining <= seg_len:
			if seg_len <= 0.001:
				return path[i]
			return path[i].lerp(path[i + 1], remaining / seg_len)
		remaining -= seg_len
	return path[path.size() - 1]

func _angle_on_path(path: PackedVector2Array, distance: float) -> float:
	if path.size() < 2:
		return 0.0
	var remaining: float = max(0.0, distance)
	for i in range(path.size() - 1):
		var seg: Vector2 = path[i + 1] - path[i]
		var seg_len: float = seg.length()
		if remaining <= seg_len:
			return seg.angle()
		remaining -= seg_len
	return (path[path.size() - 1] - path[path.size() - 2]).angle()
