extends Node2D

@export var PlacementValueNode : Label
var PlacementValue = 0

func _ready():
	if PlacementValue and PlacementValueNode:
		PlacementValueNode.text = str(PlacementValue)
