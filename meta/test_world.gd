extends Node2D

func _on_next_turn_pressed() -> void:
	GameState.next_turn.emit()
