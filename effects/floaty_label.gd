class_name FloatyLabel
extends Label

## A little hint text that floats up and off the screen

var move_speed := 100.0
var wiggle_amount := 50.0

func _ready() -> void:
	var notifier := VisibleOnScreenNotifier2D.new()
	notifier.rect = Rect2(Vector2.ZERO, get_rect().size)
	notifier.screen_exited.connect(queue_free)
	add_child(notifier)
	
	position.x -= get_rect().size.x / 2.0
	
	# So lighting effects ignore us
	material = CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	
	_wiggle()

func _process(delta: float) -> void:
	position.y -= move_speed * delta

func _wiggle() -> void:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, ^"position:x", position.x + randf_range(-wiggle_amount, wiggle_amount), 0.5)
	tween.finished.connect(_wiggle)
