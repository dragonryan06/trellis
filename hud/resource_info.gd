extends VBoxContainer

const TYPES: Array[String] = [
	"water",
	"ichor",
	"phosphor",
	"ambrose"
]
const COLORS: Array[Color] = [
	Color("blue"),
	Color("green"),
	Color("red"),
	Color("orange")
]
const UNITS: Array[String] = [
	"drams",
	"drams",
	"motes",
	"motes"
]

@onready
var player = get_node(GlobalLookups.player) as Player

func _ready() -> void:
	# Wait for container sizing to set in before going top level.
	await get_tree().process_frame
	$ResourceBank.top_level = true
	$ResourceBank.position.x = -$ResourceBank.size.x
	player.resources_changed.connect(_on_player_resources_changed)

func _fly_resource_bank_in(button_idx: int) -> void:
	var resource_bank = $ResourceBank
	
	var title = resource_bank.get_node(^"HBoxContainer/RightSide/VBoxContainer/Title")
	title.text = TYPES[button_idx].capitalize()
	title.modulate = COLORS[button_idx]
	var data = resource_bank.get_node(^"HBoxContainer/RightSide/VBoxContainer/Data")
	data.text = " Storing: %2d [color=gray]%s[/color]
 Intake: %3d [color=gray]%s/d[/color]" % [
		player.count_stored_resource(TYPES[button_idx]),
		UNITS[button_idx],
		0,
		UNITS[button_idx]
	]
	
	var viewport = resource_bank.get_node(^"HBoxContainer/LeftSide/SubViewportContainer/SubViewport")
	for child in viewport.get_children():
		if (child is not FallingSand):
			continue
		
		if (child.get_index() == button_idx):
			child.visible = true
		else:
			child.visible = false
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(resource_bank, ^"position:x", 0.0, 0.25)
	tween.tween_callback(func(): resource_bank.top_level = false)

func _fly_resource_bank_out() -> void:
	var resource_bank = $ResourceBank
	resource_bank.top_level = true
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(resource_bank, ^"position:x", -resource_bank.size.x, 0.25)
	await tween.finished
	return

func _on_button_toggled(toggled_on: bool, button_idx: int) -> void:
	if (!toggled_on):
		_fly_resource_bank_out()
		return
	
	for button: Button in $ResourceCounts/HBoxContainer.get_children():
		if (button.get_index() == button_idx):
			continue
		
		if (button.button_pressed):
			button.set_pressed_no_signal(false)
			await _fly_resource_bank_out()
			_fly_resource_bank_in(button_idx)
			return
	
	_fly_resource_bank_in(button_idx)

func _on_player_resources_changed() -> void:
	$ResourceCounts/MarginContainer/TextBar.text = "[color=blue]$[/color] %3d   [color=green]%%[/color] %3d   [color=red]@[/color] %3d   [color=orange]#[/color] %3d" % player.get_stored_resources()
