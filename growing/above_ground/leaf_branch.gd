class_name LeafBranch
extends GrowableLineBase

func _ready() -> void:
	super._ready()
	cost[SoilResources.Types.ICHOR] = 1
	$TomatoLeaf.position = points[-1]
