extends IntroScreen




@onready var Lx = $Lpoint.global_position.x
@onready var Rx = $Rpoint.global_position.x

var BlankCard = preload("res://cards/BlankCard.png")
var CardScript = preload("res://scripts/cardVisual.gd")

var UsingCards = []
var CardChilds = []

func _ready():
	Transitioning = true
	var cardsTypes : Array = Variablesharer.difficultyToCards[Variablesharer.difficulty]
	for E in cardsTypes.size():
		var NewCard = Sprite2D.new()
		NewCard.texture = BlankCard
		add_child(NewCard)
		NewCard.position = $Lpoint.position
		if cardsTypes.size() == 1:
			NewCard.position.x = Lx + ((Rx-Lx) / 2)
		else:
			NewCard.position.x = Lx + ((Rx-Lx) / (cardsTypes.size() - 1)) * E
		
		NewCard.set_script(CardScript)
		CardChilds.append(NewCard)
	await get_tree().create_timer(0.5).timeout
	await FlipCards(cardsTypes)
	Variablesharer.playerCards = UsingCards
	Transitioning = false

func FlipCards(cardsTypes):
	var NegativeCards = Variablesharer.NegativeCards.duplicate()
	var NeutralCards = Variablesharer.NeutralCards.duplicate()
	var PositiveCards = Variablesharer.PositiveCards.duplicate()
	for E in cardsTypes:
		if E == -1:
			
			
			var SelectedCard = NegativeCards.pick_random()
			NegativeCards.erase(SelectedCard)
			UsingCards.append(SelectedCard)
		elif E == 0:
			var SelectedCard = NeutralCards.pick_random()
			NegativeCards.erase(SelectedCard)
			UsingCards.append(SelectedCard)
		else:
			var SelectedCard = PositiveCards.pick_random()
			NegativeCards.erase(SelectedCard)
			UsingCards.append(SelectedCard)
	
	for P in CardChilds.size():
		await FlipSinglecard(CardChilds[P],UsingCards[P])
		
	return "hi"

func do_tween(object : Node,property,newvalue,time):
	var NewTween = create_tween()
	NewTween.tween_property(object,property,newvalue,time)
	return NewTween.finished

func FlipSinglecard(CardNode,CardType):
	$Cards.play()
	await do_tween(CardNode,"scale",Vector2(0,1),0.2)
	CardNode.texture = load("res://cards/" + CardType +".png")
	if CardType == "RainbowCar":
		CardNode.modulate = Color.from_hsv(0,0.5,1,1)
		CardNode.startrainbow()
	await do_tween(CardNode,"scale",Vector2(1,1),0.2)
	return true
