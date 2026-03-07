class_name Player
extends Sprite2D

signal resources_changed
signal roots_changed

var _stored_resources: Dictionary[SoilResources.Types, int] = {
	SoilResources.Types.WATER : 0,
	SoilResources.Types.ICHOR : 0,
	SoilResources.Types.PHOSPHOR : 0,
	SoilResources.Types.AMBROSE : 0
}

func modify_stored_resource(type: SoilResources.Types, by: int) -> void:
	assert(_stored_resources[type] + by >= 0, "Please don't take more resource than is present!")
	_stored_resources[type] += by
	resources_changed.emit()
	
	print("%s: %d -> %d" % [SoilResources.NAMES[type], _stored_resources[type] - by, _stored_resources[type]])
	
	get_parent().get_node(^"HUD/ResourceInfo").modify_resource_particles(type, by)

func count_stored_resource(type: SoilResources.Types) -> int:
	return _stored_resources[type]

func get_stored_resources() -> Array[int]:
	return _stored_resources.values()

func can_afford(cost: Dictionary[SoilResources.Types, int]) -> bool:
	for type: SoilResources.Types in cost:
		if (count_stored_resource(type) - cost[type] < 0):
			return false
	return true

func _ready() -> void:
	GlobalLookups.player = get_path()
	GameState.next_phase.connect(_on_next_phase)
	
	DebugConsole.register_command(&"resource add", func(type: String, amount: String):
		var idx = SoilResources.NAMES.values().find(type.to_lower().capitalize())
		if (idx == -1):
			return "[color=red]add: Unknown resource type: %s[/color]" % type
		
		if (int(amount) == 0):
			return "[color=red]add: Invalid quantity: %s[/color]" % amount
		
		modify_stored_resource(SoilResources.Types.values()[idx], int(amount))
	)
	
	# Wait for the whole resources system to ready before setting gamestart resources
	await get_tree().process_frame
	
	modify_stored_resource(SoilResources.Types.WATER, 5)
	modify_stored_resource(SoilResources.Types.PHOSPHOR, 5)

func _on_next_phase() -> void:
	if (GameState.phase_name == "Noon"):
		if (count_stored_resource(SoilResources.Types.WATER) > 0):
			modify_stored_resource(SoilResources.Types.WATER, -1)
		else:
			get_parent().spawn_floaty_hint("[WIP] You are dehydrated!!", Color("Red"))
	
	if (GameState.phase_name == "Dusk"):
		for growable: GrowableLineBase in get_tree().get_nodes_in_group(&"to_be_grown"):
			for type: SoilResources.Types in growable.cost:
				modify_stored_resource(type, -growable.cost[type])
			growable.remove_from_group(&"to_be_grown")

func _on_child_entered_tree(node: Node) -> void:
	if (node is not Root):
		return
	
	node.shape_changed.connect(roots_changed.emit)
