extends CanvasLayer

var AnimDone = false
var Tar
var todelete = null
func scene_transition(target, a3Dto2D = false) -> void:
	Tar = target
	print("Starting animation")
	$AnimationPlayer.play("start")
	
	
	$FallBackTimer.start(0)
	
	if a3Dto2D:
		todelete = get_tree().current_scene
		get_tree().current_scene = null
		todelete.visible = false

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


func _on_fall_back_timer_timeout():
	print("FALLBACK TIMER ENABLED")
	animdone()
