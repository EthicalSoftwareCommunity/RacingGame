extends Spatial;

var direction: Vector2;
var _distance_maximum: float;
export (float) var acceleration = 2048;
export (float) var gravity = 9.8;

func _ready():
	gravity *= -$ball.mass * 10;
	_distance_maximum = pow($torus.height, 2);
	$ball.translation = Vector3(0, -$torus.radius + 1, 0);

func _physics_process(delta):
	var _gravity: Vector3;
	var _distance: float = _distance_maximum;
	for _direction in PoolVector3Array([Vector3(_distance_maximum, 0, 0), Vector3(-_distance_maximum, 0, 0), Vector3(0, _distance_maximum, 0), Vector3(0, -_distance_maximum, 0), Vector3(0, 0, _distance_maximum), Vector3(0, 0, -_distance_maximum)]):
		$ball/ray.cast_to = _direction;
		$ball/ray.force_raycast_update();
		if $ball/ray.is_colliding() and $ball/ray.get_collision_point().distance_squared_to($ball.translation) < _distance:
			_distance = $ball/ray.get_collision_point().distance_squared_to($ball.translation);
			_gravity = $ball/ray.get_collision_normal();
	_gravity *= gravity * delta;
	$ball.engine_force = direction.y * acceleration * delta;
	$ball.steering = -direction.x / 2;
	$ball.add_central_force(_gravity);
	$camera.translation -= ($camera.translation - ($ball.to_global(Vector3(0, 1, 2)))) * delta * 16;
	$camera.rotation -= _get_camera_rotation($camera, $ball) * delta * 6;
	$camera.fov = 70 + $ball.linear_velocity.length() * 2;

func _get_camera_rotation(_camera, _target) -> Vector3:
	var _camera_rotation = _camera.rotation - _target.rotation;
	for _axis in range(3):
		if abs(_camera_rotation[_axis]) >= PI:
			_camera_rotation[_axis] = -sign(_camera_rotation[_axis]) * fmod((2 * PI - abs(_camera_rotation[_axis])), PI);
	return _camera_rotation;
