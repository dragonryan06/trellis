class_name BranchHandle
extends HandleBase

func _ready() -> void:
	super._ready()
	hide()

func _on_next_phase() -> void:
	# We must override so our visibility doesn't get messed with
	pass

func _on_visibility_range_mouse_entered() -> void:
	if (GameState.phase_name == "Noon"):
		show()

func _on_visibility_range_mouse_exited() -> void:
	if (!mouse_drag and !was_moved):
		hide()
