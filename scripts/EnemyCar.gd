extends PlayerCar
class_name CarCPU

func _physics_process(delta):
	if abs(rotation_degrees.x) >= 80 or abs(rotation_degrees.z) >= 80:
		FlippedTime += delta
	else:
		FlippedTime = 0
	
	
	if FlippedTime >= 2:
		rotation.x = 0
		rotation.z = 0
		position.y += 1
	
	if CanDrive:
		runsteering(delta)
		
		if $RayCast3D.get_collider() == GrassBody:
			GrassOn = true
		else:
			GrassOn = false
		
		
		if GrassOn:
			runengine(EnginePower * GrassMultipler)
		else:
			runengine(EnginePower)
