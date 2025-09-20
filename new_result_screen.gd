extends IntroScreen
func _ready():
	$placement.text = "PLACEMENT: " + str(Variablesharer.finalPlacement)
	IntroBg.visible = true
	$placement2.text = "DIFFICULTY: " + Variablesharer.difficultyToText[Variablesharer.difficulty]

func _process(delta):
	if Input.is_action_just_pressed("start"):
		TryTransition("res://startupScenes/difficulty.tscn")
