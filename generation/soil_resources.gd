extends Node2D

const IMAGE_DIM := Vector2i(512, 512)
const GRID_DIM := Vector2i(8, 8)
const VORONOI_SEEDS: Dictionary[String, Color] = {
	"nothing" : Color("transparent"),
	"water" : Color("blue"),
	"ichor" : Color("green"),
	"phosphor" : Color("red"),
	"ambrose" : Color("orange")
}
const SEED_WEIGHTS: Dictionary[String, float] = {
	"nothing" : 0.75, 
	"water" : 0.0625, 
	"ichor" : 0.0625,
	"phosphor" : 0.0625,
	"ambrose" : 0.0625
}

func _ready() -> void:
	var sprite = Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(_generate_voronoi_regions())
	add_child(sprite)

func _generate_voronoi_regions() -> Image:
	var image := Image.create(IMAGE_DIM.x, IMAGE_DIM.y, false, Image.FORMAT_RGBA8) # format doesn't necessarily have to be this internally
	var seeds: Dictionary[Vector2i, String]
	@warning_ignore("integer_division")
	var chunk_size := IMAGE_DIM / GRID_DIM
	
	for y in range(GRID_DIM.y):
		for x in range(GRID_DIM.x):
			var voronoi_seed = RandomHelper.get_weighted_random_key(SEED_WEIGHTS)
			seeds[Vector2i(
				randi_range(x * chunk_size.x, x * chunk_size.x + chunk_size.x),
				randi_range(y * chunk_size.y, y * chunk_size.y + chunk_size.y)
			)] = voronoi_seed
	
	# It's technically only necessary to check this chunk and its neighbors, come back and fix this once its working.
	for y in range(IMAGE_DIM.y):
		for x in range(IMAGE_DIM.x):
			var nearest_distance := INF
			var nearest: String
			
			for voronoi_seed: Vector2i in seeds.keys():
				var dist = voronoi_seed.distance_squared_to(Vector2i(x, y))
				if (dist < nearest_distance):
					nearest_distance = dist
					nearest = seeds[voronoi_seed]
			
			image.set_pixel(x, y, VORONOI_SEEDS[nearest])
	
	return image
