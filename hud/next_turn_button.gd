extends TextureButton

func _process(delta: float) -> void:
	$SubViewportContainer/SubViewport/Icon.rotation += 0.01
