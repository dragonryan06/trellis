extends Button

var _pressed_played_once := false

## Please use this method instead of setting .disabled
func disable(state: bool) -> void:
	disabled = state
	$AnimatedSprite2D.play(&"disabled" if state else &"default")

func _ready() -> void:
	GameState.next_phase.connect(
		func(): tooltip_text = "%s %d" % [GameState.phase_name, GameState.turn_number]
	)

func _process(delta: float) -> void:
	$SubViewportContainer/SubViewport/Icon.rotation += 0.01

func _on_mouse_entered() -> void:
	$AnimatedSprite2D.play(&"hover")

func _on_mouse_exited() -> void:
	if (!_pressed_played_once):
		await $AnimatedSprite2D.animation_looped
	$AnimatedSprite2D.play(&"default")

func _on_button_down() -> void:
	_pressed_played_once = false
	$AnimatedSprite2D.play(&"pressed")
	await $AnimatedSprite2D.animation_looped
	_pressed_played_once = true

func _on_button_up() -> void:
	if (!_pressed_played_once):
		await $AnimatedSprite2D.animation_looped
	$AnimatedSprite2D.play(&"hover")

func _on_pressed() -> void:
	# Still blink if key shortcut was used instead:
	if (!is_hovered()):
		$AnimatedSprite2D.play(&"pressed")
		await $AnimatedSprite2D.animation_looped
		$AnimatedSprite2D.play(&"default")
