extends Node2D



func _ready():
	$Result/PlacementValue.text = str(Variablesharer.finalPlacement)
