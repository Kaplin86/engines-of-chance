extends CanvasLayer

var AnimDone = false

func scene_transition(target, a3Dto2D = false) -> void:
	$AnimationPlayer.play("start")
	print("waiting for transition finish!!")
	
	$FallBackTimer.start(0)
	if a3Dto2D:
		await get_tree().create_timer(2).timeout
		for E in get_tree().current_scene.get_children():
			E.queue_free()
		await get_tree().create_timer(1).timeout
	else:
		await isAnimDone()
	print("its done i think")
	$FallBackTimer.stop()
	
	
	print("it finished.")
	if target is PackedScene:
		get_tree().change_scene_to_packed(target)
	elif target is String:
		get_tree().change_scene_to_file(target)
	
	print("now we end it")
	$AnimationPlayer.play("end")
	



func isAnimDone():
	AnimDone = false
	while !AnimDone:
		print($FallBackTimer.time_left)
		await get_tree().process_frame
	return


func _on_animation_player_animation_finished(anim_name):
	AnimDone = true


func _on_fall_back_timer_timeout():
	AnimDone = true
