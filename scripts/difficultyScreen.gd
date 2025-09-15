extends IntroScreen


var Difficulties = ["B","E","N","P"]
var Selected = 0

var Elements = {}
var Wait = 0
var WaitTime = 0.2

func _ready():
	for E in get_children():
		if E.name in Difficulties:
			Elements[E.name] = E

func _process(delta):
	if Input.is_action_just_pressed("start"):
		TryTransition()
	
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
	
	
	
	

func updateButtons():
	
	Selected = wrap(Selected,0,Difficulties.size())
	for E in Elements.values():
		E.find_child("Outline").color = Color("2f2f2f")
	var SelectedElement = Elements[Difficulties[Selected]]
	SelectedElement.find_child("Outline").color = Color("ffffff")
