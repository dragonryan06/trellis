class_name ResourceVein
extends Sprite2D

const COLOR_TABLE: Dictionary[String, Color] = {
	"nothing" : Color("transparent"),
	"water" : Color("blue"),
	"ichor" : Color("green"),
	"phosphor" : Color("red"),
	"ambrose" : Color("orange")
}
const WEIGHT_TABLE: Dictionary[String, float] = {
	"nothing" : 0.75, 
	"water" : 0.125, 
	"ichor" : 0.0416,
	"phosphor" : 0.0416,
	"ambrose" : 0.0416
}

var mouse_hover := false:
	get():
		return mouse_hover
	set(value):
		mouse_hover = value
		set_instance_shader_parameter(&"mouse_hover", value)

var type: String

# The position of the voronoi seed that spawned this vein.
var origin: Vector2i:
	get():
		return origins[0]
	set(value):
		origins[0] = value

# The positions of all voronoi seeds in this vein, including ones merged in from neighborhood.
# NOTE: Merging is not implemented yet lmao
var origins: Array[Vector2i] = [Vector2i(-1, -1)]

var color: Color:
	get():
		return COLOR_TABLE[type]

var image: Image

var bounds := Rect2i(0, 0, 0, 0)

var volume := 0

var peak_richness := 0

func update_bounds(to_include: Vector2i) -> void:
	if (to_include.x < bounds.position.x):
		bounds.position.x = to_include.x
	if (to_include.y < bounds.position.y):
		bounds.position.y = to_include.y
	if (to_include.x > bounds.position.x + bounds.size.x):
		bounds.size.x = to_include.x - bounds.position.x
	if (to_include.y > bounds.position.y + bounds.size.y):
		bounds.size.y = to_include.y - bounds.position.y

func _ready() -> void:
	if (bounds.size.x > 0 and bounds.size.y > 0):
		image.crop(bounds.size.x, bounds.size.y)
	texture = ImageTexture.new()
	texture.set_image(image)
	position = bounds.position
	centered = false
	name = _to_string()
	material = ShaderMaterial.new()
	material.shader = load("res://generation/resource_vein.gdshader")
	set_instance_shader_parameter(&"levels", peak_richness)

func _to_string() -> String:
	return "%s (%d)" % [type, volume]
