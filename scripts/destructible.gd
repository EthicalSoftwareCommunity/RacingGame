extends Area;

func init():
	connect("body_entered", self, "body_entered");
	monitoring = true;
	monitorable = true;
	get_node("collision").disabled = false;
	visible = true;

func body_entered(_body):
	if _body is RigidBody and not _body.mode == RigidBody.MODE_STATIC:
		disconnect("body_entered", self, "body_entered");
		for _part in [get_node("head"), get_node("torso"), get_node("legs")]:
			var _transform = _part.global_transform;
			_part.mode = RigidBody.MODE_RIGID;
			_part.set_collision_mask_bit(0, true);
			get_parent().objects.append(_part);
			remove_child(_part);
			get_parent().add_child(_part);
			_part.transform = _transform;
		queue_free();
