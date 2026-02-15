extends Button

const ATLAS_REGIONS := {
	"Dawn": Rect2(0, 0, 128, 128),
	"Noon": Rect2(128, 0, 128, 128),
	"Dusk": Rect2(0, 128, 128, 128),
	"Night": Rect2(128, 128, 128, 128)
}

var _pressed_played_once := false

## Please use this method instead of setting .disabled
func disable(state: bool) -> void:
	disabled = state
	$AnimatedSprite2D.play(&"disabled" if state else &"default")

func _ready() -> void:
	GameState.next_phase.connect(_on_next_phase)

func _on_next_phase() -> void:
	tooltip_text = "%s %d" % [GameState.phase_name, GameState.turn_number]
	
	var sprite = $SubViewportContainer/SubViewport/TimeOfDay
	var spin = func():
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SPRING)
		tween.tween_property(sprite, ^"rotation", PI, 1.0)
		await tween.finished
		sprite.rotation = 0.0
	await spin.call()
	
	if (GameState.phase_name == "Dawn"):
		sprite.texture.region = ATLAS_REGIONS["Night"]
		await spin.call()
	
	sprite.texture.region = ATLAS_REGIONS[GameState.phase_name]

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
