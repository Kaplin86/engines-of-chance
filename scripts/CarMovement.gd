extends VehicleBody3D

#Exports
@export var MaxSteer = 0.9
@export var EnginePower = 300
@export var CanDrive = false
@export var GrassBody = null

var GrassMultipler = 0.1
var GrassOn = false

func SetWheelStatus(Mode, Tire : VehicleWheel3D): #A quick function to set a wheel to be 'front' or 'back'
	if Mode == "traction":
		Tire.use_as_steering = false
		Tire.use_as_traction = true
	else:
		Tire.use_as_steering = true
		Tire.use_as_traction = false

func _physics_process(delta):
	
	if CanDrive:
		steering = move_toward(steering, Input.get_axis("right","left") * MaxSteer, delta * 8) #steer
		
		if $RayCast3D.get_collider() == GrassBody:
			GrassOn = true
		else:
			GrassOn = false
		
		
		if GrassOn:
			engine_force = Input.get_axis("down","up") * EnginePower * GrassMultipler #moves car 
		else:
			engine_force = Input.get_axis("down","up") * EnginePower #moves car 
		
		var Pitch = ((linear_velocity.distance_to(Vector3(0,0,0)) / 15) * 2) + 1 #calculate the pitch based on the velocitys distance to 0,0,0. I use distance_to since thats a float
		
		$AudioStreamPlayer3D.pitch_scale = Pitch #the faster the engine, the higher the pitch
		if !$AudioStreamPlayer3D.playing:
			$AudioStreamPlayer3D.playing = true 
	else:
		$AudioStreamPlayer3D.playing = false #dont play engine audio when unable to drive

func ActivateCard(cardname): # This will parse a card
	
	if cardname == "DoubleSpeed":
		EnginePower *= 1.5
		mass += 2
		#yeah uh no double speed causes car to flip so lets pretend it is double but dont tell anyone
	
	if cardname == "HalfSpeed":
		EnginePower /= 2
	
	if cardname == "ReversedWheels":
		SetWheelStatus("traction",$FrontRight)
		SetWheelStatus("traction",$FrontLeft)
		SetWheelStatus("steering",$BackRight)
		SetWheelStatus("steering",$BackLeft)
	
	if cardname == "HeavyCar":
		mass += 10
	
	if cardname == "LightCar":
		mass -= 10
	
	if cardname == "Reaction":
		$LiveReaction/LiveReactionChild.visible = true
		$LiveReaction/LiveReactionChild/Chara.texture = $"../Character".get_texture() 
	
	if cardname == "RainbowCar":
		NextRainbowColor()
	
	if cardname == "DriverView":
		$"../Camera3D".camera_mode = $"../Camera3D".CameraMode.DriverView
		$"../Camera3D".fov = 102.1
	

func NextRainbowColor(): #This gets started when the 'rainbow car' card is read
	var NewTween = create_tween()
	var CurrentAlbedoColor : Color = $MeshInstance3D.get_surface_override_material(0).albedo_color
	var NewValue = Color.from_hsv(CurrentAlbedoColor.h + 0.1,CurrentAlbedoColor.s,CurrentAlbedoColor.v,CurrentAlbedoColor.a) #find a new hue
	NewTween.tween_property($MeshInstance3D.get_surface_override_material(0),"albedo_color",NewValue,1)
	NewTween.finished.connect(NextRainbowColor) #Loops this function after the tween
