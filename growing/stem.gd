class_name Stem
extends GrowableLineBase

func _ready() -> void:
	super._ready()
	cost[SoilResources.Types.ICHOR] = 1

func _on_next_phase() -> void:
	super._on_next_phase()
	pass
