extends Control

const MESSAGE_FADE := 1.0
const MESSAGE_HOLD := 5.0
const MESSAGE_SPACING := 2.5

signal finished

func play() -> void:
	for child in get_children():
		if (!child.name.begins_with("Message")):
			continue
		
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, ^"modulate", Color.WHITE, MESSAGE_FADE)
		
		await tween.finished
		
		await get_tree().create_timer(MESSAGE_HOLD).timeout
		
		tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, ^"modulate", Color("#ffffff00"), MESSAGE_FADE)
		
		await get_tree().create_timer(MESSAGE_SPACING).timeout
	
	finished.emit()
	queue_free()
