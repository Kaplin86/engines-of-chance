extends VehicleBody3D
@export var MaxSteer = 0.9
@export var EnginePower = 300

@export var CanDrive = false



func SetWheelStatus(Mode, Tire : VehicleWheel3D):
	if Mode == "traction":
		Tire.use_as_steering = false
		Tire.use_as_traction = true
	else:
		Tire.use_as_steering = true
		Tire.use_as_traction = false

func _physics_process(delta):
	if CanDrive:
		steering = move_toward(steering, Input.get_axis("right","left") * MaxSteer, delta * 10)
		engine_force = Input.get_axis("down","up") * EnginePower

func ActivateCard(cardname):
	if cardname == "DoubleSpeed":
		EnginePower *= 2
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
		mass += 10
	if cardname == "Reaction":
		$LiveReaction/LiveReactionChild.visible = true
		$LiveReaction/LiveReactionChild/Chara.texture = $"../Character".get_texture() 
	if cardname == "RainbowCar":
		NextRainbowColor()

func NextRainbowColor():
	var NewTween = create_tween()
	var CurrentAlbedoColor : Color = $MeshInstance3D.get_surface_override_material(0).albedo_color
	var NewValue = Color.from_hsv(CurrentAlbedoColor.h + 0.1,CurrentAlbedoColor.s,CurrentAlbedoColor.v,CurrentAlbedoColor.a)
	NewTween.tween_property($MeshInstance3D.get_surface_override_material(0),"albedo_color",NewValue,1)
	NewTween.finished.connect(NextRainbowColor)
