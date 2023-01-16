extends Spatial;

#var direction: Vector2;
var distance_maximum: float;
var bonuses = [];
var objects = [];
var vehicles = [];
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * -100;
export (float) var acceleration = 8192 * 2;
export (Array) var amount = [100, 100, 100, 100];
export (Array) var distance = [0.04, 0.08, 0.12, 0.06];
export (Array) var width = [0.06, 0.12, 0.04, 0.06];
onready var vehicle = get_node("vehicle");

#func _init():
	#VisualServer.set_debug_generate_wireframes(true);

func _ready():
	randomize();
	#get_viewport().debug_draw = 3;
	distance_maximum = $torus.height;
	vehicle.translation = Vector3(0, -$torus.radius + 1, 0);
	vehicles.append(vehicle);
	_generation();

func _process(delta):
	vehicle.model.transform.origin += (vehicle.transform.origin - vehicle.model.transform.origin) * 8 * delta;
	vehicle.model.global_transform = vehicle.model.global_transform.interpolate_with(align_with_y(vehicle.model.global_transform, vehicle.gravity[1]), 8 * delta);

	vehicle.model.global_transform.basis = vehicle.model.global_transform.basis.slerp(vehicle.model.global_transform.basis.rotated(vehicle.model.global_transform.basis.y, -vehicle.direction.x / 4), 4 * delta);
	vehicle.model.global_transform = vehicle.model.global_transform.orthonormalized();

func _physics_process(delta):
	vehicle.gravity = gravity(vehicle);
	vehicle.add_central_force(vehicle.gravity[0] * delta * 4);
	for _object in objects:
		_object.add_central_force(gravity(_object)[0] * delta);

	$camera.translation -= ($camera.translation - (vehicle.model.to_global(Vector3(0, 1, 2)))) * delta * 16;
	$camera.rotation -= _get_camera_rotation($camera, vehicle.model) * delta * 4;
	$camera.fov = 70 + vehicle.model.linear_velocity.length() * 2;

func _get_camera_rotation(_camera, _target) -> Vector3:
	var _camera_rotation = _camera.rotation - _target.rotation;
	for _axis in range(3):
		if abs(_camera_rotation[_axis]) >= PI:
			_camera_rotation[_axis] = -sign(_camera_rotation[_axis]) * fmod((2 * PI - abs(_camera_rotation[_axis])), PI);
	return _camera_rotation;

func _generation():
	var _x: float;
	var _position: Vector2;
	for _counter in amount[0]:
		_x = rand_range(0, $road.size.x);
		_position = $road.position(_x) + Vector2((distance[0] + rand_range(0, 1000 * width[0]) / 1000) * sign(rand_range(-1, 1)), 0);
		var _bonus = get_node(["bonus_coin", "bonus_crystal"][randi() % 2]).duplicate();
		add_child(_bonus);
		bonuses.append(_bonus);
		_bonus.transform = $torus.local_transform(_bonus, _position);
		_bonus.translation = $torus.position(_position) + $torus.normal(_position) * 1;
		_bonus.init();
	for _counter in amount[1]:
		_x = rand_range(0, $road.size.x);
		_position = $road.position(_x) + Vector2((distance[1] + rand_range(0, 1000 * width[1]) / 1000) * sign(rand_range(-1, 1)), 0);
		var _object = $static_tree.duplicate();
		add_child(_object);
		_object.transform = $torus.local_transform(_object, _position);
		_object.translation = $torus.position(_position);
		_object.init();
	for _counter in amount[2]:
		_x = rand_range(0, $road.size.x);
		_position = $road.position(_x) + Vector2((distance[2] + rand_range(0, 1000 * width[2]) / 1000) * sign(rand_range(-1, 1)), 0);
		var _object = $static_rock.duplicate();
		add_child(_object);
		_object.transform = $torus.local_transform(_object, _position);
		_object.translation = $torus.position(_position);
		_object.init();
	for _counter in amount[3]:
		_x = rand_range(0, $road.size.x);
		_position = $road.position(_x) + Vector2((distance[3] + rand_range(0, 1000 * width[3]) / 1000) * sign(rand_range(-1, 1)), 0);
		var _object = $destructible.duplicate();
		add_child(_object);
		_object.transform = $torus.local_transform(_object, _position);
		_object.translation = $torus.position(_position);
		_object.init();
	for _counter in range(30):
		_x = rand_range(0, $road.size.x);
		_position = $road.position(_x);
		var _angle = $torus.normal($road.position(_x));
		var _object = get_node(["trap_rock", "trap_stones", "trap_spikes"][randi() % 3]).duplicate();
		add_child(_object);
		_object.transform = $torus.local_transform(_object, _position);
		_object.rotate_object_local(Vector3.UP, $road.angle(_x));
		_object.translation = $torus.position(_position) + $torus.normal(_position) * 0.5;
		_object.init();
#	for _counter in range($road.size.x / 4):
#		var _position1 = $torus.position($road.position(_counter * 4));
#		var _object = $label.duplicate();
#		add_child(_object);
#		_object.visible = true;
#		_object.translation = _position1 + $torus.normal($road.position(_counter * 4));
#		_object.text = str(rad2deg($road.angle(_counter * 4)));

func gravity(object):
	var _ray = get_node("ray");
	var _gravity: Vector3;
	var _distance: float = distance_maximum;
	var _normal: Vector3;
	#var _ray_counter: int = 0;
	var _ray_distance: float;
	var _ray_normal: Vector3;
	for _direction in PoolVector3Array([Vector3(distance_maximum, 0, 0), Vector3(-distance_maximum, 0, 0), Vector3(0, distance_maximum, 0), Vector3(0, -distance_maximum, 0), Vector3(0, 0, distance_maximum), Vector3(0, 0, -distance_maximum)]):
		_ray.get_parent().remove_child(_ray);
		object.add_child(_ray);
		_ray.cast_to = _direction;
		_ray.force_raycast_update();
		if _ray.is_colliding():
			#_ray_counter += 1;
			_ray_distance = _ray.get_collision_point().distance_to(object.translation);
			_ray_normal = _ray.get_collision_normal();
			_normal += _ray_normal / _ray_distance;
			if _ray_distance < _distance:
				_distance = _ray_distance;
				_gravity = _ray_normal;
	_ray.get_parent().remove_child(_ray);
	add_child(_ray);
	return [object.mass * gravity * _gravity, _normal.normalized()];

func align_with_y(xform, new_y):
	xform.basis.y = new_y;
	xform.basis.x = -xform.basis.z.cross(new_y);
	xform.basis = xform.basis.orthonormalized();
	return xform;
