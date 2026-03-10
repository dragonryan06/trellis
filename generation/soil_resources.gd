class_name SoilResources
extends Node2D

## Note that Types.NOTHING should only appear in purposes of worldgen, nowhere else please!!
enum Types { NOTHING = -1, WATER, ICHOR, PHOSPHOR, AMBROSE }

const NAMES: Dictionary[Types, String] = {
	Types.NOTHING : "Nothing",
	Types.WATER : "Water",
	Types.ICHOR : "Ichor",
	Types.PHOSPHOR : "Phosphor",
	Types.AMBROSE : "Ambrose"
}

const COLORS: Dictionary[Types, Color] = {
	Types.NOTHING : Color("transparent"),
	Types.WATER : Color("blue"),
	Types.ICHOR : Color("green"),
	Types.PHOSPHOR : Color("red"),
	Types.AMBROSE : Color("orange")
}

const SYMBOLS: Dictionary[Types, String] = {
	Types.NOTHING : "",
	Types.WATER : "$",
	Types.ICHOR : "%",
	Types.PHOSPHOR : "@",
	Types.AMBROSE : "#"
}

const UNITS: Dictionary[Types, String] = {
	Types.NOTHING : "",
	Types.WATER : "drams",
	Types.ICHOR : "drams",
	Types.PHOSPHOR : "motes",
	Types.AMBROSE : "motes"
}

const FLAVORTEXT: Dictionary[Types, String] = {
	Types.NOTHING : "[color=gray]There is nothing there.",
	Types.WATER : "[color=gray]Essence of life and sculptor of soils. Of all things, it is first.",
	Types.ICHOR : "[color=gray]Sanguine drops fallen from Helia's leaves and scattered so that all her subjects may prosper.",
	Types.PHOSPHOR : "[color=gray]Musky humor of earth & soil. Makes strong the root and beautiful the petal.",
	Types.AMBROSE : "[color=gray]Mineral of vitality and longevity. Emboldens the body and makes cowardly her enemies."
}

const GENERATION_WEIGHTS: Dictionary[Types, float] = {
	Types.NOTHING : 0.75, 
	Types.WATER : 0.125, 
	Types.ICHOR : 0.0416,
	Types.PHOSPHOR : 0.0416,
	Types.AMBROSE : 0.0416
}

const IMAGE_DIM := Vector2i(1024, 512)
const GRID_DIM := Vector2i(10, 10)

## Every "chunk" spawns one voronoi seed, which later becomes a resource vein.
## To find what resource vein you lie in the voronoi region of, first find the
## chunk you're in, and then compare distances of that chunk's and each of its
## neighbors' veins with your position.

# Key should be a chunk position
var _resource_veins: Dictionary[Vector2i, ResourceVein]

var _last_mouse_hover: ResourceVein

static func get_weighted_random_type() -> Types:
	const EPSILON := 0.001
	var point := randf()
	var sum := 0.0
	
	for i in range(len(GENERATION_WEIGHTS)):
		sum += GENERATION_WEIGHTS.values()[i]
		if (point <= sum + EPSILON):
			return GENERATION_WEIGHTS.keys()[i]
	assert(false, "Weights in table didn't add to 1.0! Perhaps EPSILON needs adjusting?")
	return Types.NOTHING

func get_resource_at(local_pos: Vector2) -> ResourceVein:
	if (local_pos.x < 0 or local_pos.x > IMAGE_DIM.x or local_pos.y < 0 or local_pos.y > IMAGE_DIM.y):
		return null
	
	return _get_containing_resource_vein(local_pos)

