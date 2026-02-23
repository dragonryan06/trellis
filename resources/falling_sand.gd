class_name FallingSand
extends Sprite2D

const TICK_LENGTH := 0.05
const MIN_VALUE := 127

@export
var image_size := Vector2i(16, 16)

enum MovementType { POWDER, LIQUID }
@export var movement_type: MovementType

@onready
var _image := Image.create_empty(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)

var _sim_state: Array[PackedByteArray]

var _dirty := false

var _frozen: Array[Vector2i] = []

var _queue_added_this_frame := false
var _add_queue := 0
var _queue_removed_this_frame := false
var _remove_queue := 0

## Add a particle immediately.
func add_particle() -> void:
	_sim_state[0][randi_range(0, image_size.x - 1)] = randi_range(MIN_VALUE, 255)
	_dirty = true

## Add 'count' particles to the queue, to be introduced a tick at a time.
## It's okay and actually generally preferred to call this with count=1.
func queue_add_particles(count: int) -> void:
	assert(count > 0, "I can't add %d particles, silly" % count)
	if (_add_queue == 0 and !_queue_added_this_frame):
		add_particle()
		_queue_added_this_frame = true
		_add_queue += count - 1
	else:
		_add_queue += count

## Remove a particle immediately.
func remove_particle() -> void:
	var nonzero_cols: Array[int] = []
	for x in range(image_size.x): # TODO a similar loop to this could be added to add() to ensure we're not overwriting the top row.
		if (_sim_state[image_size.y - 1][x] != 0):
			nonzero_cols.append(x)
	
	_sim_state[image_size.y - 1][nonzero_cols.pick_random()] = 0
	_dirty = true

## Add 'count' particles to the queue, to be removed a tick at a time.
## It's okay and actually generally preferred to call this with count=1.
func queue_remove_particles(count: int) -> void:
	assert(count > 0, "I can't remove %d particles, silly" % count)
	if (_remove_queue == 0 and !_queue_removed_this_frame):
		remove_particle()
		_queue_removed_this_frame = true
		_remove_queue += count - 1
	else:
		_remove_queue += count

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
	_queue_added_this_frame = false
	_queue_removed_this_frame = false

func _tick() -> void:
	if (_add_queue > 0):
		add_particle()
		_add_queue -= 1
	
	if (_remove_queue > 0):
		remove_particle()
		_remove_queue -= 1
	
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
