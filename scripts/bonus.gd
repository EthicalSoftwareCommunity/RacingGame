extends Area;

func init():
	connect("body_entered", self, "body_entered");
	monitoring = true;
	monitorable = true;
	get_node("collision").disabled = false;
	visible = true;

func body_entered(_body):
	if _body is RigidBody and _body.mode == RigidBody.MODE_RIGID and get_parent().vehicles.has(_body):
		get_parent().bonuses.erase(self);
		queue_free();
