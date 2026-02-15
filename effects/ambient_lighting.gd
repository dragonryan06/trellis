extends CanvasModulate

func _ready() -> void:
	GameState.next_phase.connect(
		func(): $AnimationPlayer.play(GameState.phase_name)
	)
