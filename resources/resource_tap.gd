class_name ResourceTap
extends Marker2D

func _ready() -> void:
	GameState.next_phase.connect(_on_next_phase)

func _on_next_phase() -> void:
	if (GameState.phase_name != "Dawn"):
		return
	
	var soil_resources = get_node(GlobalLookups.soil_resources) as SoilResources
	print(soil_resources.get_resource_at(soil_resources.to_local(global_position)))
