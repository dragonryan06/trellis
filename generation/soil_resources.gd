extends Node2D

const IMAGE_DIM := Vector2i(512, 512)
const GRID_DIM := Vector2i(8, 8)
const RESOURCE_TYPES: Dictionary[String, Color] = {
	"nothing" : Color("transparent"),
	"water" : Color("blue"),
	"ichor" : Color("green"),
	"phosphor" : Color("red"),
	"ambrose" : Color("orange")
}
const RESOURCE_WEIGHTS: Dictionary[String, float] = {
	"nothing" : 0.75, 
	"water" : 0.0625, 
	"ichor" : 0.0625,
	"phosphor" : 0.0625,
	"ambrose" : 0.0625
}

## Every "chunk" spawns one voronoi seed, which later becomes a resource node.
## To find what resource node you lie in the voronoi region of, first find the
## chunk you're in, and then compare distances of that chunk's and each of its
## neighbors' nodes with your position.

# Pairing of chunk position to node (voronoi seed) position
var _chunks: Dictionary[Vector2i, Vector2i]

# Pairing of node (voronoi seed) position to resource type
var _resource_nodes: Dictionary[Vector2i, String]

func _ready() -> void:
	var sprite = Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(_generate_resources())
	@warning_ignore("integer_division")
	sprite.position.y = IMAGE_DIM.y / 2
	add_child(sprite)

func _generate_resources() -> Image:
	print("Generating soil resources...")
	var t_start = Time.get_unix_time_from_system()
	
	var image := Image.create(IMAGE_DIM.x, IMAGE_DIM.y, false, Image.FORMAT_RGBA8) # format doesn't necessarily have to be this internally
	
	@warning_ignore("integer_division")
	var chunk_size := IMAGE_DIM / GRID_DIM
	
	for y in range(GRID_DIM.y):
		for x in range(GRID_DIM.x):
			var resource = RandomHelper.get_weighted_random_key(RESOURCE_WEIGHTS)
			var location = Vector2i(
				randi_range(x * chunk_size.x, x * chunk_size.x + chunk_size.x),
				randi_range(y * chunk_size.y, y * chunk_size.y + chunk_size.y)
			)
			_chunks[Vector2i(x, y)] = location
			_resource_nodes[location] = resource
	
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.005
	
	# It's technically only necessary to check this chunk and its neighbors, come back and fix this once its working.
	for y in range(IMAGE_DIM.y):
		for x in range(IMAGE_DIM.x):
			var nearest_distance := INF
			var nearest: String
			
			for voronoi_seed in _get_local_and_neighboring_voronoi_seeds(Vector2i(x, y)):
				if (voronoi_seed == null):
					continue
				
				var dist = voronoi_seed.distance_squared_to(Vector2i(x, y))
				if (dist < nearest_distance):
					nearest_distance = dist
					nearest = _resource_nodes[voronoi_seed]
			
			image.set_pixel(x, y, Color(
				RESOURCE_TYPES[nearest].r,
				RESOURCE_TYPES[nearest].g,
				RESOURCE_TYPES[nearest].b,
				RESOURCE_TYPES[nearest].a * snapped(noise.get_noise_2d(x,y) + 0.75, 0.25)))
	
	print("...done (%.2fs)" % (Time.get_unix_time_from_system() - t_start))
	
	return image

func _get_local_and_neighboring_voronoi_seeds(location: Vector2i) -> Array:
	@warning_ignore("integer_division")
	var chunk_pos = Vector2i(
		location.x / (IMAGE_DIM.x / GRID_DIM.x), 
		location.y / (IMAGE_DIM.y / GRID_DIM.y)
	)
	return [
		_chunks.get(chunk_pos),
		_chunks.get(chunk_pos + Vector2i.UP),
		_chunks.get(chunk_pos + Vector2i.DOWN),
		_chunks.get(chunk_pos + Vector2i.LEFT),
		_chunks.get(chunk_pos + Vector2i.RIGHT)
	]
