extends Node3D

@export var PlayerCarNode : PlayerCar
@export var PathTrack : TrackPath

func on_map_map_done():
	PathTrack.sample_track(0)
	PlayerCarNode
