extends Path3D
class_name TrackPath

func sample_track(distance, ratio = false) -> Transform3D: ##Gets track's transform at distance m along the track. if ratio is set to true, this will be a ratio from 0.0 to 1.0
	
	
	if !has_node("PathFollow3D"):
		var NewFollower = PathFollow3D.new()
		add_child(NewFollower)
		NewFollower.name = "PathFollow3D"
	
	var Follower : PathFollow3D = get_node("PathFollow3D")
	if ratio:
		Follower.progress_ratio = distance
	else:
		Follower.progress = distance
	
	return Follower.transform
