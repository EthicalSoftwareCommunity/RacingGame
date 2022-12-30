extends Spatial;

var direction: Vector2;
var distance_maximum: float;
var bonuses = [];
var destructibles = [];
var objects = [];
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * -100;
export (float) var acceleration = 8192 * 2;
export (Array) var amount = [100, 100, 100];
export (Array) var distance = [0.04, 0.08, 0.06];
export (Array) var width = [0.06, 0.12, 0.06];

func _ready():
	randomize();
	distance_maximum = pow($torus.height, 2);
	$ball.translation = Vector3(0, -$torus.radius + 1, 0);
#	for _angle in range(90):
#		var _bonus = $bonus.duplicate();
#		add_child(_bonus);
#		bonuses.append(_bonus);
#		_bonus.transform = $torus.local_transform(_bonus, Vector2(0.495 + (_angle % 2) * 0.01, _angle / 90.0));
#		_bonus.translation = $torus.position(Vector2(0.495 + (_angle % 2) * 0.01, _angle / 90.0)) + $torus.normal(Vector2(0.495 + (_angle % 2) * 0.01, _angle / 90.0)) * 1;
#		_bonus.init();
#		if _angle % 2 == 0:
#			var _object = $static.duplicate();
#			add_child(_object);
#			objects.append(_object);
#			_object.transform = $torus.local_transform(_object, Vector2(0.475, (_angle + 0.25) / 45.0));
#			_object.translation = $torus.position(Vector2(0.475, (_angle + 0.25) / 45.0));
#			_object.init();
#			_object = $static.duplicate();
#			add_child(_object);
#			objects.append(_object);
#			_object.transform = $torus.local_transform(_object, Vector2(0.525, (_angle + 0.25) / 45.0));
#			_object.translation = $torus.position(Vector2(0.525, (_angle + 0.25) / 45.0));
#			_object.init();
#			_object = $destructible.duplicate();
#			add_child(_object);
#			_object.transform = $torus.local_transform(_object, Vector2(0.5, (_angle + 0.25) / 45.0));
#			_object.translation = $torus.position(Vector2(0.5, (_angle + 0.25) / 45.0));
#			_object.init();
	_generation();

func _physics_process(delta):
	$ball.engine_force = direction.y * acceleration * delta;
	$ball.steering = -direction.x / 4;
	for _object in [$ball] + destructibles:
		_object.add_central_force(gravity(_object) * delta);
	$camera.translation -= ($camera.translation - ($ball.to_global(Vector3(0, 1, 2)))) * delta * 16;
	$camera.rotation -= _get_camera_rotation($camera, $ball) * delta * 4;
	$camera.fov = 70 + $ball.linear_velocity.length() * 2;

func _get_camera_rotation(_camera, _target) -> Vector3:
	var _camera_rotation = _camera.rotation - _target.rotation;
	for _axis in range(3):
		if abs(_camera_rotation[_axis]) >= PI:
			_camera_rotation[_axis] = -sign(_camera_rotation[_axis]) * fmod((2 * PI - abs(_camera_rotation[_axis])), PI);
	return _camera_rotation;

func _generation():
	var _x: float;
	var _position: Vector2;
	var _angle: float;
	for _counter in amount[0]:
		_x = rand_range(0, $road.size.x);
		_position = $road.position(_x) + Vector2((distance[0] + rand_range(0, 1000 * width[0]) / 1000) * sign(rand_range(-1, 1)), 0);
		var _bonus = $bonus.duplicate();
		add_child(_bonus);
		bonuses.append(_bonus);
		_bonus.transform = $torus.local_transform(_bonus, _position);
		_bonus.translation = $torus.position(_position) + $torus.normal(_position) * 1;
		_bonus.init();
	for _counter in amount[1]:
		_x = rand_range(0, $road.size.x);
		_position = $road.position(_x) + Vector2((distance[1] + rand_range(0, 1000 * width[1]) / 1000) * sign(rand_range(-1, 1)), 0);
		var _object = $static.duplicate();
		add_child(_object);
		objects.append(_object);
		_object.transform = $torus.local_transform(_object, _position);
		_object.translation = $torus.position(_position);
		_object.init();
	for _counter in amount[2]:
		_x = rand_range(0, $road.size.x);
		_position = $road.position(_x) + Vector2((distance[2] + rand_range(0, 1000 * width[2]) / 1000) * sign(rand_range(-1, 1)), 0);
		var _object = $destructible.duplicate();
		add_child(_object);
		objects.append(_object);
		_object.transform = $torus.local_transform(_object, _position);
		_object.translation = $torus.position(_position);
		_object.init();

func gravity(object):
	var _ray = get_node("ray");
	var _gravity: Vector3;
	var _distance: float = distance_maximum;
	for _direction in PoolVector3Array([Vector3(distance_maximum, 0, 0), Vector3(-distance_maximum, 0, 0), Vector3(0, distance_maximum, 0), Vector3(0, -distance_maximum, 0), Vector3(0, 0, distance_maximum), Vector3(0, 0, -distance_maximum)]):
		_ray.get_parent().remove_child(_ray);
		object.add_child(_ray);
		_ray.cast_to = _direction;
		_ray.force_raycast_update();
		if _ray.is_colliding() and _ray.get_collision_point().distance_squared_to(object.translation) < _distance:
			_distance = _ray.get_collision_point().distance_squared_to(object.translation);
			_gravity = _ray.get_collision_normal();
	_ray.get_parent().remove_child(_ray);
	add_child(_ray);
	return object.mass * gravity * _gravity;
