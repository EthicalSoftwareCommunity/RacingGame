extends MeshInstance;

var body = StaticBody.new();
var collision = CollisionShape.new();
export (Vector2) var size = Vector2(64, 256);
export (int) var height = 64;
export (int) var radius = 256;

func _ready():
	add_child(body);
	body.add_child(collision);
	body.set_collision_layer_bit(31, true);
	var _data = [];
	var _vectors = PoolVector3Array();
	_data.resize(ArrayMesh.ARRAY_MAX);
	for _x in range(size.x):
		for _y in range(size.y):
			if _y == 0:
				_vectors.append(Vector3(0, 0, 0));
				_vectors.append(Vector3(radius * sin(PI / size.y * (_y + 1)) * sin(2 * PI / size.x * _x), height * shape(PI / size.y * (_y + 1)), radius * sin(PI / size.y * (_y + 1)) * cos(2 * PI / size.x * _x)));
				_vectors.append(Vector3(radius * sin(PI / size.y * (_y + 1)) * sin(2 * PI / size.x * (_x + 1)), height * shape(PI / size.y * (_y + 1)), radius * sin(PI / size.y * (_y + 1)) * cos(2 * PI / size.x * (_x + 1))));
			elif _y == size.y - 1:
				_vectors.append(_vectors[-2]);
				_vectors.append(Vector3(0, 0, 0));
				_vectors.append(_vectors[-3]);
			else:
				_vectors.append(_vectors[-2]);
				_vectors.append(Vector3(radius * sin(PI / size.y * (_y + 1)) * sin(2 * PI / size.x * _x), height * shape(PI / size.y * (_y + 1)), radius * sin(PI / size.y * (_y + 1)) * cos(2 * PI / size.x * _x)));
				_vectors.append(_vectors[-3]);
				_vectors.append(_vectors[-1]);
				_vectors.append(_vectors[-3]);
				_vectors.append(Vector3(radius * sin(PI / size.y * (_y + 1)) * sin(2 * PI / size.x * (_x + 1)), height * shape(PI / size.y * (_y + 1)), radius * sin(PI / size.y * (_y + 1)) * cos(2 * PI / size.x * (_x + 1))));
	_data[ArrayMesh.ARRAY_VERTEX] = _vectors;
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _data);
	collision.shape = mesh.create_trimesh_shape();

func shape(data):
	return sin(PI - data * 2);

#Vector2 type variable is used for the calculation.
#x — latitude
#y — longitude
func position(vector):
	return to_global(Vector3(radius * sin(PI * vector.x) * sin(2 * PI * vector.y), height * shape(PI * vector.x), radius * sin(PI * vector.x) * cos(2 * PI * vector.y)));

func normal(vector):
	var _points = [position(vector), position(Vector2(vector.x, vector.y - 0.0001)), position(Vector2(vector.x + 0.0001, vector.y))];
	return (_points[0] - _points[1]).normalized().rotated((_points[0] - _points[2]).normalized(), PI / 2);

func local_transform(_object, vector):
	var _transform = _object.transform;
	var _normal = normal(vector);
	_transform.basis.y = _normal;
	_transform.basis.x = -_transform.basis.z.cross(_normal);
	return _transform.basis.orthonormalized();
