class_name HUDController
extends CanvasLayer

signal build_pressed
signal finish_pressed
signal cancel_pressed
signal reset_view_pressed

@onready var coins_label: Label = $Root/TopPanel/TopRow/CoinsLabel
@onready var status_label: Label = $Root/StatusPanel/StatusLabel
@onready var build_info_panel: PanelContainer = $Root/BuildInfoPanel
@onready var build_info_label: Label = $Root/BuildInfoPanel/BuildInfoLabel
@onready var build_button: Button = $Root/BottomPanel/BottomRow/BuildButton
@onready var finish_button: Button = $Root/BottomPanel/BottomRow/FinishButton
@onready var cancel_button: Button = $Root/BottomPanel/BottomRow/CancelButton
@onready var reset_button: Button = $Root/BottomPanel/BottomRow/ResetButton

func _ready() -> void:
	build_button.pressed.connect(func(): build_pressed.emit())
	finish_button.pressed.connect(func(): finish_pressed.emit())
	cancel_button.pressed.connect(func(): cancel_pressed.emit())
	reset_button.pressed.connect(func(): reset_view_pressed.emit())
	
	if is_instance_valid(build_info_panel):
		build_info_panel.visible = false

func update_coins(amount: int) -> void:
	if is_instance_valid(coins_label):
		coins_label.text = "🪙  %s coins" % _format_number(amount)

func set_build_mode(in_build_mode: bool, has_route: bool) -> void:
	if is_instance_valid(build_button):
		build_button.disabled = in_build_mode or has_route
	if is_instance_valid(finish_button):
		finish_button.disabled = not in_build_mode
	if is_instance_valid(cancel_button):
		cancel_button.disabled = not in_build_mode
	if is_instance_valid(build_info_panel):
		build_info_panel.visible = in_build_mode

func update_build_cost(estimated_cost: int, available_coins: int, waypoints: int) -> void:
	if not is_instance_valid(build_info_label) or not is_instance_valid(build_info_panel):
		return
	build_info_panel.visible = true
	var affordable: bool = estimated_cost <= available_coins
	var color_tag: String = "✓" if affordable else "⚠"
	build_info_label.text = "TRACK PLANNING | %d/9 Bends | Cost: %s coins %s" % [
		waypoints,
		_format_number(estimated_cost),
		color_tag
	]
	if affordable:
		build_info_label.modulate = Color("#ffeb99")
	else:
		build_info_label.modulate = Color("#ff8878")

func set_status(message: String) -> void:
	if is_instance_valid(status_label):
		status_label.text = message

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
