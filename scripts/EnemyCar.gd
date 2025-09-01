extends PlayerCar
class_name CarCPU

var TargetTransform : Transform3D

var Progress = 0
@export var TurnSpeed = 8
@export var Lookahead = 7
@export var LookOffset = -3

func _physics_process(delta):
	CanDrive = true
	
	if abs(rotation_degrees.x) >= 80 or abs(rotation_degrees.z) >= 80:
		FlippedTime += delta
	else:
		FlippedTime = 0
	
	
	if FlippedTime >= 2:
		rotation.x = 0
		rotation.z = 0
		position.y += 1
	
	
	if CanDrive:
		
		var PathCurve : Curve3D = $"../Path3D".curve
		var Offset = PathCurve.get_closest_offset(global_position)
		
		TargetTransform = $"../Path3D".sample_track(Offset - Lookahead)
		
		TargetTransform.origin += TargetTransform.basis.x * LookOffset
		
		var TargetPosition = TargetTransform.origin
		
		BotSteering(delta,to_local(TargetPosition))
		
		
		if $RayCast3D.get_collider() == GrassBody:
			GrassOn = true
		else:
			GrassOn = false
		
		
		if GrassOn:
			runengine(EnginePower * GrassMultipler, true)
		else:
			runengine(EnginePower, true)

func BotSteering(delta, target):
	var BindingNumber = 2
	if target.z > BindingNumber:
		steering = move_toward(steering, -MaxSteer, delta * TurnSpeed)
	if target.z < -BindingNumber:
		steering = move_toward(steering, MaxSteer, delta * TurnSpeed)
	if target.z < BindingNumber and target.z > -BindingNumber:
		steering = move_toward(steering, 0, delta * TurnSpeed)
	
	
