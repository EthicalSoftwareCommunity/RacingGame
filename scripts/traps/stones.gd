extends Area;

func init():
	connect("body_entered", self, "body_entered");
	monitoring = true;
	monitorable = true;
	get_node("collision").disabled = false;
	visible = true;

func body_entered(_body):
	if _body is RigidBody and _body.mode == RigidBody.MODE_RIGID and get_parent().vehicles.has(_body):
		disconnect("body_entered", self, "body_entered");
		$warning.visible = false;
		var _stones = [get_node("stone_1"), get_node("stone_2"), get_node("stone_3"), get_node("stone_4"), get_node("stone_5")];
		for _stone in _stones:
			var _transform = _stone.global_transform;
			_stone.mode = RigidBody.MODE_RIGID;
			_stone.set_collision_mask_bit(0, true);
			get_parent().objects.append(_stone);
			remove_child(_stone);
			get_parent().add_child(_stone);
			_stone.transform = _transform;
			_stone.apply_central_impulse(_stone.to_global(Vector3(1024, -512, 0)) - _stone.global_translation);
			_stone.visible = true;
		yield(get_tree().create_timer(3.0), "timeout");
		for _stone in _stones:
			get_parent().objects.erase(_stone);
			_stone.queue_free();
		queue_free();
