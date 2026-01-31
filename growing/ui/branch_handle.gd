class_name BranchHandle
extends HandleBase

func _ready() -> void:
	$AnimatedSprite2D.hide()

func _on_visibility_range_mouse_entered() -> void:
	$AnimatedSprite2D.show()

func _on_visibility_range_mouse_exited() -> void:
	if (!mouse_drag and !was_moved):
		$AnimatedSprite2D.hide()
