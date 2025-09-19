extends Camera3D

func do_tween(object : Node,property,newvalue,time):
	var NewTween = create_tween()
	NewTween.tween_property(object,property,newvalue,time)
	return NewTween.finished
func _ready():
	transform = $"CameraAngles/1".transform
	await do_tween(self,"transform",$"CameraAngles/2".transform,3)
	transform = $"CameraAngles/3".transform
	await do_tween(self,"transform",$"CameraAngles/4".transform,3)
	$"../Camera3D".current = true
	$"../Light".runlights()
	do_tween($"../TrackName/Node2D","modulate",Color(1,1,1,0),1)
