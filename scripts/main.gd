extends Node3D

@export var PlayerCarNode : PlayerCar
@export var PathTrack : TrackPath

func _on_map_map_done():
	
	PlayerCarNode.transform = PathTrack.sample_track(5)
	PlayerCarNode.rotation_degrees -= Vector3(0,90,0)
