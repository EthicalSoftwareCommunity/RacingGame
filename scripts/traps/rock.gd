extends Area;

func init():
	connect("body_entered", self, "body_entered");
	monitoring = true;
	monitorable = true;
	get_node("collision").disabled = false;
	visible = true;

func body_entered(_body):
	if _body is VehicleBody:
		disconnect("body_entered", self, "body_entered");
		$warning.visible = false;
		var _rock = $rock;
		var _transform = _rock.global_transform;
		_rock.mode = RigidBody.MODE_RIGID;
		_rock.set_collision_mask_bit(0, true);
		get_parent().objects.append(_rock);
		remove_child(_rock);
		get_parent().add_child(_rock);
		_rock.transform = _transform;
		_rock.apply_central_impulse(_rock.to_global(Vector3(1536, -768, 0)) - _rock.global_translation);
		_rock.visible = true;
		yield(get_tree().create_timer(3.0), "timeout");
		get_parent().objects.erase(_rock);
		_rock.queue_free();
		queue_free();
