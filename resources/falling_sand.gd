class_name FallingSand
extends Sprite2D

const TICK_LENGTH := 0.05
const MIN_VALUE := 100

@export
var image_size := Vector2i(16, 16)

enum MovementType { POWDER, LIQUID }
@export var movement_type: MovementType

@onready
var _image := Image.create_empty(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)

var _sim_state: Array[PackedByteArray]

var _dirty := false

var _frozen: Array[Vector2i] = []

func _ready() -> void:
	centered = false
	_image.fill(Color("transparent"))
	texture = ImageTexture.new()
	texture.set_image(_image)
	
	for y in range(image_size.y):
		var row: PackedByteArray = []
		for x in range(image_size.x):
			row.append(0)
		_sim_state.append(row)
	
	var ticker = Timer.new()
	ticker.autostart = true
	ticker.timeout.connect(_tick)
	add_child(ticker)
	ticker.start(TICK_LENGTH)

func _process(_delta: float) -> void:
	if (!_dirty):
		return
	
	for y in range(image_size.y):
		for x in range(image_size.x):
			var val = _sim_state[y][x]
			if (val != 0):
				var color = val / 255.0
				_image.set_pixel(x, y, Color(color, color, color, 1.0))
			else:
				_image.set_pixel(x, y, Color("transparent"))
	
	texture.update(_image)
	_dirty = false

func _input(event: InputEvent) -> void:
	if (!event.is_action_pressed(&"TEST_spawn_particle")):
		return
	
	_sim_state[0][randi_range(0, image_size.x - 1)] = randi_range(MIN_VALUE, 255)
	_dirty = true

func _tick() -> void:
	for y in range(image_size.y):
		for x in range(image_size.x):
			if (_frozen.has(Vector2i(x, y))):
				continue
			
			var val = _sim_state[y][x]
			if (val == 0):
				continue
			
			var try_move = func(to_x: int, to_y: int) -> bool:
				if (to_y < 0 or to_y >= image_size.y or to_x < 0 or to_x >= image_size.x):
					return false
				
				if (_sim_state[to_y][to_x] == 0):
					_sim_state[y][x] = 0
					_sim_state[to_y][to_x] = val
					_frozen.append(Vector2i(to_x, to_y))
					return true
				return false
			
			var moves: Array[Callable] = [
				try_move.bind(x - 1, y + 1),
				try_move.bind(x + 1, y + 1)
			]
			
			if (movement_type == MovementType.LIQUID):
				moves.append(try_move.bind(x - 1, y))
				moves.append(try_move.bind(x + 1, y))
			
			moves.shuffle()
			moves.insert(0, try_move.bind(x, y + 1))
			
			for move in moves:
				if (move.call()):
					break
	
	_dirty = true
	_frozen = []
