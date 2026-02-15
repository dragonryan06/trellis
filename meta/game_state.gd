extends Node

const TURN_PHASES : Array[String] = [
	"Dawn",
	"Noon",
	"Dusk"
]

signal next_phase
signal next_turn
signal hold_state_changed(state: bool)

var turn_number : int:
	get():
		@warning_ignore(&"integer_division")
		return (_phase_count / 3) + 1

var phase_name : String:
	get():
		return TURN_PHASES[_phase_count % 3]

var _phase_count : int
var _holds: Array[Node] = []

func advance_phase() -> bool:
	if (!_holds.is_empty()):
		print("Can't advance phase, one or more nodes is holding: " + str(_holds))
		return false
	
	_phase_count += 1
	next_phase.emit()
	
	if (_phase_count % 3 == 0):
		next_turn.emit()
	
	print("==== %s of Turn %d ====" % [phase_name, turn_number])
	return true

## Request that phase advances be denied until you release_hold(self)
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
	print("==== Dawn of Turn 1 ====")
