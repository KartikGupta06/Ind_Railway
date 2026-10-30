class_name WorldRenderer
extends Node2D

## WorldRenderer
## Draws a natural, living Indian landscape: organic patchwork fields, an animated river
## with banks and ripples, clustered banyan/mango/palm groves with wind sway,
## village settlements, and scenic hill ranges.

var anim_time: float = 0.0

# Pre-computed field definitions for organic, handcrafted appearance
var _fields: Array[Dictionary] = []
var _trees: Array[Dictionary] = []
var _cottages: Array[Dictionary] = []

# River geometry
var river_path: PackedVector2Array = PackedVector2Array([
	Vector2(1020, -30), Vector2(990, 160), Vector2(1080, 310),
	Vector2(1240, 435), Vector2(1190, 575), Vector2(1300, 720),
	Vector2(1250, 875), Vector2(1385, 1040), Vector2(1320, 1220), Vector2(1430, 1630)
])

func _ready() -> void:
	_init_world_data()

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()

func _init_world_data() -> void:
	# Generate organic, non-uniform agricultural parcels
	var field_styles = [
		{"base": Color("#d6b24e"), "stripe": Color("#c49f38"), "type": "mustard"},
		{"base": Color("#7fa950"), "stripe": Color("#6d943e"), "type": "paddy"},
		{"base": Color("#8ea65d"), "stripe": Color("#7a914c"), "type": "pasture"},
		{"base": Color("#937754"), "stripe": Color("#7d6342"), "type": "soil"},
		{"base": Color("#a2c26c"), "stripe": Color("#8dae57"), "type": "wheat"},
		{"base": Color("#b5cc78"), "stripe": Color("#9fb464"), "type": "meadow"}
	]
	
	# Layout fields across the world avoiding river corridor
	var rows: int = 7
	var cols: int = 12
	var col_w: float = GameConfig.WORLD_WIDTH / float(cols)
	var row_h: float = GameConfig.WORLD_HEIGHT / float(rows)
	
	for r in range(rows):
		for c in range(cols):
			var center_x: float = float(c) * col_w + col_w * 0.5
			# Skip area where river runs
			if center_x > 940.0 and center_x < 1460.0:
				continue
			var fx: float = float(c) * col_w + 14.0 + float((r * 17) % 25)
			var fy: float = float(r) * row_h + 16.0 + float((c * 23) % 20)
			var fw: float = col_w - 28.0 - float((r + c) % 15)
			var fh: float = row_h - 32.0 - float((r * 2) % 12)
			var style = field_styles[(r * 3 + c * 5) % field_styles.size()]
			_fields.append({
				"rect": Rect2(fx, fy, fw, fh),
				"style": style,
				"furrow_angle": float((r + c) % 3) * 0.35
			})
	
	# Generate clustered tree groves (Banyan, Mango, Palm)
	# 1. Banyan & Mango groves in western plains
	for i in range(45):
		var tx: float = 80.0 + fmod(float(i * 197), 850.0)
		var ty: float = 70.0 + fmod(float(i * 149), GameConfig.WORLD_HEIGHT - 140.0)
		if Vector2(tx, ty).distance_to(GameConfig.STATION_A_POS) > 175.0:
			var tree_type = "banyan" if (i % 3 == 0) else "mango"
			_trees.append({
				"pos": Vector2(tx, ty),
				"type": tree_type,
				"scale": 0.85 + float(i % 5) * 0.08,
				"phase": float(i) * 0.4
			})
	
	# 2. Palms and riverine trees along the riverbanks
	for i in range(35):
		var side: float = -1.0 if (i % 2 == 0) else 1.0
		var progress: float = float(i) / 35.0
		var base_pt: Vector2 = river_path[int(progress * float(river_path.size() - 2))]
		var offset: Vector2 = Vector2(side * (85.0 + float((i * 19) % 50)), float((i * 31) % 60) - 30.0)
		var t_pos: Vector2 = base_pt + offset
		_trees.append({
			"pos": t_pos,
			"type": "palm",
			"scale": 0.8 + float(i % 4) * 0.1,
			"phase": float(i) * 0.5
		})
	
	# 3. Eastern groves around Nadi Gaon
	for i in range(40):
		var tx: float = 1520.0 + fmod(float(i * 181), GameConfig.WORLD_WIDTH - 1620.0)
		var ty: float = 90.0 + fmod(float(i * 137), GameConfig.WORLD_HEIGHT - 160.0)
		if Vector2(tx, ty).distance_to(GameConfig.STATION_B_POS) > 175.0:
			var tree_type = "mango" if (i % 2 == 0) else "banyan"
			_trees.append({
				"pos": Vector2(tx, ty),
				"type": tree_type,
				"scale": 0.82 + float(i % 5) * 0.07,
				"phase": float(i) * 0.35
			})
	
	# Generate village cottage clusters
	# Settlement 1: Rampur village in NW
	for i in range(6):
		var cx: float = 240.0 + float(i % 3) * 65.0 + float((i / 3) * 18)
		var cy: float = 210.0 + float(i / 3) * 55.0
		_cottages.append({"pos": Vector2(cx, cy), "rot": float(i % 2) * 0.1})
	
	# Settlement 2: Nadi Gaon village outskirts in SE
	for i in range(7):
		var cx: float = 2150.0 + float(i % 4) * 60.0
		var cy: float = 980.0 + float(i / 4) * 58.0 + float((i % 2) * 12)
		_cottages.append({"pos": Vector2(cx, cy), "rot": float((i + 1) % 2) * -0.12})

