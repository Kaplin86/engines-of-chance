extends Node2D
class_name IntroScreen

## A node that waits for a input then immediately goes to the next screen

@export var TargetScene : PackedScene
@export var RunTransition = true

var Transitioning = false

func TryTransition(override = ""):
	if !Transitioning:
			Transitioning = true
			var TheTarget = TargetScene
			if override:
				TheTarget = override
			if RunTransition:
				Transition.scene_transition(TheTarget)
			else:
				get_tree().change_scene_to_packed(TheTarget)

func _process(delta):
	if Input.is_action_just_pressed("start"):
		TryTransition()
