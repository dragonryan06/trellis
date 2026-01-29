extends Node

signal next_turn

var turn_count : int

func advance_turn() -> void:
	next_turn.emit()
	turn_count += 1
	print("==== Turn %d ====" % (turn_count + 1))

func _ready() -> void:
	print("==== Turn 1 ====")
