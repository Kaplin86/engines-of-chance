extends Node3D

@export var PlayerCarNode : PlayerCar
@export var PathTrack : TrackPath

var BaseCar = preload("res://car.tscn")
var CPUScript = preload("res://scripts/EnemyCar.gd")


#var DriverCount = 3
var DriverCount = 15
var Drivers = []



var RNG = RandomNumberGenerator.new()

var StartingPoint = 0



func set_drive():
	for E in Drivers:
		E.CanDrive = true
	Drivers.append(PlayerCarNode)

func _ready():
	var Rows = ceil(DriverCount / 3)
	for E in Rows:
		for B in 3:
			if E == 0 and B == 1:
				$Path3D/PathFollow3D.progress = 10 * (E + 1 - (B * 0.2)) + StartingPoint
				$Path3D/PathFollow3D.rotation_mode = PathFollow3D.ROTATION_ORIENTED
				PlayerCarNode.global_transform = $Path3D/PathFollow3D/Node3D.global_transform
				PlayerCarNode.rotation_degrees += Vector3(0,180,0)
				
				
				PlayerCarNode.global_position += (PlayerCarNode.basis.z * ((B - 1) * 5))
			else:
				var NewScene = BaseCar.instantiate()
				
				
				var NewCarMesh : MeshInstance3D = NewScene.get_node("MeshInstance3D")
				var Mat : StandardMaterial3D
				if NewCarMesh.get_surface_override_material(0):
					Mat = NewCarMesh.get_surface_override_material(0).duplicate()
					NewCarMesh.set_surface_override_material(0,Mat)
					Mat.albedo_color = Color.from_hsv(RNG.randf(),Mat.albedo_color.s,Mat.albedo_color.v)
					Mat.next_pass = Mat.next_pass.duplicate()
					var ShaderResource : ShaderMaterial = Mat.next_pass
					ShaderResource.set_shader_parameter("outline_color",Color.from_hsv(Mat.albedo_color.h - 0.05, Mat.albedo_color.s,Mat.albedo_color.v - 0.54)) 
				
				Drivers.append(NewScene)
				
				
				NewScene.set_script(CPUScript)
				add_child(NewScene)
				var NewDriver : CarCPU = NewScene
				
				$Path3D/PathFollow3D.progress = 10 * (E + 1 - (B * 0.2)) + StartingPoint
				$Path3D/PathFollow3D.rotation_mode = PathFollow3D.ROTATION_ORIENTED
				NewDriver.global_transform = $Path3D/PathFollow3D/Node3D.global_transform
				NewDriver.rotation_degrees += Vector3(0,180,0)
				
				
				NewDriver.global_position += (NewDriver.basis.z * ((B - 1) * 5))
				
				NewDriver.visible = true
				NewDriver.GrassBody = $map.Grassbody

				
				
				
				NewScene.set_script(CPUScript)
				
				NewDriver.mass = 60
				NewDriver.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
				NewDriver.center_of_mass = Vector3(0,-0.1,0)
				
				NewDriver.MaxSteer = 0.5
				NewDriver.EnginePower = 125 + RNG.randi_range(-1,1)
				
				NewDriver.Lookahead = RNG.randi_range(6,8)
				NewDriver.TurnSpeed = RNG.randi_range(7,9)
				NewDriver.LookOffset = RNG.randi_range(-3,3)
				NewDriver.CanDrive = false
				
				NewDriver.freeze = false
				
				var MinimapIcon = TextureRect.new()
				MinimapIcon.texture = load("res://CIRCLE.png")
				MinimapIcon.size = Vector2(123,123)
				MinimapIcon.pivot_offset = Vector2(61.5,61.5)
				MinimapIcon.scale = Vector2(0.2,0.2)
				MinimapIcon.set_meta("Target",NewDriver.get_path())
				MinimapIcon.modulate = Color.from_hsv(Mat.albedo_color.h,0.25,Mat.albedo_color.v)
				$Speedomoter/TextureRect.add_child(MinimapIcon)
		
		

var PlacementPosition : Array = []

func _process(delta):
	PlacementPosition = []
	for E in Drivers:
		var CurveRoad : Curve3D = $Path3D.curve
		var ClosestOffset = CurveRoad.get_closest_offset(E.global_position)
		var Len = CurveRoad.get_baked_length()
		var CorrectDistance = Len - ClosestOffset
		if CorrectDistance >= Len / 4 and CorrectDistance <= Len / 4 * 2 and E.LapStatus == 0:
			E.LapStatus = 1
		elif CorrectDistance >= (Len / 4) * 2 and CorrectDistance <= Len / 4 * 3 and E.LapStatus == 1:
			E.LapStatus = 2
		elif CorrectDistance >= (Len / 4) * 3 and E.LapStatus == 2:
			E.LapStatus = 3
		elif CorrectDistance <= 10 and E.LapStatus == 3:
			E.LapStatus = 0
			E.Laps += 1
		var DistanceAlong = 0
		if E.LapStatus == 0 and CorrectDistance >= Len / 4 and E.Laps == 0:
			DistanceAlong = CorrectDistance - Len
		else:
			DistanceAlong = CorrectDistance + (E.Laps * Len)
		PlacementPosition.append({E:DistanceAlong})
	
	PlacementPosition.sort_custom(MySort)
	for E in PlacementPosition:
		if E.keys()[0] == PlayerCarNode:
			$Speedomoter/Label.text = str(PlacementPosition.find(E) + 1)
	
func MySort(a, b):
	if a.values()[0] > b.values()[0]:
		return true
	return false
