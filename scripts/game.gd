extends Node

func _ready():
	get_tree().root.connect("size_changed", self, "size_changed");
	size_changed();

func size_changed():
	var _scale: float;
	if OS.window_size.x > OS.window_size.y:
		_scale = OS.window_size.y / ProjectSettings.get_setting("display/window/size/height");
	else:
		_scale = OS.window_size.x / ProjectSettings.get_setting("display/window/size/width");
	$controller.scale = Vector2.ONE * _scale;
	$controller.position = Vector2(192 * $controller.scale.x, OS.window_size.y - 192 * $controller.scale.y);
