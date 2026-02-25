class_name ResourceTap
extends AnimatedSprite2D

@onready
var pellet_texture = preload("res://resources/resource_pellet.png")

@onready
var soil_resources := get_node(GlobalLookups.soil_resources) as SoilResources

var tapped_vein: ResourceVein:
	get():
		return soil_resources.get_resource_at(soil_resources.to_local(global_position))

func _ready() -> void:
	GameState.next_phase.connect(_on_next_phase)
	add_to_group(&"resource_taps")

func _on_next_phase() -> void:
	if (GameState.phase_name != "Dawn"):
		return
	
	var vein = soil_resources.get_resource_at(soil_resources.to_local(global_position))
	
	if (vein.remaining == 0):
		return
	
	vein.remaining -= 1
	var player = get_node(GlobalLookups.player) as Player
	var increment = player.modify_stored_resource.bind(vein.type, 1)
	
	var pellet = Sprite2D.new()
	pellet.material = CanvasItemMaterial.new()
	pellet.material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	pellet.texture = pellet_texture
	pellet.modulate = vein.color
	add_child(pellet)
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(pellet, ^"position", make_canvas_position_local(Vector2.ZERO), 0.5)
	tween.tween_callback(pellet.queue_free)
	tween.tween_callback(increment) # TODO bug somewhere around here where increment can end up called twice...?
