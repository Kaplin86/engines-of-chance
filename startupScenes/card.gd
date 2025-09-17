extends IntroScreen

var PositiveCards = ["DoubleSpeed","LightCar","GrassCard", "Ghost"]
var NegativeCards = ["HalfSpeed","HeavyCar","SpamCard"]
var NeutralCards = ["RainbowCar","Reaction","DriverView"]

@onready var Lx = $Lpoint.global_position.x
@onready var Rx = $Rpoint.global_position.x

var BlankCard = preload("res://cards/BlankCard.png")

var UsingCards = []
var CardChilds = []

func _ready():
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
	
		CardChilds.append(NewCard)
	await get_tree().create_timer(0.5).timeout
	FlipCards(cardsTypes)

func FlipCards(cardsTypes):
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
	
	for P in CardChilds:
		print(P)
