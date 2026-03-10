extends CanvasLayer

func _ready() -> void:
	for action: StringName in InputMap.get_actions():
		if (action.begins_with("ui_")):
			continue
		
		$PanelContainer/Content/TabContainer/Controls/VBoxContainer/HBoxContainer/Names.text += "%s:\n" % action
		$PanelContainer/Content/TabContainer/Controls/VBoxContainer/HBoxContainer/Values.text += "%s\n" % InputMap.action_get_events(action)[0].as_text()

func _on_back_pressed() -> void:
	queue_free()
