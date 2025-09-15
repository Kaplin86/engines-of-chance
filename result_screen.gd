extends Node2D

@export var PlacementValueNode : Label

func _ready():
	if PlacementValueNode:
		PlacementValueNode.text = str(Variablesharer.finalPlacement)
