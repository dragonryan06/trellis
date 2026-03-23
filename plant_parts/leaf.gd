extends Sprite2D

## The Sprite2D.offset to use when flip_h is true.
@export
var mirror_offset := Vector2(0.0, 0.0)

# 0.0: Baby, 1.0: Young, 2.0: Mature
var _growth := 0.0:
	get():
		return _growth
	set(value):
		var leaf = $SubViewport/TomatoLeaf/Leaf
		_growth = value
		
		if _growth <= 1.0:
			leaf.set_blend_shape_value(0, 1.0 - (_growth))
			leaf.set_blend_shape_value(1, _growth)
			leaf.set_instance_shader_parameter(&"scene_x", 0)
			leaf.set_instance_shader_parameter(&"scene_y", 1)
			leaf.set_instance_shader_parameter(&"crossfader", _growth)
		elif _growth <= 2.0:
			leaf.set_blend_shape_value(0, 0.0)
			leaf.set_blend_shape_value(1, 1.0 - (_growth - 1.0))
			leaf.set_instance_shader_parameter(&"scene_x", 1)
			leaf.set_instance_shader_parameter(&"scene_y", 2)
			leaf.set_instance_shader_parameter(&"crossfader", _growth - 1.0)
		else:
			leaf.set_blend_shape_value(0, 0.0)
			leaf.set_blend_shape_value(1, 0.0)
			leaf.set_instance_shader_parameter(&"scene_x", 2)
			leaf.set_instance_shader_parameter(&"crossfader", 0.0)

func mirror_sprite() -> void:
	flip_h = true
	offset = mirror_offset

func _ready() -> void:
	scale = Vector2(0.0, 0.0)
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, ^"scale", Vector2(0.5, 0.5), 1.0)

#func _ready() -> void:
	#_growth = 0.0
	#while true:
		#await _test_grow_up()
#
#func _test_grow_up() -> void:
	#_growth = 0.0
	#
	#var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	#tween.tween_property(self, ^"_growth", 2.0, 3.0)
	#
	#await tween.finished
