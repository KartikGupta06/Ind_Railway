class_name StationRenderer
extends Node2D

## StationRenderer
## Renders authentic Indian railway station environments (Asha Nagar & Nadi Gaon):
## realistic paved platforms with yellow safety line, iconic mustard-yellow Indian Railways
## bilingual station signboards, starter station master offices with terracotta roofs,
## platform lamps, and clearly designated expansion zones for future upgrades.

func _draw() -> void:
	_draw_station(
		GameConfig.STATION_A_POS,
		GameConfig.STATION_A_NAME,
		GameConfig.STATION_A_NAME_HINDI,
		GameConfig.STATION_A_COLOR,
		true
	)
	
	_draw_station(
		GameConfig.STATION_B_POS,
		GameConfig.STATION_B_NAME,
		GameConfig.STATION_B_NAME_HINDI,
		GameConfig.STATION_B_COLOR,
		false
	)

func _draw_station(pos: Vector2, station_name: String, hindi_name: String, accent_color: Color, is_origin: bool) -> void:
	# Platform geometry relative to station track anchor
	# The track runs horizontally past the station at pos.y
	# Platform sits just north of the track: y in [pos.y - 48, pos.y - 12]
	var plat_width: float = 260.0
	var plat_height: float = 38.0
	var plat_rect: Rect2 = Rect2(pos + Vector2(-plat_width * 0.5, -46.0), Vector2(plat_width, plat_height))
	
	# 1. Platform Ground Shadow cast onto ballast/earth
	draw_rect(Rect2(plat_rect.position + Vector2(2, 4), plat_rect.size), Color(0.12, 0.15, 0.12, 0.28), true)
	
	# 2. Main Platform Paved Slab
	draw_rect(plat_rect, GameConfig.COLOR_PLATFORM_SURFACE, true)
	# Platform border stone edging
	draw_rect(plat_rect, GameConfig.COLOR_PLATFORM_CURB, false, 2.0)
	
	# Platform tactile paving pavers pattern (subtle lines)
	for i in range(1, 9):
		var px: float = plat_rect.position.x + float(i) * (plat_width / 9.0)
		draw_line(Vector2(px, plat_rect.position.y + 2), Vector2(px, plat_rect.position.y + plat_height - 2), Color(0.78, 0.75, 0.68, 0.5), 1.0)
	
	# 3. Yellow Safety Warning Line (Mandatory Indian Railways safety strip)
	var safety_y: float = plat_rect.position.y + plat_height - 4.5
	draw_line(
		Vector2(plat_rect.position.x + 4.0, safety_y),
		Vector2(plat_rect.position.x + plat_width - 4.0, safety_y),
		GameConfig.COLOR_PLATFORM_EDGE,
		3.0
	)
	
	# 4. Starter Station Master Office (Minimal starter building, positioned north of platform)
	var bldg_pos: Vector2 = pos + Vector2(-75.0, -96.0)
	var bldg_size: Vector2 = Vector2(70.0, 46.0)
	# Building shadow
	draw_rect(Rect2(bldg_pos + Vector2(4, 4), bldg_size), Color(0.1, 0.12, 0.1, 0.3), true)
	# Walls
	draw_rect(Rect2(bldg_pos, bldg_size), GameConfig.COLOR_BUILDING_WALL, true)
	draw_rect(Rect2(bldg_pos, bldg_size), accent_color.darkened(0.2), false, 2.0)
	# Terracotta hip roof
	var roof_pts: PackedVector2Array = PackedVector2Array([
		bldg_pos + Vector2(-6, 0),
		bldg_pos + Vector2(bldg_size.x * 0.5, -16),
		bldg_pos + Vector2(bldg_size.x + 6, 0)
	])
	draw_colored_polygon(roof_pts, GameConfig.COLOR_BUILDING_ROOF)
	draw_polyline(roof_pts, GameConfig.COLOR_BUILDING_ROOF.darkened(0.25), 2.0)
	# Doorway & ticket window
	draw_rect(Rect2(bldg_pos + Vector2(10, 16), Vector2(16, 30)), Color("#4a3625"), true)
	draw_rect(Rect2(bldg_pos + Vector2(38, 14), Vector2(18, 16)), Color("#7fc8db"), true) # Ticket counter window
	draw_rect(Rect2(bldg_pos + Vector2(38, 14), Vector2(18, 16)), Color("#3b291a"), false, 1.5)
	
	# Station Master name plaque over door
	draw_rect(Rect2(bldg_pos + Vector2(8, 6), Vector2(20, 6)), Color("#fff2c4"), true)
	
	# 5. Iconic Indian Railways Mustard-Yellow Station Signboard
	var board_pos: Vector2 = pos + Vector2(25.0, -108.0)
	var board_w: float = 145.0
	var board_h: float = 46.0
	
	# Two sturdy black signboard posts
	draw_line(board_pos + Vector2(20, board_h), board_pos + Vector2(20, board_h + 36), Color("#222222"), 4.0)
	draw_line(board_pos + Vector2(board_w - 20, board_h), board_pos + Vector2(board_w - 20, board_h + 36), Color("#222222"), 4.0)
	
	# Board shadow
	draw_rect(Rect2(board_pos + Vector2(3, 4), Vector2(board_w, board_h)), Color(0.1, 0.12, 0.1, 0.3), true)
	# Mustard Yellow Face
	draw_rect(Rect2(board_pos, Vector2(board_w, board_h)), GameConfig.COLOR_STATION_BOARD_BG, true)
	# Bold Black Border
	draw_rect(Rect2(board_pos, Vector2(board_w, board_h)), GameConfig.COLOR_STATION_BOARD_BORDER, false, 3.0)
	
	# Dual language typography: Devanagari Hindi on top, English below
	draw_string(ThemeDB.fallback_font, board_pos + Vector2(8, 20), hindi_name, HORIZONTAL_ALIGNMENT_CENTER, board_w - 16, 15, GameConfig.COLOR_STATION_BOARD_TEXT)
	draw_string(ThemeDB.fallback_font, board_pos + Vector2(8, 38), station_name, HORIZONTAL_ALIGNMENT_CENTER, board_w - 16, 14, GameConfig.COLOR_STATION_BOARD_TEXT)
	
	# 6. Platform Infrastructure Details
	# Platform vintage lampposts with warm glow
	var lamp_left: Vector2 = plat_rect.position + Vector2(16, 8)
	var lamp_right: Vector2 = plat_rect.position + Vector2(plat_width - 16, 8)
	_draw_platform_lamp(lamp_left)
	_draw_platform_lamp(lamp_right)
	
	# Traditional Indian Railways Drinking Water Stand ("WATER / जल")
	var water_pos: Vector2 = plat_rect.position + Vector2(100, 10)
	draw_rect(Rect2(water_pos, Vector2(16, 14)), Color("#3b78a3"), true)
	draw_rect(Rect2(water_pos + Vector2(2, -4), Vector2(12, 4)), Color("#ded8c7"), true)
	draw_circle(water_pos + Vector2(8, -6), 3.0, Color("#d4d4d4"))
	
	# Vintage Platform Clock on Post
	var clock_pos: Vector2 = bldg_pos + Vector2(bldg_size.x + 12, 10)
	draw_line(clock_pos, clock_pos + Vector2(0, 18), Color("#2b2b2b"), 2.5)
	draw_circle(clock_pos, 7.5, Color("#ffffff"))
	draw_circle(clock_pos, 7.5, Color("#1a1a1a"), false, 1.8)
	draw_line(clock_pos, clock_pos + Vector2(0, -4), Color("#1a1a1a"), 1.5)
	draw_line(clock_pos, clock_pos + Vector2(3, 1), Color("#1a1a1a"), 1.5)
	
	# 7. Reserved Future Expansion Zone Marker
	# Visual indication of progressive building slots (chai stall, shed, foot overbridge)
	var expansion_pos: Vector2 = plat_rect.position + Vector2(plat_width + 12, 4)
	draw_rect(Rect2(expansion_pos, Vector2(65, 32)), Color(0.2, 0.3, 0.2, 0.12), true)
	draw_rect(Rect2(expansion_pos, Vector2(65, 32)), Color("#9ca890"), false, 1.5)
	draw_string(ThemeDB.fallback_font, expansion_pos + Vector2(4, 20), "+ EXPANSION", HORIZONTAL_ALIGNMENT_CENTER, 57, 10, Color(0.3, 0.45, 0.35, 0.7))

func _draw_platform_lamp(p: Vector2) -> void:
	# Cast iron post
	draw_line(p, p + Vector2(0, -22), Color("#262626"), 2.5)
	# Cross bracket
	draw_line(p + Vector2(-4, -22), p + Vector2(4, -22), Color("#262626"), 2.0)
	# Lamp housing
	draw_circle(p + Vector2(0, -22), 4.5, Color("#ffea88"))
	# Soft warm glow on platform surface
	draw_circle(p + Vector2(0, 2), 12.0, Color(1.0, 0.95, 0.65, 0.22))
