extends CanvasLayer

func scene_transition(target) -> void:
	$AnimationPlayer.play("start")
	await $AnimationPlayer.animation_finished
	if target is PackedScene:
		get_tree().change_scene_to_packed(target)
	elif target is String:
		get_tree().change_scene_to_file(target)
	$AnimationPlayer.play("end")
	
