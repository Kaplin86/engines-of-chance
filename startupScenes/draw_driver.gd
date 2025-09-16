extends IntroScreen

var DrawingGrid = false
var Wait = 0
var WaitTime = 0.3

var Drawing = true
var DrawCursorPosition = Vector2(0,0)

var Options = ["D","C"]
var Elements = {}
var Selected = -2

func _ready():
	for E in get_children():
		if E.name in Options:
			Elements[E.name] = E

@onready var DrawCursor = $Cursor

func updateButtons():
	$Select.play()
	if Selected != -2:
		Selected = wrap(Selected,0,Options.size())
	for E in Elements.values():
		E.find_child("Outline").color = Color("2f2f2f")
	if Selected != -2:
		var SelectedElement = Elements[Options[Selected]]
		SelectedElement.find_child("Outline").color = Color("ffffff")

func _process(delta):
	if Drawing:
		DrawCursor.visible = true
		Wait -= delta
		if DrawingGrid:
			
			
			if Wait <= 0:
				if round(Input.get_axis("up","down")) != 0:
					DrawCursorPosition += Vector2(0,1 * round(Input.get_axis("up","down")))
					Wait = WaitTime / 3
				if round(Input.get_axis("left","right")) != 0:
					DrawCursorPosition += Vector2(1  * round(Input.get_axis("left","right")) ,0)
					Wait = WaitTime / 3
			
			if DrawCursorPosition.x > 25:
				Drawing = false
				Selected = 0
				updateButtons()
			
			DrawCursorPosition = Vector2(clamp(DrawCursorPosition.x,0,25),clamp(DrawCursorPosition.y,0,25))
			DrawCursor.global_position = Vector2(18.0,18.0) + (8 * DrawCursorPosition)
		else:
			if Wait <= 0:
				if round(Input.get_axis("up","down")) != 0 or round(Input.get_axis("left","right")) != 0:
					DrawCursor.global_position += Vector2(2 * round(Input.get_axis("left","right")) ,2 * round(Input.get_axis("up","down")))
					Wait = (WaitTime * 0.2) / 3
			
			if DrawCursor.global_position.x > 220:
				Drawing = false
				Selected = 0
				updateButtons()
			
			DrawCursor.global_position.x = clamp(DrawCursor.global_position.x,16,220)
			DrawCursor.global_position.y = clamp(DrawCursor.global_position.y,16,220)
	else:
		DrawCursor.visible = false
		if Wait <= 0:
			if Input.is_action_pressed("down"):
				Wait = WaitTime
				Selected += 1
				updateButtons()
			if Input.is_action_pressed("up"):
				Wait = WaitTime
				Selected -= 1
				updateButtons()
			if Input.is_action_pressed("left"):
				Drawing = true
				Selected = -2
				updateButtons()
				Wait = WaitTime / 3
		
		
		Wait -= delta