func _draw() -> void:
	_draw_base_terrain()
	_draw_agricultural_fields()
	_draw_roads_and_paths()
	_draw_river_system()
	_draw_settlements()
	_draw_foliage()
	_draw_hills_and_labels()

func _draw_base_terrain() -> void:
	# Rich lush green ground foundation
	var world_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(GameConfig.WORLD_WIDTH, GameConfig.WORLD_HEIGHT))
	draw_rect(world_rect, Color("#9bc66e"), true)
	
	# Broad natural terrain color patches for varied elevation feel
	draw_circle(Vector2(500, 400), 450.0, Color(0.58, 0.76, 0.40, 0.35))
	draw_circle(Vector2(2100, 1100), 550.0, Color(0.55, 0.73, 0.38, 0.35))
	draw_circle(Vector2(2400, 300), 600.0, Color(0.62, 0.80, 0.45, 0.4))

func _draw_agricultural_fields() -> void:
	for f in _fields:
		var r: Rect2 = f["rect"]
		var style: Dictionary = f["style"]
		
		# Field bund shadow (earthen ridge around plot)
		draw_rect(Rect2(r.position + Vector2(2, 3), r.size), Color(0.2, 0.25, 0.15, 0.2), true)
		# Earthen boundary ridge
		draw_rect(Rect2(r.position - Vector2(2, 2), r.size + Vector2(4, 4)), Color("#877656"), true)
		# Field crop surface
		draw_rect(r, style["base"], true)
		
		# Crop furrows / textures
		var num_lines: int = 5
		for line_idx in range(1, num_lines):
			var ly: float = r.position.y + float(line_idx) * r.size.y / float(num_lines)
			draw_line(
				Vector2(r.position.x + 6.0, ly),
				Vector2(r.position.x + r.size.x - 6.0, ly),
				style["stripe"],
				2.0
			)

