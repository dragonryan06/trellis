extends CanvasLayer

@onready
var _command_line = $PanelContainer/VBoxContainer/CommandLine
@onready
var _history = $PanelContainer/VBoxContainer/MarginContainer/RichTextLabel

var _toggled := false

var _command_registry: Dictionary[StringName, Callable] = { }

func register_command(command: StringName, callable: Callable) -> void:
	_command_registry[command] = callable

func _ready() -> void:
	_command_line.caret_column = len(_command_line.text)
	
	register_command(&"clear", func(): _history.text = "")

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed(&"debug_console_toggle")):
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		if _toggled:
			tween.tween_property($PanelContainer, ^"position:y", -$PanelContainer.get_rect().size.y, 0.25)
		else:
			tween.tween_property($PanelContainer, ^"position:y", 0.0, 0.25)
		_toggled = !_toggled

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()):
		_command_line.release_focus()

func _evaluate_command(command: String) -> void:
	var result
	
	var found_command := &""
	for registered in _command_registry:
		if (command.begins_with(registered)):
			found_command = registered
			break
	
	if (found_command != &""):
		var callable := _command_registry[found_command]
		var args := command.trim_prefix(found_command).split(" ", false) 
		
		if (len(args) != callable.get_argument_count()):
			result = "[color=red]%s: Expected %d args, got %d[/color]" % [
				found_command.split(" ", false)[-1],
				callable.get_argument_count(),
				len(args)
			]
		else:
			result = _command_registry[found_command].callv(args)
	else:
		var arbitrary := Expression.new()
		
		if (arbitrary.parse(command) != Error.OK):
			result = "[color=red]%s[/color]" % arbitrary.get_error_text()
		else:
			result = arbitrary.execute([], self)
			
			if (arbitrary.has_execute_failed()):
				result = "[color=red]%s[/color]" % arbitrary.get_error_text()
	
	if (result == null):
		return
	
	print(result)
	_history.text += "\n%s" % result

func _on_command_line_text_changed(new_text: String) -> void:
	if (!new_text.begins_with("> ")):
		_command_line.text = "> " + _command_line.text.substr(2)
		_command_line.caret_column = len(_command_line.text)
	
	if (new_text.contains("`") or new_text.contains("~")):
		# User actually meant to close the window.
		_command_line.text = "> "
		_command_line.caret_column = len(_command_line.text)
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property($PanelContainer, ^"position:y", -$PanelContainer.get_rect().size.y, 0.25)
		_command_line.release_focus()
		_toggled = false

func _on_command_line_text_submitted(new_text: String) -> void:
	print(new_text)
	_history.text += "\n%s" % new_text
	_command_line.text = "> "
	_command_line.caret_column = len(_command_line.text)
	
	if (new_text == "> "):
		return
	
	_evaluate_command(new_text.trim_prefix("> "))
