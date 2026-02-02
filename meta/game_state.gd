extends Node

signal next_turn
signal hold_state_changed(state: bool)

var turn_count : int

var _holds: Array[Node] = []

func advance_turn() -> bool:
	if (!_holds.is_empty()):
		print("Can't advance turn, one or more nodes is holding: " + str(_holds))
		return false
	
	next_turn.emit()
	turn_count += 1
	print("==== Turn %d ====" % (turn_count + 1))
	return true

## Request that turn advances be denied until you release_hold(self)
func hold(caller: Node) -> void:
	if (_holds.find(caller) == -1):
		_holds.append(caller)
	
	if (len(_holds) == 1):
		hold_state_changed.emit(true)

## Release the hold placed in the name of caller, if there is one.
func release_hold(caller: Node) -> void:
	_holds.erase(caller)
	
	if (len(_holds) == 0):
		hold_state_changed.emit(false)

func _ready() -> void:
	print("==== Turn 1 ====")
