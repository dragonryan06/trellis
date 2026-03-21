extends Sprite2D

var _total := 0.0

func _process(delta: float) -> void:
	_total += delta
	$SubViewport/TomatoLeaf/Leaf.set_blend_shape_value(0, 0.5 * sin(_total) + 0.5)

func _set_baby() -> void:
	$SubViewport/TomatoLeaf/Leaf.set_blend_shape_value(0, 1.0)
	$SubViewport/TomatoLeaf/Leaf.set_blend_shape_value(1, 1.0)
	$SubViewport/TomatoLeaf/Leaf.s
