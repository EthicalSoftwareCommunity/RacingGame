extends MeshInstance;

var body = StaticBody.new();
var collision = CollisionShape.new();
#Vector2 type variable is used for the calculation.
#x — latitude curve modifier, must be a multiple of 2
#y — longitude curve modifier, must be between 0 and 1
export (Vector2) var modifier = Vector2.ONE;
export (Vector2) var size = Vector2(1024, 8);
export (float) var height = 0.325;
export (float) var width = 0.01;
onready var _torus = get_parent().get_node("torus");

func _ready():
	add_child(body);
	body.add_child(collision);
	body.set_collision_layer_bit(31, true);
	var _data = [];
	var _positions = [];
	var _vectors = PoolVector3Array();
	_data.resize(ArrayMesh.ARRAY_MAX);
	for _x in range(size.x):
		for _y in range(size.y):
			_vectors += _road_segment(Vector2(_x, _y));
	_data[ArrayMesh.ARRAY_VERTEX] = _vectors;
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _data);
	collision.shape = mesh.create_trimesh_shape();

func _road_segment(vector):
	var _positions = [position(vector.x), position(vector.x + 1), position(vector.x + 2)];
	var _angles = [
		-angle(vector.x),
		-angle(vector.x + 1)
	];
	if _positions[0].y > 0.125:
		pass;
	var _vectors = PoolVector3Array();
	var _vectors_positions = [
		_positions[0] + Vector2(-width / 2 + vector.y / size.y * width, 0).rotated(_angles[0]),
		_positions[0] + Vector2(-width / 2 + (vector.y + 1) / size.y * width, 0).rotated(_angles[0]),
		_positions[1] + Vector2(-width / 2 + vector.y / size.y * width, 0).rotated(_angles[1]),
		_positions[1] + Vector2(-width / 2 + (vector.y + 1) / size.y * width, 0).rotated(_angles[1])
	];
	_vectors.append(_torus.position(_vectors_positions[0]) + _torus.normal(_vectors_positions[0]) * height);
	_vectors.append(_torus.position(_vectors_positions[1]) + _torus.normal(_vectors_positions[1]) * height);
	_vectors.append(_torus.position(_vectors_positions[2]) + _torus.normal(_vectors_positions[2]) * height);
	_vectors.append(_vectors[-1]);
	_vectors.append(_vectors[-3]);
	_vectors.append(_torus.position(_vectors_positions[3]) + _torus.normal(_vectors_positions[3]) * height);
	return _vectors;

func angle(x):
	return atan(cos(x / size.x * PI * 2 * modifier.x) * (modifier.x * modifier.y));

func position(x):
	var _angle = x / size.x * PI * 2 * modifier.x;
	return Vector2(0.5 + sin(_angle) / 2 * modifier.y, x / size.x);
