class_name TrackRenderer
extends Node2D

## TrackRenderer
## Renders commercial-grade 2D railway tracks: textured ballast bed, individual sleepers,
## double steel rails with metallic highlights, automated bridge structures (concrete piers,
## red oxide steel girders, safety walkways) over rivers, and an exact build-mode preview.

var tracks: Array[PackedVector2Array] = []
var build_mode: bool = false
var route_points: PackedVector2Array = PackedVector2Array()

# Reference to the river path for water crossing detection
var river_path: PackedVector2Array = PackedVector2Array([
	Vector2(1020, -30), Vector2(990, 160), Vector2(1080, 310),
	Vector2(1240, 435), Vector2(1190, 575), Vector2(1300, 720),
	Vector2(1250, 875), Vector2(1385, 1040), Vector2(1320, 1220), Vector2(1430, 1630)
])

func update_tracks(new_tracks: Array[PackedVector2Array]) -> void:
	tracks = new_tracks
	queue_redraw()

func update_build_preview(in_build_mode: bool, points: PackedVector2Array) -> void:
	build_mode = in_build_mode
	route_points = points
	queue_redraw()

func _draw() -> void:
	for path in tracks:
		_draw_track_path(path)
	
	if build_mode:
		_draw_build_preview()

func _draw_track_path(path: PackedVector2Array) -> void:
	if path.size() < 2:
		return
	
	# Pass 1: Ground Ballast Bed (only for land segments)
	_draw_ballast_pass(path)
	
	# Pass 2: Bridges (piers, abutments, steel girder deck over water)
	_draw_bridge_pass(path)
	
	# Pass 3: Sleepers / Ties (land sleepers and bridge ties)
	_draw_sleepers_pass(path)
	
	# Pass 4: Continuous Twin Steel Rails (base flange, rail head, metallic specular)
	_draw_rails_pass(path)

func _draw_ballast_pass(path: PackedVector2Array) -> void:
	for i in range(path.size() - 1):
		var a: Vector2 = path[i]
		var b: Vector2 = path[i + 1]
		var mid: Vector2 = (a + b) * 0.5
		
		# Skip ballast if segment is over the river (bridge replaces ballast)
		if _is_over_water(mid):
			continue
		
		# Soft ballast ground shadow
		draw_line(a + Vector2(2, 3), b + Vector2(2, 3), GameConfig.COLOR_BALLAST_SHADOW, GameConfig.BALLAST_WIDTH + 4.0)
		# Beveled ballast edges
		draw_line(a, b, GameConfig.COLOR_BALLAST_EDGE, GameConfig.BALLAST_WIDTH)
		# Main gravel ballast bed
		draw_line(a, b, GameConfig.COLOR_BALLAST_BASE, GameConfig.BALLAST_WIDTH - 5.0)

