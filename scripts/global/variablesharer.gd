extends Node
var finalPlacement = 0
var difficulty = "N"
var difficultyToText = {"B":"BABY","E":"EASY","N":"NORMAL","P":"pain"}
# 1 means positive card, 0 means neutral, -1 means negative
var difficultyToCards = {"B":[1],"E":[1,0],"N":[1,0,-1],"P":[-1,-1,-1]}

var playerCards = []

var PositiveCards = ["DoubleSpeed","LightCar","GrassCard", "Ghost"]
var NegativeCards = ["HalfSpeed","HeavyCar","SpamCard"]
var NeutralCards = ["RainbowCar","Reaction","DriverView","Celebration"]
