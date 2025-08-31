extends PlayerCar
class_name CarCPU

var TargetTransform : Transform3D

var Progress = 0

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
		
		TargetTransform = $"../Path3D".sample_track(Offset - 7)
		
		
		var TargetPosition = TargetTransform.origin
		
		$Sprite3D.global_position = TargetPosition
		
		var LocalTargetPosition = $Sprite3D.position
		BotSteering(delta,TargetPosition)
		
		if $RayCast3D.get_collider() == GrassBody:
			GrassOn = true
		else:
			GrassOn = false
		
		
		if GrassOn:
			runengine(EnginePower * GrassMultipler, true)
		else:
			runengine(EnginePower, true)

func BotSteering(delta, target):
	#this doesnt work im trying to fix that
	print(global_position.angle_to(target))
	steering = -global_position.angle_to(target)
	
	#the below works but i want a better one
	#if target.z > 3:
	#	steering = move_toward(steering, -MaxSteer, delta * 8)
	#if target.z < -3:
	#	steering = move_toward(steering, MaxSteer, delta * 8)
	
	
