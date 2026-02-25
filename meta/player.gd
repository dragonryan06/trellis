class_name Player
extends Sprite2D

signal resources_changed
signal roots_changed

var _stored_resources: Dictionary[String, int] = {
	"water" : 0,
	"ichor" : 0,
	"phosphor" : 0,
	"ambrose" : 0
}

func modify_stored_resource(type: String, by: int) -> void:
	assert(_stored_resources[type] + by >= 0, "Please don't take more resource than is present!")
	_stored_resources[type] += by
	resources_changed.emit()
	
	get_parent().get_node(^"HUD/ResourceInfo").modify_resource_particles(type, by)

func count_stored_resource(type: String) -> int:
	return _stored_resources[type]

func get_stored_resources() -> Array[int]:
	return _stored_resources.values()

func _ready() -> void:
	GlobalLookups.player = get_path()
	GameState.next_phase.connect(_on_next_phase)
	
	# Wait for the whole resources system to ready before setting gamestart resources
	await get_tree().process_frame
	
	modify_stored_resource("water", 5)

func _on_next_phase() -> void:
	if (GameState.phase_name != "Noon"):
		return
	
	if (count_stored_resource("water") > 0):
		modify_stored_resource("water", -1)
	else:
		get_parent().spawn_floaty_hint("[WIP] You are dehydrated!!", Color("Red"))

func _on_child_entered_tree(node: Node) -> void:
	if (node is not Root):
		return
	
	node.shape_changed.connect(roots_changed.emit)
