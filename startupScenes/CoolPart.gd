extends IntroScreen

var Options = ["B","D"]
var Wait = 0
var WaitTime = 0.3
var Selected = 0
var Elements = {}


func _ready():
	for E in get_children():
		if E.name in Options:
			Elements[E.name] = E
	
	if Variablesharer.difficulty == "P":
		$Difficulty/Label.visible = true
	else:
		$Difficulty.text = "DIFFICULTY: " + Variablesharer.difficultyToText[Variablesharer.difficulty]

func _process(delta):
	if Input.is_action_just_pressed("start"):
		if Selected == 0:
			TryTransition()
		else:
			TryTransition("res://startupScenes/draw_driver.tscn")
		Wait = 3
	else:
		if Wait <= 0:
			if Input.is_action_pressed("down"):
				Wait = WaitTime
				Selected += 1
				updateButtons()
			if Input.is_action_pressed("up"):
				Wait = WaitTime
				Selected -= 1
				updateButtons()
		
		Wait -= delta
	$SubViewport/Car.rotation.y += 0.02

func updateButtons():
	$Select.play()
	Selected = wrap(Selected,0,Options.size())
	for E in Elements.values():
		E.find_child("Outline").color = Color("2f2f2f")
	var SelectedElement = Elements[Options[Selected]]
	SelectedElement.find_child("Outline").color = Color("ffffff")
