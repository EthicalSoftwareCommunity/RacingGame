extends Spatial;

var direction: Vector2;
var _distance_maximum: float;
export (float) var acceleration = 1024;
export (float) var gravity = 980;

func _ready():
	gravity *= -100;
	_distance_maximum = pow($torus.height, 2);
	$ball.translation = Vector3(0, 0, $torus.radius / 2);

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
	ball_move(Vector3(direction.x, 0, direction.y) * delta + _gravity);
	$camera.translation = $ball.translation - Vector3(0, 0, -4);

func ball_move(_vector):
	$ball.add_central_force(_vector);
