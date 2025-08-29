extends CanvasLayer
@export var Car : VehicleBody3D


var Layers = 7

func _process(delta: float) -> void:
	$TextureProgressBar.value = Car.linear_velocity.distance_to(Vector3.ZERO)
	
	print($TextureProgressBar.value / $TextureProgressBar.max_value)
	
	
	
	$TextureRect/Circle2.position = Vector2(1.69 * Car.global_position.x,1.69925485378 * Car.global_position.z)
	$TextureRect/Circle2.position += $TextureRect.size / 2
	$TextureRect/Circle2.position -= $TextureRect/Circle2.pivot_offset

func do_tween(object : Node,property,newvalue,time):
	var NewTween = create_tween()
	NewTween.tween_property(object,property,newvalue,time)
	return NewTween.finished
