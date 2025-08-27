extends CanvasLayer
@export var Car : VehicleBody3D

var Tier = 0
var MaxTier = 4

func _process(delta: float) -> void:
	$TextureProgressBar.value = Car.linear_velocity.distance_to(Vector3.ZERO)