func _draw_bridge_pass(path: PackedVector2Array) -> void:
	# Identify consecutive bridge segments
	var bridge_segments: Array[Dictionary] = []
	for i in range(path.size() - 1):
		var a: Vector2 = path[i]
		var b: Vector2 = path[i + 1]
		if _is_over_water(a) or _is_over_water(b):
			bridge_segments.append({"a": a, "b": b, "idx": i})
	
	if bridge_segments.is_empty():
		return
	
	# 1. Concrete Bridge Piers standing in the water
	var pier_interval: int = max(1, bridge_segments.size() / 3)
	for seg_idx in range(0, bridge_segments.size(), pier_interval):
		var pt: Vector2 = bridge_segments[seg_idx]["a"]
		# Only draw pier if deeply over water
		if _distance_to_river(pt) < 55.0:
			# Pier shadow on water
			draw_circle(pt + Vector2(4, 18), 14.0, Color(0.1, 0.2, 0.25, 0.45))
			# Pier column (concrete structure in river)
			draw_rect(Rect2(pt + Vector2(-9, 4), Vector2(18, 26)), GameConfig.COLOR_BRIDGE_PIER_DARK, true)
			draw_rect(Rect2(pt + Vector2(-8, 3), Vector2(16, 24)), GameConfig.COLOR_BRIDGE_PIER, true)
			# Pier cap
			draw_rect(Rect2(pt + Vector2(-12, 0), Vector2(24, 6)), Color("#b0a89b"), true)
	
	# 2. Heavy Steel Girder Beams & Safety Walkways
	for seg in bridge_segments:
		var a: Vector2 = seg["a"]
		var b: Vector2 = seg["b"]
		var dir: Vector2 = (b - a).normalized()
		var norm: Vector2 = Vector2(-dir.y, dir.x)
		
		# Steel bridge deck base shadow
		draw_line(a + Vector2(2, 4), b + Vector2(2, 4), Color(0.08, 0.12, 0.15, 0.4), 26.0)
		
		# Twin Red Oxide Steel Deck Girders
		var left_girder_a: Vector2 = a + norm * 12.0
		var left_girder_b: Vector2 = b + norm * 12.0
		var right_girder_a: Vector2 = a - norm * 12.0
		var right_girder_b: Vector2 = b - norm * 12.0
		
		# Main girder beams
		draw_line(left_girder_a, left_girder_b, GameConfig.COLOR_BRIDGE_GIRDER, 4.5)
		draw_line(right_girder_a, right_girder_b, GameConfig.COLOR_BRIDGE_GIRDER, 4.5)
		draw_line(left_girder_a, left_girder_b, GameConfig.COLOR_BRIDGE_GIRDER_DARK, 1.8)
		draw_line(right_girder_a, right_girder_b, GameConfig.COLOR_BRIDGE_GIRDER_DARK, 1.8)
		
		# Top safety handrails
		var left_rail_a: Vector2 = a + norm * 14.5
		var left_rail_b: Vector2 = b + norm * 14.5
		var right_rail_a: Vector2 = a - norm * 14.5
		var right_rail_b: Vector2 = b - norm * 14.5
		draw_line(left_rail_a, left_rail_b, Color("#d66858"), 1.6)
		draw_line(right_rail_a, right_rail_b, Color("#d66858"), 1.6)

func _draw_sleepers_pass(path: PackedVector2Array) -> void:
	for i in range(path.size() - 1):
		var a: Vector2 = path[i]
		var b: Vector2 = path[i + 1]
		var seg_vec: Vector2 = b - a
		var seg_len: float = seg_vec.length()
		if seg_len < 0.1:
			continue
		
		var normal: Vector2 = Vector2(-seg_vec.y, seg_vec.x).normalized()
		var is_bridge: bool = _is_over_water((a + b) * 0.5)
		
		var spacing: float = 8.0 if is_bridge else GameConfig.SLEEPER_SPACING
		var num_sleepers: int = max(1, int(seg_len / spacing))
		
		for s in range(num_sleepers + 1):
			var p: Vector2 = a.lerp(b, float(s) / float(num_sleepers))
			
			if is_bridge:
				# Open deck bridge timber tie (dark creosote timber)
				var half_w: float = 11.0
				draw_line(p - normal * half_w, p + normal * half_w, GameConfig.COLOR_BRIDGE_TIE, 3.8)
			else:
				# Standard concrete/timber railway sleeper
				var half_w: float = GameConfig.SLEEPER_LENGTH * 0.5
				# Sleeper drop shadow
				draw_line(p - normal * half_w + Vector2(1, 1.5), p + normal * half_w + Vector2(1, 1.5), Color(0.15, 0.12, 0.1, 0.35), GameConfig.SLEEPER_WIDTH)
				# Concrete sleeper body
				draw_line(p - normal * half_w, p + normal * half_w, GameConfig.COLOR_SLEEPER_CONCRETE, GameConfig.SLEEPER_WIDTH)
				# Fastener tie-plates (steel clips securing the rails)
				var rail_dist: float = GameConfig.TRACK_GAUGE * 0.5
				draw_circle(p - normal * rail_dist, 1.8, Color("#423d38"))
				draw_circle(p + normal * rail_dist, 1.8, Color("#423d38"))

