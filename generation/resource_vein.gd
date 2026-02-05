class_name ResourceVein

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

var type: String

# The position of the voronoi seed that spawned this vein.
var position: Vector2i:
	get():
		return positions[0]
	set(value):
		positions[0] = value

# All voronoi seed positions in this vein, including merged neighbors.
var positions: Array[Vector2i] = [Vector2i(-1, -1)]

var color: Color:
	get():
		return COLOR_TABLE[type]

var volume := 0

func _to_string() -> String:
	return "%s (%d)" % [type, volume]
