extends CanvasLayer

@onready
var command_line = $PanelContainer/VBoxContainer/CommandLine

@onready
var history = $PanelContainer/VBoxContainer/MarginContainer/RichTextLabel

func _ready() -> void:
	command_line.caret_column = len(command_line.text)

func _on_command_line_text_changed(new_text: String) -> void:
	if (!new_text.begins_with("> ")):
		command_line.text = "> " + command_line.text.substr(2)
		command_line.caret_column = len(command_line.text)

func _on_command_line_text_submitted(new_text: String) -> void:
	print(new_text)
	history.text += "\n%s" % new_text
	command_line.text = "> "
	command_line.caret_column = len(command_line.text)
