extends VehicleBody3D
@export var MaxSteer = 0.9
@export var EnginePower = 300

@export var CanDrive = false

func _physics_process(delta):
	if CanDrive:
		steering = move_toward(steering, Input.get_axis("right","left") * MaxSteer, delta * 10)
		engine_force = Input.get_axis("down","up") * EnginePower
