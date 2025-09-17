extends CanvasLayer

@export var PlayerCarNode : PlayerCar

var State = "Drive"

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
	
	for E in get_children():
		if E.visible == false:
			E.modulate = Color(1,1,1,0)
			E.visible = true
	
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

var StateChanging = false

var CardsFlipped = false

#var PositiveCards = ["DoubleSpeed","LightCar","GrassCard", "Ghost"]
var PositiveCards = ["Ghost"]
var NegativeCards = ["HalfSpeed","HeavyCar","SpamCard"]
var NeutralCards = ["RainbowCar","Reaction","DriverView"]


var Card1
var Card2
var Card3

var ShibaAvailable = true

func FlipSinglecard(CardNode,CardType):
	$Cards/CardDraw.play()
	await do_tween(CardNode,"scale",Vector2(0,1),0.2)
	CardNode.texture = load("res://cards/" + CardType +".png")
	if CardType == "RainbowCar":
		CardNode.modulate = Color.from_hsv(0,0.5,1,1)
		CardNode.startrainbow()
	await do_tween(CardNode,"scale",Vector2(1,1),0.2)
	return true



func FlipCards():
	Card1 = PositiveCards.pick_random()
	Card2 = NeutralCards.pick_random()
	Card3 = NegativeCards.pick_random()
	
	await FlipSinglecard($Cards/Card1,Card1)
	await FlipSinglecard($Cards/Card2,Card2)
	await FlipSinglecard($Cards/Card3,Card3)
	

func _process(delta):
	if State == "Title":
		if Input.is_action_just_released("start") and !StateChanging:
			StateChanging = true
			await do_tween($TitleStuff,"modulate",Color(1,1,1,0),0.3)
			await do_tween($DrawTutorial,"modulate",Color(1,1,1,1),0.3)
			State = "Tut"
			StateChanging = false
	
	if State == "Tut":
		if Input.is_action_just_released("start")  and !StateChanging:
			StateChanging = true
			await do_tween($DrawTutorial,"modulate",Color(1,1,1,0),0.3)
			await do_tween($DrawTime,"modulate",Color(1,1,1,1),0.3)
			State = "45"
			StateChanging = false
	
	if State == "45":
		if Input.is_action_just_released("start")  and !StateChanging:
			StateChanging = true
			await do_tween($DrawTime,"modulate",Color(1,1,1,0),0.3)
			await do_tween($Drawer,"modulate",Color(1,1,1,1),0.3)
			State = "Draw"
			StateChanging = false
	
	if State == "Precard":
		if Input.is_action_just_released("start")  and !StateChanging:
			StateChanging = true
			await do_tween($CardTutorial,"modulate",Color(1,1,1,0),0.3)
			await do_tween($Cards,"modulate",Color(1,1,1,1),0.3)
			State = "GetCards"
			FlipCards()
			StateChanging = false
	
	if State == "GetCards":
		if Input.is_action_just_released("start")  and !StateChanging:
			StateChanging = true
			State = "Drive"
			do_tween($Cards,"modulate",Color(1,1,1,0),0.3)
			await do_tween($ColorRect,"modulate",Color(1,1,1,0),0.3)
			await get_tree().create_timer(0.5).timeout
			
			$"../Camera3D".camera_mode = $"../Camera3D".CameraMode.FollowBehind
			
			PlayerCarNode.ActivateCard(Card1)
			PlayerCarNode.ActivateCard(Card2)
			PlayerCarNode.ActivateCard(Card3)
			
			PlayerCarNode.CanDrive = true
			$"..".set_drive()
			StateChanging = false
			$"../Speedomoter".visible = true
			$"../Speedomoter".MusicPlaying = true
			$"../Speedomoter/Intro".playing = false
	
	
	if State == "Draw":
		runDraw(delta)
	
	if State == "Drive":
		$"../Speedomoter/LapDisplay".text = str(PlayerCarNode.Laps)+"/"+str($"..".LapCount)
		if PlayerCarNode.Laps == $"..".LapCount:
			State = "Result"
			PlayerPlacementAtVictory = $"..".PlayerPlace
			await get_tree().create_timer(0.5).timeout
			$"../Speedomoter".MusicPlaying = false
			Variablesharer.finalPlacement = PlayerPlacementAtVictory
			Transition.scene_transition("res://result_screen.tscn")
			
