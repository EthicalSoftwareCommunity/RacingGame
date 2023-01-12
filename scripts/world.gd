extends Spatial;

var direction: Vector2;
var distance_maximum: float;
var bonuses = [];
var objects = [];
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * -100;
export (float) var acceleration = 8192 * 2;
export (Array) var amount = [100, 100, 100];
export (Array) var distance = [0.04, 0.08, 0.06];
export (Array) var width = [0.06, 0.12, 0.06];

#func _init():
	#VisualServer.set_debug_generate_wireframes(true);

func _ready():
	randomize();
	#get_viewport().debug_draw = 3;
	distance_maximum = pow($torus.height, 2);
	$ball.translation = Vector3(0, -$torus.radius + 1, 0);
	_generation();

func _physics_process(delta):
	$ball.engine_force = direction.y * acceleration * delta;
	$ball.steering = -direction.x / 4;
	for _object in [$ball] + objects:
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
		#objects.append(_object);
		_object.transform = $torus.local_transform(_object, _position);
		_object.translation = $torus.position(_position);
		_object.init();
	for _counter in amount[2]:
		_x = rand_range(0, $road.size.x);
		_position = $road.position(_x) + Vector2((distance[2] + rand_range(0, 1000 * width[2]) / 1000) * sign(rand_range(-1, 1)), 0);
		var _object = $destructible.duplicate();
		add_child(_object);
		#objects.append(_object);
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
