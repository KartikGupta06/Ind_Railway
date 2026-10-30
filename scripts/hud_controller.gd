class_name HUDController
extends CanvasLayer

signal build_pressed
signal finish_pressed
signal cancel_pressed
signal reset_view_pressed

@onready var coins_label: Label = $Root/TopPanel/TopRow/CoinsLabel
@onready var status_label: Label = $Root/StatusPanel/StatusLabel
@onready var build_button: Button = $Root/BottomPanel/BottomRow/BuildButton
@onready var finish_button: Button = $Root/BottomPanel/BottomRow/FinishButton
@onready var cancel_button: Button = $Root/BottomPanel/BottomRow/CancelButton
@onready var reset_button: Button = $Root/BottomPanel/BottomRow/ResetButton

func _ready() -> void:
	build_button.pressed.connect(func(): build_pressed.emit())
	finish_button.pressed.connect(func(): finish_pressed.emit())
	cancel_button.pressed.connect(func(): cancel_pressed.emit())
	reset_button.pressed.connect(func(): reset_view_pressed.emit())

func update_coins(amount: int) -> void:
	if is_instance_valid(coins_label):
		coins_label.text = "%s coins" % _format_number(amount)

func set_build_mode(in_build_mode: bool, has_route: bool) -> void:
	if is_instance_valid(build_button):
		build_button.disabled = in_build_mode or has_route
	if is_instance_valid(finish_button):
		finish_button.disabled = not in_build_mode
	if is_instance_valid(cancel_button):
		cancel_button.disabled = not in_build_mode

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
