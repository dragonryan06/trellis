extends CanvasLayer

var enabled := true

var _hold := false

func _input(event: InputEvent) -> void:
	if (!_hold and enabled and event.is_action_pressed(&"pause_menu_toggle")):
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property($PanelContainer, ^"position:y", -$PanelContainer.position.y, 0.5)
		_hold = true
		tween.tween_callback(func(): _hold = false)

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
	queue_free()

func _on_options_pressed() -> void:
	add_sibling(load("res://menus/options_menu.tscn").instantiate())

func _on_quit_pressed() -> void:
	get_tree().quit()
