extends MeshInstance;

var body = StaticBody.new();
var collision = CollisionShape.new();
export (Vector2) var size = Vector2(8, 16);
export (int) var height = 8;
export (int) var radius = 32;

func _ready():
	add_child(body);
	body.add_child(collision);
	var _data = [];
	var _vectors = PoolVector3Array();
	_data.resize(ArrayMesh.ARRAY_MAX);
	for _x in range(size.x):
		for _y in range(size.y):
			if _y == 0:
				_vectors.append(Vector3(0, 0, 0));
				_vectors.append(Vector3(radius * sin(PI / size.y * (_y + 1)) * sin(2 * PI / size.x * _x), _shape(PI / size.y * (_y + 1)), radius * sin(PI / size.y * (_y + 1)) * cos(2 * PI / size.x * _x)));
				_vectors.append(Vector3(radius * sin(PI / size.y * (_y + 1)) * sin(2 * PI / size.x * (_x + 1)), _shape(PI / size.y * (_y + 1)), radius * sin(PI / size.y * (_y + 1)) * cos(2 * PI / size.x * (_x + 1))));
			elif _y == size.y - 1:
				_vectors.append(_vectors[-2]);
				_vectors.append(Vector3(0, 0, 0));
				_vectors.append(_vectors[-3]);
			else:
				_vectors.append(_vectors[-2]);
				_vectors.append(Vector3(radius * sin(PI / size.y * (_y + 1)) * sin(2 * PI / size.x * _x), _shape(PI / size.y * (_y + 1)), radius * sin(PI / size.y * (_y + 1)) * cos(2 * PI / size.x * _x)));
				_vectors.append(_vectors[-3]);
				_vectors.append(_vectors[-1]);
				_vectors.append(_vectors[-3]);
				_vectors.append(Vector3(radius * sin(PI / size.y * (_y + 1)) * sin(2 * PI / size.x * (_x + 1)), _shape(PI / size.y * (_y + 1)), radius * sin(PI / size.y * (_y + 1)) * cos(2 * PI / size.x * (_x + 1))));
	_data[ArrayMesh.ARRAY_VERTEX] = _vectors;
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _data);
	collision.shape = mesh.create_trimesh_shape();

func _shape(_data):
	return height * sin(PI - _data * 2);
