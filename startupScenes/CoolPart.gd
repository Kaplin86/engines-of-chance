extends IntroScreen
func _process(delta):
	if Input.is_action_just_pressed("start"):
		TryTransition()
	$SubViewport/Car.rotation.y += 0.02
