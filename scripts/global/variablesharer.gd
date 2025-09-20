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

var driversprites = ["blueguy.png", "kaplin.png", "oneturret.png", "spore.png", "redguy.png", "terrance.png","dino.png","shiba.png"]
# Driver credits/references: 
# oneturret : game of same name
# spore : gnArp bAll
# terrance : misc character made by my good friend brushleaf68 that he uses a lot its like his main guy
# kaplin : take a wild guess
# dino : its      its dino
# shiba : is it a reference if its a real life thing? 
