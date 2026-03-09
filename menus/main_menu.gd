extends Node2D

func _on_play_pressed() -> void:
	var tween = get_tree().create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property($UI/Center, ^"position:y", -$UI/Center.get_rect().size.y - $UI/Center.position.y, 1.0)
	tween.tween_property($UI/RepoLink, ^"position:x", -$UI/RepoLink.get_rect().size.x, 1.0)
	tween.tween_property($UI/VersionInfo, ^"position:x", get_viewport_rect().size.x, 1.0)
	
	await tween.finished
	
	var ftb = get_tree().create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	ftb.tween_property($AmbientLighting, ^"color", Color("#000000"), 2.0)
	ftb.tween_property($Camera2D, ^"position:y", 128.0, 2.0)
	
	await ftb.finished
	
	get_tree().change_scene_to_file("res://story_scenes/story_mode.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
