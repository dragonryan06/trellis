class_name Player
extends Sprite2D

signal resources_changed

var _stored_resources: Dictionary[String, int] = {
	"water" : 0,
	"ichor" : 0,
	"phosphor" : 0,
	"ambrose" : 0
}

func increment_stored_resource(type: String, by: int) -> void:
	_stored_resources[type] += by
	resources_changed.emit()
	
	if (by > 0):
		get_parent().get_node(^"HUD/ResourceCounts").add_resource_particles(type, by)
	else:
		print("Removing from stored resource sandbox not implemented!!!")

func count_stored_resource(type: String) -> int:
	return _stored_resources[type]

func get_stored_resources() -> Array[int]:
	return _stored_resources.values()

func _ready() -> void:
	GlobalLookups.player = get_path()
