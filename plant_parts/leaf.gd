extends Sprite2D

const INVALID_COLOR := Color("#ff0000")
const VALID_COLOR := Color("#00ff00")

const BABY_HITBOX := Rect2(24.0, -1.5, 56.0, 25.0)
const YOUNG_HITBOX := Rect2(79.0, 0.0, 166.0, 68.0)
const MATURE_HITBOX := Rect2(92.0, 19.0, 252.0, 122.0)

var flip := false:
	set(value):
		flip = value
		scale.x = -scale.x

var to_be_grown := false

var _hover := false:
	set(value):
		_hover = value
		
		if _hover:
			set_instance_shader_parameter(&"outline_enabled", true)
		elif not to_be_grown:
			set_instance_shader_parameter(&"outline_enabled", false)

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
			$Hitbox/CollisionShape2D.position = BABY_HITBOX.position
			$Hitbox/CollisionShape2D.shape.size = BABY_HITBOX.size
			$CostDisplay.position = BABY_HITBOX.position + BABY_HITBOX.size
			if _growth == 1.0:
				$Hitbox/CollisionShape2D.position = YOUNG_HITBOX.position
				$Hitbox/CollisionShape2D.shape.size = YOUNG_HITBOX.size
		elif _growth <= 2.0:
			leaf.set_blend_shape_value(0, 0.0)
			leaf.set_blend_shape_value(1, 1.0 - (_growth - 1.0))
			leaf.set_instance_shader_parameter(&"scene_x", 1)
			leaf.set_instance_shader_parameter(&"scene_y", 2)
			leaf.set_instance_shader_parameter(&"crossfader", _growth - 1.0)
			$Hitbox/CollisionShape2D.position = YOUNG_HITBOX.position
			$Hitbox/CollisionShape2D.shape.size = YOUNG_HITBOX.size
			if _growth == 2.0:
				$Hitbox/CollisionShape2D.position = MATURE_HITBOX.position
				$Hitbox/CollisionShape2D.shape.size = MATURE_HITBOX.size
		else:
			leaf.set_blend_shape_value(0, 0.0)
			leaf.set_blend_shape_value(1, 0.0)
			leaf.set_instance_shader_parameter(&"scene_x", 2)
			leaf.set_instance_shader_parameter(&"crossfader", 0.0)
			$Hitbox/CollisionShape2D.position = MATURE_HITBOX.position
			$Hitbox/CollisionShape2D.shape.size = MATURE_HITBOX.size

func _ready() -> void:
	scale = Vector2(0.0, 0.0)
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, ^"scale", Vector2(-0.5, 0.5) if flip else Vector2(0.5, 0.5), 1.0)
	_growth = 0.0
	while true:
		await _test_grow_up()

func _test_grow_up() -> void:
	_growth = 0.0
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, ^"_growth", 2.0, 3.0)
	
	await tween.finished

func _on_hitbox_mouse_entered() -> void:
	_hover = true

func _on_hitbox_mouse_exited() -> void:
	_hover = false
