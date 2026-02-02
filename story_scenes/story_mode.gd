extends Node2D

var seed_wiggle_tween: Tween

func _ready() -> void:
	$PlayerCamera.locked = true
	$PlayerCore/Stem/GrowthHandle.hide()
	$PlayerCore/Taproot/GrowthHandle.hide()
	seed_wiggle_tween = get_tree().create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	seed_wiggle_tween.tween_property($PlayerCore, ^"rotation", 0.1, 1.0)
	seed_wiggle_tween.tween_property($PlayerCore, ^"rotation", -0.1, 2.0)
	$Vignette/AnimationPlayer.play(&"blackout")
	$HUD/StartupMovie.play()
	
	await $HUD/StartupMovie.finished
	
	$Vignette/AnimationPlayer.play(&"initial_loop")

func wake_up_effect() -> void:
	$WakeUpClickArea.queue_free()
	seed_wiggle_tween.kill()
	$Vignette/AnimationPlayer.play(&"wake_up")
	
	var stem = $PlayerCore/Stem
	var taproot = $PlayerCore/Taproot
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(stem, ^"endpoint_position", Vector2(24, -48), 6.0)
	tween.tween_property(taproot, ^"endpoint_position", Vector2(16, 64), 6.0)
	
	await tween.finished
	
	stem.get_node(^"GrowthHandle").show()
	stem.get_node(^"GrowthHandle").position = stem.endpoint_position
	taproot.get_node(^"GrowthHandle").show()
	taproot.get_node(^"GrowthHandle").position = taproot.endpoint_position
	$PlayerCamera.locked = false

func _on_next_turn_pressed() -> void:
	GameState.advance_turn()

func _on_wake_up_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (!(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT)):
		return
	
	wake_up_effect()
