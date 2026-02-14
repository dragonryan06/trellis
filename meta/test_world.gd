extends Node2D

func _ready() -> void:
	GameState.hold_state_changed.connect(_on_hold_state_changed)

func _on_next_turn_button_pressed() -> void:
	GameState.advance_turn()

func _on_hold_state_changed(state: bool) -> void:
	$HUD/NextTurnButton.disable(state)