var PlayerPlacementAtVictory = 0

func runDraw(delta):
	$Drawer/ChangeColor.visible = true
	$Drawer/Finish.visible = true
	DrawTimer -= delta
	$Drawer/TimeLabel.text = str(int(clamp(floor(DrawTimer),0,99)))
	$Drawer/Lock.global_position = $Drawer/Lock.global_position.move_toward(Vector2(120,128),delta * 25)
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
				ShibaAvailable = false
				ColorRects[str(int(DrawCursorPosition.x)) + "," + str(int(DrawCursorPosition.y))].color = $Drawer/Pencil.modulate
				DrawnGuys[str(int(DrawCursorPosition.x)) + "," + str(int(DrawCursorPosition.y))] = $Drawer/Pencil.modulate
			if Input.is_action_pressed("rearview"):
				ColorRects[str(int(DrawCursorPosition.x)) + "," + str(int(DrawCursorPosition.y))].color = Color(0,0,0,0)
				DrawnGuys[str(int(DrawCursorPosition.x)) + "," + str(int(DrawCursorPosition.y))] = Color(0,0,0,0)
		else:
			if Input.is_action_just_pressed("start") or  Input.is_action_just_pressed("rearview"):
				$Drawer/Lock.global_position += Vector2(RNG.randi_range(-5,5),RNG.randi_range(-5,5))
		
		$Drawer/SwapColor.color = Color("212737")
		$Drawer/Confirm.color = Color("212737")
	else:
		
		if SpecialDrawControl == "color":
			$Drawer/Confirm.color = Color("212737")
			$Drawer/SwapColor.color = Color("616d8e")
			
			if Input.is_action_just_released("start"):
				_on_change_color_pressed()
			if Input.is_action_just_released("rearview"):
				$Drawer/Pencil.modulate.h -= 0.1
			
			
		else:
			$Drawer/SwapColor.color = Color("212737")
			$Drawer/Confirm.color = Color("616d8e")
			
			if Input.is_action_just_released("start") and !StateChanging:
				_on_finish_pressed()
				
				
				
		
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


func _on_change_color_pressed():
	$Drawer/Pencil.modulate.h += 0.1


func _on_finish_pressed():
	if !StateChanging:
		if $Drawer/TimeLabel.text == "30":
			var SoundPlayer = AudioStreamPlayer.new()
			SoundPlayer.stream = load("res://sfx/DogBarkShort.mp3")
			add_child(SoundPlayer)
			SoundPlayer.play()
			
		else:
			ShibaAvailable = false
		StateChanging = true
		State = "Precard"
		$Drawer/ChangeColor.visible = false
		$Drawer/Finish.visible = false
		
		for E in ColorRects:
			var NewerColorRect = ColorRects[E].duplicate()
			$"../Character".add_child(NewerColorRect)
		PlayerCarNode.find_child("SpriteFront").texture = $"../Character".get_texture()
		PlayerCarNode.find_child("SpriteBack").texture = $"../Character".get_texture()
		if ShibaAvailable:
			PlayerCarNode.find_child("SpriteFront").scale = Vector3(0.13,0.13,0.13)
			PlayerCarNode.find_child("SpriteBack").scale = Vector3(0.13,0.13,0.13)
			PlayerCarNode.find_child("SpriteFront").texture = load("res://SpeedyShibaSecret.png")
			PlayerCarNode.find_child("SpriteBack").texture =load("res://SpeedyShibaSecret.png")
			$"../Character/SpeedyShibaSecret".visible = true
		
		await do_tween($Drawer,"modulate",Color(1,1,1,0),0.3)
		await do_tween($CardTutorial,"modulate",Color(1,1,1,1),0.3)
		StateChanging = false
	
