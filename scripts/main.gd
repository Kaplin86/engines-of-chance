extends Node3D

@export var PlayerCarNode : PlayerCar
@export var PathTrack : TrackPath

var BaseCar = preload("res://car.tscn")
var CPUScript = preload("res://scripts/EnemyCar.gd")

var DriverCount = 15
var Drivers = []



var RNG = RandomNumberGenerator.new()

func _on_map_map_done():
	
	PlayerCarNode.transform = PathTrack.sample_track(5)
	PlayerCarNode.rotation_degrees -= Vector3(0,90,0)
	
func _ready():
	for E in DriverCount:
		var NewScene = BaseCar.instantiate()
		NewScene.set_script(CPUScript)
		var NewDriver : CarCPU = NewScene
		Drivers.append(NewDriver)
		add_child(NewDriver)
		NewDriver.visible = true
		NewDriver.transform = PathTrack.sample_track(-10 * E)
		NewDriver.GrassBody = $map.Grassbody
		NewDriver.rotation_degrees -= Vector3(0,90,0)
		NewDriver.mass = 60
		NewDriver.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
		NewDriver.center_of_mass = Vector3(0,-0.1,0)
		
		NewDriver.MaxSteer = 0.5
		NewDriver.EnginePower = 125 + RNG.randi_range(-1,1)
		
		NewDriver.Lookahead = RNG.randi_range(6,8)
		NewDriver.TurnSpeed = RNG.randi_range(7,9)
		NewDriver.LookOffset = RNG.randi_range(-3,3)
		
		NewDriver.freeze = false
