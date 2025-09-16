extends Node2D
class_name IntroScreen

## A node that waits for a input then immediately goes to the next screen

@export_file("*.tscn") var TargetScene : String
@export var RunTransition = true

var Transitioning = false

func TryTransition(override = ""):
	if !Transitioning:
			Transitioning = true
			if override:
				TargetScene = override
			if RunTransition:
				Transition.scene_transition(TargetScene)
			else:
				get_tree().change_scene_to_file(TargetScene)

func _process(delta):
	if Input.is_action_just_pressed("start"):
		TryTransition()
