extends CanvasLayer

func scene_transition(target: String) -> void:
	$AnimationPlayer.play("start")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play("end")
	
