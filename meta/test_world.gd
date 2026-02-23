extends Node2D

func spawn_floaty_hint(with_text: String, color := Color("White")) -> void:
	await get_tree().create_timer(0.5).timeout
	var label = FloatyLabel.new()
	label.text = with_text
	label.modulate = color
	label.position = get_local_mouse_position()
	add_child(label)

func _ready() -> void:
	GameState.hold_state_changed.connect($HUD/NextTurnButton.disable)
	GameState.next_phase.connect(_show_missing_feature_hint)

func _on_next_turn_button_pressed() -> void:
	GameState.advance_phase()

func _show_missing_feature_hint() -> void:
	await get_tree().create_timer(1.0).timeout
	var label = FloatyLabel.new()
	match GameState.phase_name:
		"Dawn":
			label.text = "[WIP] Events trigger..."
		"Noon":
			#label.text = "[WIP] Some soil resources expended to survive..."
			return
		"Dusk":
			label.text = "[WIP] Sensing abilities available..."
	label.position = get_local_mouse_position()
	add_child(label)