func _draw_roads_and_paths() -> void:
	# Primary dusty gravel roads
	var road_west: PackedVector2Array = PackedVector2Array([
		Vector2(40, 590), Vector2(240, 640), Vector2(470, 630), Vector2(690, 670), Vector2(880, 640)
	])
	var road_east: PackedVector2Array = PackedVector2Array([
		Vector2(1810, 850), Vector2(1980, 810), Vector2(2240, 860), Vector2(2520, 810), Vector2(2760, 840)
	])
	var village_path_nw: PackedVector2Array = PackedVector2Array([
		Vector2(320, 190), Vector2(360, 360), Vector2(450, 520), Vector2(470, 630)
	])
	
	# Soft road drop shadows
	draw_polyline(road_west, Color(0.2, 0.2, 0.15, 0.15), 24.0, true)
	draw_polyline(road_east, Color(0.2, 0.2, 0.15, 0.15), 24.0, true)
	
	# Road base (earthen gravel)
	draw_polyline(road_west, Color("#cfbe9b"), 19.0, true)
	draw_polyline(road_east, Color("#cfbe9b"), 19.0, true)
	draw_polyline(village_path_nw, Color("#d5c6a5"), 11.0, true)
	
	# Light center tracks (wheel ruts)
	draw_polyline(road_west, Color("#e6dac0"), 12.0, true)
	draw_polyline(road_east, Color("#e6dac0"), 12.0, true)
	draw_polyline(village_path_nw, Color("#ebe2ce"), 6.0, true)

func _draw_river_system() -> void:
	# Outer sandy riverbank strip
	draw_polyline(river_path, Color("#cfbf97"), 156.0, true)
	draw_polyline(river_path, Color("#b5a882"), 140.0, true)
	
	# River shallow waters
	draw_polyline(river_path, Color("#5ea8af"), 120.0, true)
	# River deep channel
	draw_polyline(river_path, Color("#3a838f"), 96.0, true)
	# River deep core
	draw_polyline(river_path, Color("#2c6c77"), 60.0, true)
	
	# Animated surface water wavelets and currents
	var wave_offset: float = fmod(anim_time * 35.0, 140.0)
	for i in range(river_path.size() - 1):
		var p1: Vector2 = river_path[i]
		var p2: Vector2 = river_path[i + 1]
		var seg_len: float = p1.distance_to(p2)
		var num_waves: int = max(1, int(seg_len / 45.0))
		
		for w in range(num_waves):
			var t: float = fmod(float(w) / float(num_waves) + (wave_offset / seg_len), 1.0)
			var wave_center: Vector2 = p1.lerp(p2, t)
			var tangent: Vector2 = (p2 - p1).normalized()
			var normal: Vector2 = Vector2(-tangent.y, tangent.x)
			
			# Specular water highlights
			var wave_w: float = 18.0 + sin(anim_time * 3.0 + float(w + i)) * 6.0
			var w_left: Vector2 = wave_center - tangent * wave_w * 0.5 + normal * sin(anim_time * 2.0 + float(w)) * 4.0
			var w_right: Vector2 = wave_center + tangent * wave_w * 0.5 + normal * sin(anim_time * 2.0 + float(w)) * 4.0
			draw_line(w_left, w_right, Color(0.75, 0.92, 0.95, 0.45), 2.2)

func _draw_settlements() -> void:
	for cottage in _cottages:
		var p: Vector2 = cottage["pos"]
		# Ground shadow
		draw_rect(Rect2(p + Vector2(-16, -10), Vector2(34, 26)), Color(0.12, 0.15, 0.12, 0.25), true)
		# Whitewashed mud walls
		draw_rect(Rect2(p + Vector2(-14, -8), Vector2(28, 20)), Color("#ede9dc"), true)
		draw_rect(Rect2(p + Vector2(-14, -8), Vector2(28, 20)), Color("#b5ae9b"), false, 1.5)
		# Terracotta clay tile roof (warm Indian village roof)
		var roof_pts: PackedVector2Array = PackedVector2Array([
			p + Vector2(-18, -8),
			p + Vector2(0, -22),
			p + Vector2(18, -8)
		])
		draw_colored_polygon(roof_pts, Color("#b84f37"))
		draw_polyline(roof_pts, Color("#8c3420"), 1.8)
		# Doorway
		draw_rect(Rect2(p + Vector2(-3, 2), Vector2(6, 10)), Color("#5c4632"), true)