func _draw_rails_pass(path: PackedVector2Array) -> void:
	var rail_offset: float = GameConfig.TRACK_GAUGE * 0.5
	
	for i in range(path.size() - 1):
		var a: Vector2 = path[i]
		var b: Vector2 = path[i + 1]
		var seg_vec: Vector2 = b - a
		if seg_vec.length() < 0.1:
			continue
		var normal: Vector2 = Vector2(-seg_vec.y, seg_vec.x).normalized()
		
		var left_a: Vector2 = a + normal * rail_offset
		var left_b: Vector2 = b + normal * rail_offset
		var right_a: Vector2 = a - normal * rail_offset
		var right_b: Vector2 = b - normal * rail_offset
		
		# 1. Base Rail Flange (dark steel shadow under rail)
		draw_line(left_a, left_b, GameConfig.COLOR_RAIL_BASE, GameConfig.RAIL_WIDTH + 1.2)
		draw_line(right_a, right_b, GameConfig.COLOR_RAIL_BASE, GameConfig.RAIL_WIDTH + 1.2)
		
		# 2. Rail Head (polished steel)
		draw_line(left_a, left_b, GameConfig.COLOR_RAIL_HEAD, GameConfig.RAIL_WIDTH)
		draw_line(right_a, right_b, GameConfig.COLOR_RAIL_HEAD, GameConfig.RAIL_WIDTH)
		
		# 3. Metallic Specular Running Surface (top shiny reflection)
		draw_line(left_a, left_b, GameConfig.COLOR_RAIL_SPECULAR, 0.8)
		draw_line(right_a, right_b, GameConfig.COLOR_RAIL_SPECULAR, 0.8)

func _draw_build_preview() -> void:
	var raw_preview: PackedVector2Array = route_points.duplicate()
	raw_preview.append(GameConfig.STATION_B_POS)
	var preview: PackedVector2Array = _smooth_path(raw_preview)
	
	if preview.size() >= 2:
		# Glowing route corridor
		draw_polyline(preview, Color(0.12, 0.18, 0.22, 0.35), 24.0, true)
		# Track bed preview
		draw_polyline(preview, Color(0.96, 0.82, 0.42, 0.75), 14.0, true)
		# High-visibility dashed golden centerline
		draw_polyline(preview, Color("#fff4a3"), 5.0, true)
		
		# Indicate bridge span in preview if crossing river
		for i in range(preview.size() - 1):
			var mid: Vector2 = (preview[i] + preview[i + 1]) * 0.5
			if _is_over_water(mid):
				draw_line(preview[i], preview[i + 1], Color("#e85b48"), 10.0)
	
	# Waypoint pins
	for idx in range(route_points.size()):
		var pt: Vector2 = route_points[idx]
		# Outer glow
		draw_circle(pt, 12.0, Color(1.0, 0.9, 0.5, 0.4))
		# Pin body
		draw_circle(pt, 8.0, Color("#fff5b8"))
		draw_circle(pt, 5.0, Color("#d99f2b"))
		draw_circle(pt, 2.0, Color("#ffffff"))
	
	# Terminus target marker at Station B
	draw_circle(GameConfig.STATION_B_POS, 14.0, Color(0.4, 0.7, 1.0, 0.4))
	draw_circle(GameConfig.STATION_B_POS, 8.0, Color("#8ac4ff"))
	draw_circle(GameConfig.STATION_B_POS, 4.0, Color("#ffffff"))

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

func _is_over_water(p: Vector2) -> bool:
	return _distance_to_river(p) < 64.0

func _distance_to_river(p: Vector2) -> float:
	var min_d: float = 99999.0
	for i in range(river_path.size() - 1):
		var a: Vector2 = river_path[i]
		var b: Vector2 = river_path[i + 1]
		var d: float = _dist_to_segment(p, a, b)
		if d < min_d:
			min_d = d
	return min_d

func _dist_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab: Vector2 = b - a
	var ab_len_sq: float = ab.length_squared()
	if ab_len_sq <= 0.001:
		return p.distance_to(a)
	var t: float = clampf((p - a).dot(ab) / ab_len_sq, 0.0, 1.0)
	var proj: Vector2 = a + ab * t
	return p.distance_to(proj)
