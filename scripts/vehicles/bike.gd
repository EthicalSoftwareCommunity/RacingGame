extends RigidBody;

var direction: Vector2;
var gravity;
onready var model = get_parent().get_node("model");

func _integrate_forces(state):
	if direction.x != 0:
	#if Input.is_action_pressed("control_brake"):
		linear_damp = 2;
	else:
		linear_damp = 6;
	state.apply_central_impulse(-model.global_transform.basis.z * 48 * linear_damp);
