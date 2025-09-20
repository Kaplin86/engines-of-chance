extends CanvasLayer

var AnimDone = false
var Tar
func scene_transition(target, a3Dto2D = false) -> void:
	Tar = target
	$AnimationPlayer.play("start")
	
	
	$FallBackTimer.start(0)
	
	

func animdone():
	print("its done i think")
	$FallBackTimer.stop()
	
	
	print("it finished.")
	
	if Tar is PackedScene:
		get_tree().call_deferred("change_scene_to_packed",Tar)
	elif Tar is String:
		get_tree().change_scene_to_file(Tar)
	
	print("now we end it")
	$AnimationPlayer.play("end")
