extends Node3D

@export var PlayerCarNode : PlayerCar
@export var PathTrack : TrackPath

var DriverCount = 8
var Drivers = []

@onready var BaseCPU = $BaseCPU

var RNG = RandomNumberGenerator.new()

func _on_map_map_done():
	
	PlayerCarNode.transform = PathTrack.sample_track(5)
	PlayerCarNode.rotation_degrees -= Vector3(0,90,0)
	
func _ready():
	for E in DriverCount:
		var NewDriver : CarCPU = BaseCPU.duplicate()
		Drivers.append(NewDriver)
		add_child(NewDriver)
		NewDriver.visible = true
		NewDriver.transform = PathTrack.sample_track(-10 * E)
		NewDriver.GrassBody = $map.Grassbody
		NewDriver.rotation_degrees -= Vector3(0,90,0)
		
		NewDriver.Lookahead = RNG.randi_range(6,8)
		NewDriver.TurnSpeed = RNG.randi_range(7,9)
		
		NewDriver.freeze = false
