class_name ResourceTap
extends Marker2D

@onready
var pellet_texture = preload("res://resources/resource_pellet.png")

func _ready() -> void:
	GameState.next_phase.connect(_on_next_phase)

func _on_next_phase() -> void:
	if (GameState.phase_name != "Dawn"):
		return
	
	var soil_resources = get_node(GlobalLookups.soil_resources) as SoilResources
	var vein = soil_resources.get_resource_at(soil_resources.to_local(global_position))
	
	if (vein.remaining == 0):
		return
	
	vein.remaining -= 1
	var player = get_node(GlobalLookups.player) as Player
	player.increment_stored_resource(vein.type, 1)
	
	var pellet = Sprite2D.new()
	pellet.material = CanvasItemMaterial.new()
	pellet.material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	pellet.texture = pellet_texture
	pellet.modulate = vein.color
	add_child(pellet)
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(pellet, ^"position", make_canvas_position_local(Vector2.ZERO), 0.5)
	tween.tween_callback(pellet.queue_free)
