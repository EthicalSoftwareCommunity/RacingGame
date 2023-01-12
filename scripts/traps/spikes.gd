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
		$spikes.visible = true;
		$animation.play("up");
