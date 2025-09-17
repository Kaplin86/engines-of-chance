extends VehicleBody3D
class_name PlayerCar
#Exports
@export var MaxSteer = 0.9
@export var EnginePower = 300
@export var CanDrive = false
@export var GrassBody = null


var Laps = 0
var LapStatus = 0

var GrassMultipler = 0.5
var GrassOn = false

func _ready():
	for E in Variablesharer.playerCards:
		ActivateCard(E)

func SetWheelStatus(Mode, Tire : VehicleWheel3D): #A quick function to set a wheel to be 'front' or 'back'
	if Mode == "traction":
		Tire.use_as_steering = false
		Tire.use_as_traction = true
	else:
		Tire.use_as_steering = true
		Tire.use_as_traction = false

var FlippedTime = 0

func runflip(delta):
	if abs(rotation_degrees.x) >= 80 or abs(rotation_degrees.z) >= 80:
		FlippedTime += delta
	else:
		FlippedTime = 0
	
	
	if FlippedTime >= 2:
		rotation.x = 0
		rotation.z = 0
		position.y += 1

func _physics_process(delta):
	runflip(delta)
	
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
		
		var Pitch = ((linear_velocity.distance_to(Vector3(0,0,0)) / 15) * 2) + 1 #calculate the pitch based on the velocitys distance to 0,0,0. I use distance_to since thats a float
		
		$AudioStreamPlayer3D.pitch_scale = Pitch #the faster the engine, the higher the pitch
		if !$AudioStreamPlayer3D.playing:
			$AudioStreamPlayer3D.playing = true 
	else:
		$AudioStreamPlayer3D.playing = false #dont play engine audio when unable to drive

func runengine(power, bot = false):
	if bot:
		engine_force = power
	else:
		engine_force = Input.get_axis("down","up") * power #moves car 

func runsteering(delta):
	steering = move_toward(steering, Input.get_axis("right","left") * MaxSteer, delta * 8) #steer
	

func ActivateCard(cardname): # This will parse a card
	print(self, ' ', cardname)
	if cardname == "DoubleSpeed":
		EnginePower *= 1.5
		mass += 2
		$"../Speedomoter/TextureProgressBar".max_value *= 1.5
		#yeah uh no double speed causes car to flip so lets pretend it is double but dont tell anyone
	
	if cardname == "HalfSpeed":
		EnginePower /= 1.2
	
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
		$AudioStreamPlayer3D.volume_db = -40
	
	if cardname == "GrassCard":
		GrassMultipler = 0.9
	
	if cardname == "SpamCard":
		ADVERTISE()
	
	if cardname == "Ghost":
		set_collision_layer_value(1,0)
		var SurfaceMat : StandardMaterial3D = $MeshInstance3D.get_surface_override_material(0)
		var CurrentColor = SurfaceMat.albedo_color
		SurfaceMat.albedo_color = Color(CurrentColor.r,CurrentColor.g,CurrentColor.b,0.5)
		var nextPass : ShaderMaterial = SurfaceMat.next_pass
		nextPass.set_shader_parameter("outline_color",Color("8a000075"))
		SurfaceMat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

var PopupTypes = ["Gradient","Hi","New","SmilyFace2","SmilyFace"]

func ADVERTISE():
	var RNG = RandomNumberGenerator.new()
	await get_tree().create_timer(RNG.randf_range(5.0,10.0)).timeout
	var NewspamImage = Sprite2D.new()
	$Spam/spam.play()
	NewspamImage.texture = load("res://popups/"+ PopupTypes.pick_random()+".png")
	$Spam.add_child(NewspamImage)
	NewspamImage.position = Vector2(RNG.randf_range(65.0,255.0),RNG.randf_range(43.0,198.0))
	NewspamImage.scale.x = RNG.randf_range(0.9,1.1)
	NewspamImage.scale.y = NewspamImage.scale.x 
	ADVERTISE()
	await get_tree().create_timer(RNG.randf_range(1.0,3.0)).timeout
	NewspamImage.queue_free()

func NextRainbowColor(): #This gets started when the 'rainbow car' card is read
	var NewTween = create_tween()
	var CurrentAlbedoColor : Color = $MeshInstance3D.get_surface_override_material(0).albedo_color
	var NewValue = Color.from_hsv(CurrentAlbedoColor.h + 0.1,CurrentAlbedoColor.s,CurrentAlbedoColor.v,CurrentAlbedoColor.a) #find a new hue
	NewTween.tween_property($MeshInstance3D.get_surface_override_material(0),"albedo_color",NewValue,1)
	NewTween.finished.connect(NextRainbowColor) #Loops this function after the tween
