class_name Stem
extends GrowableLineBase

func grow_to(location: Vector2) -> void:
	super.grow_to(location)
	var leaf = load("res://growing/leaf.tscn").instantiate()
	leaf.position = location
	add_child(leaf)

func _ready() -> void:
	super._ready()
	cost[SoilResources.Types.ICHOR] = 1

func _on_next_phase() -> void:
	super._on_next_phase()
	pass
