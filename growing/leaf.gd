extends Sprite2D

const VIEWPORT_DIM_BASE := Vector2(128, 128)

@export
var middle_tiles := 1
@export
var edge_points := 8

@export
var begin_curve: Curve
@export
var middle_curve: Curve
@export
var end_curve: Curve
@export
var z_curve: Curve

var size := 1.0

func _ready() -> void:
	_generate_mesh()

#func _process(delta: float) -> void:
	#if Input.is_action_pressed(&"camera_pan_right"):
		#$SubViewport/MeshInstance3D.rotate_y(delta)
	#if Input.is_action_pressed(&"camera_pan_left"):
		#$SubViewport/MeshInstance3D.rotate_y(-delta)
	#if Input.is_action_pressed(&"camera_pan_up"):
		#$SubViewport/MeshInstance3D.rotate_x(delta)
	#if Input.is_action_pressed(&"camera_pan_down"):
		#$SubViewport/MeshInstance3D.rotate_x(-delta)

func _input(event: InputEvent) -> void:
	if (event is InputEventKey and event.is_pressed() and event.keycode == Key.KEY_SLASH):
		size = randf()
		print(size)
		$SubViewport.size.x = (size * VIEWPORT_DIM_BASE).x
		_generate_mesh()

func _generate_mesh() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	st.set_normal(Vector3(0, 0, 1))
	
	_draw_curve(st, begin_curve, -(middle_tiles/2.0 + 1))
	for i in range(middle_tiles):
		_draw_curve(st, middle_curve, i - ((middle_tiles)/2.0))
	_draw_curve(st, end_curve, (middle_tiles/2.0))
	
	st.index()
	
	$SubViewport/MeshInstance3D.mesh = st.commit()

func _draw_curve(st: SurfaceTool, curve: Curve, x_offset: float) -> void:
	for point in range(0, edge_points + 1):
		var x := float(point) / edge_points
		var global_x := (x + x_offset) / (2 + middle_tiles) + 0.5
		
		st.set_uv(Vector2(global_x, 1))
		st.add_vertex(Vector3(size * (x + x_offset), -curve.sample(x), z_curve.sample(global_x)))
		st.set_uv(Vector2(global_x, 0))
		st.add_vertex(Vector3(size * (x + x_offset), curve.sample(x), z_curve.sample(global_x)))
