extends TouchScreenButton;

var _touch: bool;
onready var _controller: = get_parent();
onready var _world: = get_node("/root/game/world");

func _input(event):
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed()):
		if event is InputEventScreenTouch:
			if (event.position - _controller.position).length() <= 128 * _controller.scale.x:
				_touch = true;
			else:
				_touch = false;
		if _touch:
			set_global_position(event.position - Vector2(48, 48) * _controller.scale.x);
			if (event.position - _controller.position).length() > 80 * _controller.scale.x:
				set_position((event.position - _controller.position).normalized() * 80 - Vector2(48, 48));
			_world.vehicle.direction = (event.position - _controller.position).normalized() * (get_global_position() + Vector2(48, 48) - _controller.position).length() / 80;
	elif event is InputEventScreenTouch and not event.is_pressed():
		set_position(Vector2.ZERO - Vector2(48, 48));
		_world.vehicle.direction = Vector2.ZERO;
