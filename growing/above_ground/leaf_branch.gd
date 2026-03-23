class_name LeafBranch
extends GrowableLineBase

func grow_to(location: Vector2) -> void:
	super.grow_to(location)
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($EndLeaf, ^"position", location, 1.0)

func _ready() -> void:
	super._ready()
	cost[SoilResources.Types.ICHOR] = 1
	$EndLeaf.position = points[-1]