func _draw_foliage() -> void:
	for tree in _trees:
		var p: Vector2 = tree["pos"]
		var s: float = tree["scale"]
		var type: String = tree["type"]
		var phase: float = tree["phase"]
		var sway_x: float = sin(anim_time * 2.2 + phase) * 2.0 * s
		
		# Ground drop shadow
		draw_circle(p + Vector2(4, 8), 12.0 * s, Color(0.12, 0.18, 0.1, 0.28))
		
		if type == "banyan":
			# Broad sturdy trunk
			draw_rect(Rect2(p + Vector2(-4, 0), Vector2(8, 16) * s), Color("#5c4633"), true)
			# Spreading multi-lobed canopy
			var crown_c: Vector2 = p + Vector2(sway_x, -10.0 * s)
			draw_circle(crown_c, 16.0 * s, Color("#265427"))
			draw_circle(crown_c + Vector2(-10, -4) * s, 12.0 * s, Color("#2d622e"))
			draw_circle(crown_c + Vector2(10, -5) * s, 12.0 * s, Color("#356e36"))
			draw_circle(crown_c + Vector2(0, -10) * s, 13.0 * s, Color("#427e43"))
			# Sunlit leaf highlight
			draw_circle(crown_c + Vector2(-3, -12) * s, 6.0 * s, Color("#60a15c"))
		elif type == "mango":
			# Slender brown trunk
			draw_rect(Rect2(p + Vector2(-3, 0), Vector2(6, 14) * s), Color("#694d38"), true)
			# Dense rounded crown
			var crown_c: Vector2 = p + Vector2(sway_x, -8.0 * s)
			draw_circle(crown_c, 14.0 * s, Color("#38682e"))
			draw_circle(crown_c + Vector2(-6, -6) * s, 10.0 * s, Color("#467a3a"))
			draw_circle(crown_c + Vector2(6, -5) * s, 10.0 * s, Color("#528944"))
			draw_circle(crown_c + Vector2(-2, -8) * s, 5.0 * s, Color("#73aa5f"))
		else: # Palm tree
			# Curved slender trunk
			var trunk_top: Vector2 = p + Vector2(sway_x * 1.5, -24.0 * s)
			draw_line(p + Vector2(0, 4), trunk_top, Color("#70563e"), 3.5 * s)
			# Radiating fronds
			for a in range(7):
				var angle: float = float(a) * (PI / 3.5) - PI * 0.85
				var frond_end: Vector2 = trunk_top + Vector2(cos(angle), sin(angle)) * 16.0 * s
				draw_line(trunk_top, frond_end, Color("#3d782c"), 2.2 * s)

func _draw_hills_and_labels() -> void:
	# North-East Sahyadri hill range
	for i in range(9):
		var hx: float = 1720.0 + float(i) * 115.0
		var hy: float = 85.0 + float((i * 47) % 110)
		var pts: PackedVector2Array = PackedVector2Array([
			Vector2(hx - 95, hy + 120), Vector2(hx - 30, hy + 15),
			Vector2(hx + 25, hy + 50), Vector2(hx + 75, hy - 15),
			Vector2(hx + 120, hy + 120)
		])
		draw_colored_polygon(pts, Color("#6d975a"))
		draw_polyline(pts, Color("#567b46"), 2.5)
		# Sunny ridge highlight
		draw_line(Vector2(hx - 30, hy + 15), Vector2(hx + 75, hy - 15), Color("#aed48f"), 3.0)
	
	# Atmospheric region labels with soft shadow
	var label_pos1: Vector2 = Vector2(280, 290)
	draw_string(ThemeDB.fallback_font, label_pos1 + Vector2(2, 2), "SAHYADRI VALLEY DIVISION", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.1, 0.2, 0.15, 0.35))
	draw_string(ThemeDB.fallback_font, label_pos1, "SAHYADRI VALLEY DIVISION", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.22, 0.40, 0.28, 0.85))
	
	var label_pos2: Vector2 = Vector2(1650, 1340)
	draw_string(ThemeDB.fallback_font, label_pos2 + Vector2(2, 2), "KONKAN EXPANSION SECTOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.1, 0.2, 0.15, 0.35))
	draw_string(ThemeDB.fallback_font, label_pos2, "KONKAN EXPANSION SECTOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.22, 0.40, 0.28, 0.80))