func _process(_delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var vein = get_resource_at(mouse_pos)
	
	if $Label.visible:
		$Label.position = mouse_pos
		$Label.text = "(%d, %d): %s" % [mouse_pos.x, mouse_pos.y, vein]
	
	if (vein == null):
		return
	
	vein.mouse_hover = true
	if (_last_mouse_hover != vein and _last_mouse_hover != null):
		_last_mouse_hover.mouse_hover = false
	_last_mouse_hover = vein

func _ready() -> void:
	GlobalLookups.soil_resources = get_path()
	
	DebugConsole.register_command(&"resource replenish", func():
		var modified := 0
		for vein: ResourceVein in _resource_veins.values():
			if (vein.remaining != vein.volume):
				modified += 1
			vein.remaining = vein.volume
		return "Replenished %d resource veins" % modified
	)
	
	DebugConsole.register_command(&"resource debug", func(): $Label.visible = !$Label.visible)
	
	# Just set SoilResources invisible if you dont want to wait on it generating.
	if (!visible):
		return
	
	_generate_resources()
	for vein in _resource_veins.values():
		if (vein.type == Types.NOTHING):
			continue
		add_child(vein)

func _generate_resources() -> void:
	print("Generating soil resources...")
	var t_start = Time.get_unix_time_from_system()
	
	@warning_ignore("integer_division")
	var chunk_size := IMAGE_DIM / GRID_DIM
	
	for y in range(GRID_DIM.y):
		for x in range(GRID_DIM.x):
			var vein = ResourceVein.new()
			vein.type = get_weighted_random_type()
			vein.origin = Vector2i(
				randi_range(x * chunk_size.x, x * chunk_size.x + chunk_size.x),
				randi_range(y * chunk_size.y, y * chunk_size.y + chunk_size.y)
			)
			_resource_veins[Vector2i(x, y)] = vein
			
			if (vein.type == Types.NOTHING):
				continue
			
			vein.image = Image.create_empty(IMAGE_DIM.x, IMAGE_DIM.y, false, Image.FORMAT_RGBA8)
			vein.image.fill(Color("transparent"))
	
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.005
	
	for y in range(IMAGE_DIM.y):
		for x in range(IMAGE_DIM.x):
			var vein = _get_containing_resource_vein(Vector2i(x, y))
			
			if (vein.type == Types.NOTHING):
				continue
			
			var normalized_richness = clamp(snapped(noise.get_noise_2d(x,y) + 0.75, 0.25), 0.0, 1.0)
			var richness := int(round(4 * normalized_richness))
			
			vein.pixel_volume += richness
			vein.update_bounds(Vector2i(x, y))
			if (richness > vein.peak_richness):
				vein.peak_richness = richness
			
			vein.image.set_pixel(x, y, Color(
				vein.color.r,
				vein.color.g,
				vein.color.b,
				vein.color.a * normalized_richness))
	
	print("...done (%.2fs)" % (Time.get_unix_time_from_system() - t_start))

func _get_containing_resource_vein(of: Vector2i) -> ResourceVein:
	@warning_ignore("integer_division")
	var chunk_pos = Vector2i(
		of.x / (IMAGE_DIM.x / GRID_DIM.x), 
		of.y / (IMAGE_DIM.y / GRID_DIM.y)
	)
	var neighbors = [
		_resource_veins.get(chunk_pos),
		_resource_veins.get(chunk_pos + Vector2i.UP),
		_resource_veins.get(chunk_pos + Vector2i.UP + Vector2i.LEFT),
		_resource_veins.get(chunk_pos + Vector2i.UP + Vector2i.RIGHT),
		_resource_veins.get(chunk_pos + Vector2i.DOWN),
		_resource_veins.get(chunk_pos + Vector2i.DOWN + Vector2i.LEFT),
		_resource_veins.get(chunk_pos + Vector2i.DOWN + Vector2i.RIGHT),
		_resource_veins.get(chunk_pos + Vector2i.LEFT),
		_resource_veins.get(chunk_pos + Vector2i.RIGHT)
	]
	var nearest_distance := INF
	var nearest: ResourceVein
	
	for vein in neighbors:
		if (vein == null):
			continue
		
		for origin in vein.origins:
			var dist = origin.distance_squared_to(of)
			if (dist < nearest_distance):
				nearest_distance = dist
				nearest = vein
	
	return nearest
