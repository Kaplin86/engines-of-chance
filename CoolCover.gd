extends CanvasLayer

var State = "Title"

var ColorRects = {}
var RNG = RandomNumberGenerator.new()
var DrawCursorPosition = Vector2(0,0)
@onready var DrawCursor = $Drawer/Cursor

var DrawnGuys = {}

func do_tween(object : Node,property,newvalue,time):
	var NewTween = create_tween()
	NewTween.tween_property(object,property,newvalue,time)
	return NewTween.finished

func _ready():
	$TitleStuff.visible = true
	for Xpos in range(26):
		for Ypos in range(26):
			var NewRect = ColorRect.new()
			ColorRects[str(Xpos) + "," + str(Ypos)] = NewRect
			DrawnGuys[str(Xpos) + "," + str(Ypos)] = Color(0,0,0,0)
			NewRect.size = Vector2(8,8)
			NewRect.position = Vector2(16,16) + Vector2(8*Xpos,8*Ypos)
			$Drawer.add_child(NewRect)
			NewRect.color = Color(0,0,0,0)

var DeltaHold = 0
var CanMove = true
var SpecialDrawControl = null

var DrawTimer = 46


func _process(delta):
	if State == "Title":
		if Input.is_action_just_released("start"):
			await do_tween($TitleStuff,"modulate",Color(1,1,1,0),0.3)
			await do_tween($DrawTime,"modulate",Color(1,1,1,1),0.3)
			State = "45"
	
	if State == "45":
		if Input.is_action_just_released("start"):
			await do_tween($DrawTime,"modulate",Color(1,1,1,0),0.3)
			await do_tween($Drawer,"modulate",Color(1,1,1,1),0.3)
			State = "Draw"
	
	if State == "Draw":
		DrawTimer -= delta
		$Drawer/TimeLabel.text = str(int(clamp(floor(DrawTimer),0,99)))
		$Drawer/Lock.global_position = $Drawer/Lock.global_position.move_toward(Vector2(120,128),delta * 10)
		if DrawTimer <= 0:
			$Drawer/Lock.visible = true
		if !SpecialDrawControl:
			if DeltaHold + delta >= 0.15:
				if CanMove == false:
					DeltaHold = 0
					CanMove = true
			else:
				if CanMove == false:
					DeltaHold += delta
			
			if CanMove:
				if round(Input.get_axis("left","right")) != 0:
					DrawCursorPosition += Vector2(1 * round(Input.get_axis("left","right")),0)
					CanMove = false
					if DrawCursorPosition.x >= 26:
						if DrawCursorPosition.y >= 13:
							SpecialDrawControl = "accept"
						else:
							SpecialDrawControl = "color"
					if 1 * round(Input.get_axis("left","right")) == -1:
						if SpecialDrawControl:
							SpecialDrawControl = null
				
				if round(Input.get_axis("up","down")) != 0:
					DrawCursorPosition += Vector2(0,1* round(Input.get_axis("up","down")))
					CanMove = false
				
				DrawCursorPosition = Vector2(clamp(DrawCursorPosition.x,0,25),clamp(DrawCursorPosition.y,0,25))
			
			DrawCursor.global_position = Vector2(18.0,18.0) + (8 * DrawCursorPosition)
			DrawCursor.visible = !SpecialDrawControl
			
			if DrawTimer > 0:
				if Input.is_action_pressed("start"):
					ColorRects[str(int(DrawCursorPosition.x)) + "," + str(int(DrawCursorPosition.y))].color = $Drawer/Pencil.modulate
					DrawnGuys[str(int(DrawCursorPosition.x)) + "," + str(int(DrawCursorPosition.y))] = $Drawer/Pencil.modulate
				if Input.is_action_pressed("rearview"):
					ColorRects[str(int(DrawCursorPosition.x)) + "," + str(int(DrawCursorPosition.y))].color = Color(0,0,0,0)
					DrawnGuys[str(int(DrawCursorPosition.x)) + "," + str(int(DrawCursorPosition.y))] = Color(0,0,0,0)
			else:
				if Input.is_action_pressed("start") or  Input.is_action_pressed("rearview"):
					$Drawer/Lock.global_position += Vector2(RNG.randi_range(-5,5),RNG.randi_range(-5,5))
			
			$Drawer/SwapColor.color = Color("212737")
			$Drawer/Confirm.color = Color("212737")
		else:
			
			if SpecialDrawControl == "color":
				$Drawer/Confirm.color = Color("212737")
				$Drawer/SwapColor.color = Color("616d8e")
				
				if Input.is_action_just_released("start"):
					$Drawer/Pencil.modulate.h += 0.1
				if Input.is_action_just_released("rearview"):
					$Drawer/Pencil.modulate.h -= 0.1
			else:
				$Drawer/SwapColor.color = Color("212737")
				$Drawer/Confirm.color = Color("616d8e")
				
				if Input.is_action_just_released("start"):
					State = "Drive"
					do_tween($Drawer,"modulate",Color(1,1,1,0),0.3)
					await do_tween($ColorRect,"modulate",Color(1,1,1,0),0.3)
					for E in ColorRects:
						var NewerColorRect = ColorRects[E].duplicate()
						$"../Character".add_child(NewerColorRect)
					$"../Car/SpriteFront".texture = $"../Character".get_texture()
					$"../Car/SpriteBack".texture = $"../Character".get_texture()
					await get_tree().create_timer(0.5).timeout
					$"../Car".CanDrive = true
					$"../Camera3D".camera_mode = $"../Camera3D".CameraMode.FollowBehind
					
					
			
			if round(Input.get_axis("down","up")) != 0:
				if round(Input.get_axis("down","up")) == -1:
					if SpecialDrawControl == "color":
						SpecialDrawControl = "accept"
				else:
					if SpecialDrawControl == "accept":
						SpecialDrawControl = "color"
					
			if round(Input.get_axis("left","right")) == -1:
				
				if SpecialDrawControl == "color":
					DrawCursorPosition = Vector2(25,6)
				else:
					DrawCursorPosition = Vector2(25,20)
				SpecialDrawControl = null
			
