extends Control

onready var _world: = get_node("/root/game/world");

func _ready():
	$button_left.connect("button_down", self, "turn", [[true, -1]]);
	$button_left.connect("button_up", self, "turn", [[false]]);
	$button_right.connect("button_down", self, "turn", [[true, 1]]);
	$button_right.connect("button_up", self, "turn", [[false]]);

func turn(data):
	if data[0]:
		_world.vehicle.direction.x = data[1];
	else:
		_world.vehicle.direction.x = 0;
