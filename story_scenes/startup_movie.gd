extends CanvasLayer

const MESSAGE_FADE := 1.0
const MESSAGE_HOLD := 5.0
const MESSAGE_SPACING := 2.5

signal finished

func _ready() -> void:
	# Give the loading hint a frame to draw
	# TODO: Generation needs to happen in a separate thread so there can be a throbber instead
	await get_tree().process_frame
	$Loading.queue_free()
	
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
	
	_finalize()

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventKey) and event.is_pressed():
		_finalize()
		for child in get_children():
			if (!child.name.begins_with("Message")):
				continue
			child.hide()

func _finalize():
	$Vignette/AnimationPlayer.play(&"eyes_opening")
	await $Vignette/AnimationPlayer.animation_finished
	
	finished.emit()
	queue_free()
