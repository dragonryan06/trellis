extends VBoxContainer

@onready
var player = get_node(GlobalLookups.player) as Player

var active_tab := -1

func modify_resource_particles(of_type: SoilResources.Types, by: int) -> void:
	var sand = $ResourceBank/HBoxContainer/LeftSide/SubViewportContainer/SubViewport.get_child(
		of_type
	) as FallingSand
	
	if (by > 0):
		sand.queue_add_particles(by)
	else:
		sand.queue_remove_particles(-by)

func _ready() -> void:
	player.resources_changed.connect(_on_player_resources_changed)
	player.roots_changed.connect(
		func(): if active_tab != -1: _update_bank_data(),
		ConnectFlags.CONNECT_DEFERRED
	)
	
	# Wait for container sizing to set in before going top level.
	await get_tree().process_frame
	$ResourceBank.top_level = true
	$ResourceBank.position.x = -$ResourceBank.size.x

func _fly_resource_bank_in() -> void:
	var resource_bank = $ResourceBank
	
	var title = resource_bank.get_node(^"HBoxContainer/RightSide/VBoxContainer/Title")
	title.text = SoilResources.NAMES[active_tab]
	title.modulate = SoilResources.COLORS[active_tab]
	_update_bank_data()
	resource_bank.get_node(^"HBoxContainer/RightSide/VBoxContainer/Flavor").text = SoilResources.FLAVORTEXT[active_tab]
	
	var viewport = resource_bank.get_node(^"HBoxContainer/LeftSide/SubViewportContainer/SubViewport")
	for child in viewport.get_children():
		if (child is not FallingSand):
			continue
		
		if (child.get_index() == active_tab):
			child.visible = true
		else:
			child.visible = false
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(resource_bank, ^"position:x", 0.0, 0.25)
	tween.tween_callback(func(): resource_bank.top_level = false)

func _fly_resource_bank_out() -> void:
	var resource_bank = $ResourceBank
	resource_bank.top_level = true
	
	for tap: ResourceTap in get_tree().get_nodes_in_group(&"resource_taps"):
		tap.hide()
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(resource_bank, ^"position:x", -resource_bank.size.x, 0.25)
	await tween.finished
	return

func _update_bank_data() -> void:
	var intake := 0
	for tap: ResourceTap in get_tree().get_nodes_in_group(&"resource_taps"):
		var vein = tap.tapped_vein
		if (vein.type == active_tab and vein.remaining > 0):
			intake += 1
			tap.show()
			tap.modulate = SoilResources.COLORS[active_tab]
			tap.get_node("PointLight2D").color = SoilResources.COLORS[active_tab]
		else:
			tap.hide()
	
	var data = $ResourceBank.get_node(^"HBoxContainer/RightSide/VBoxContainer/Data")
	data.text = "Storing: %2d [color=gray]%s[/color]
Intake: %3d [color=gray]%s/d[/color]" % [
		player.count_stored_resource(active_tab),
		SoilResources.UNITS[active_tab],
		intake,
		SoilResources.UNITS[active_tab]
	]

func _on_button_toggled(toggled_on: bool, button_idx: int) -> void:
	if (!toggled_on):
		_fly_resource_bank_out()
		active_tab = -1
		return
	
	active_tab = button_idx
	
	for button: Button in $ResourceCounts/HBoxContainer.get_children():
		if (button.get_index() == button_idx):
			continue
		
		if (button.button_pressed):
			button.set_pressed_no_signal(false)
			await _fly_resource_bank_out()
			_fly_resource_bank_in()
			return
	
	_fly_resource_bank_in()

func _on_player_resources_changed() -> void:
	$ResourceCounts/MarginContainer/TextBar.text = "[color=blue]$[/color] %3d   [color=green]%%[/color] %3d   [color=red]@[/color] %3d   [color=orange]#[/color] %3d" % player.get_stored_resources()
	
	if (active_tab == -1):
		return
	
	_update_bank_data()
