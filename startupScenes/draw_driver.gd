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
	
	for E in CharacterViewport.find_child("CharacterStore").get_children():
		var NewOne = E.duplicate()
		$PenBits.add_child(NewOne)

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



func drawpoint():
	var NewRect := ColorRect.new()
	NewRect.color = $D/Pencil.modulate
	NewRect.size = Vector2(8,8)
	NewRect.global_position = DrawCursor.global_position - Vector2(2,2)
	$PenBits.add_child(NewRect)

var moved = true

func _process(delta):
	if Drawing:
		DrawCursor.visible = true
		Wait -= delta
		
		if Input.is_action_pressed("start"):
			if DrawingGrid:
				if !get_color_rects_at_point(DrawCursor.global_position):
					drawpoint()
			else:
				if moved:
					drawpoint()
					moved = false
		
		if Input.is_action_pressed("rearview"):
			for E in get_color_rects_at_point(DrawCursor.global_position):
				E.queue_free()
		
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
				if DrawCursorPosition.y >= 25 / 2:
					Selected = 1
				else:
					Selected = 0
				updateButtons()
			
			DrawCursorPosition = Vector2(clamp(DrawCursorPosition.x,0,25),clamp(DrawCursorPosition.y,0,25))
			DrawCursor.global_position = Vector2(18.0,18.0) + (8 * DrawCursorPosition)
		else:
			if Wait <= 0:
				if round(Input.get_axis("up","down")) != 0 or round(Input.get_axis("left","right")) != 0:
					DrawCursor.global_position += Vector2(2 * round(Input.get_axis("left","right")) ,2 * round(Input.get_axis("up","down")))
					Wait = (WaitTime * 0.2) / 3
					moved = true
			
			if DrawCursor.global_position.x > 220:
				Drawing = false
				if DrawCursor.global_position.y >= ((220 - 16)/2) + 16:
					Selected = 1
				else:
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
			if Input.is_action_pressed("start"):
				if Selected == 0:
					$D/Pencil.modulate.h -= 0.1
					Wait = WaitTime
				else:
					TryTransition()
					for E in $PenBits.get_children():
						var NewE = E.duplicate()
						CharacterViewport.find_child("CharacterStore").add_child(NewE)
					CharacterViewport.find_child("Driver").visible = false
					Wait = 5
		
		Wait -= delta

func get_color_rects_at_point(point: Vector2) -> Array:
	var hits = []
	for child : ColorRect in $PenBits.get_children():
		
		if Rect2(child.global_position, child.size).has_point(point):
			hits.append(child)
	return hits
