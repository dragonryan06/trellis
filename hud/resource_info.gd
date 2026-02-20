extends VBoxContainer

const TITLES: Array[String] = [
	"Water",
	"Ichor",
	"Phosphor",
	"Ambrose"
]
const COLORS: Array[Color] = [
	Color("blue"),
	Color("green"),
	Color("red"),
	Color("orange")
]

func _ready() -> void:
	# Wait for container sizing to set in before going top level.
	await get_tree().process_frame
	$ResourceBank.top_level = true
	$ResourceBank.position.x = -$ResourceBank.size.x

func _fly_resource_bank_in(button_idx: int) -> void:
	var resource_bank = $ResourceBank
	
	var title = resource_bank.get_node(^"HBoxContainer/MarginContainer/VBoxContainer/Title")
	title.text = TITLES[button_idx]
	title.modulate = COLORS[button_idx]
	
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
