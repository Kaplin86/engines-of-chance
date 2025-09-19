extends Node2D
func _ready():
	$placement.text = "PLACEMENT: " + str(Variablesharer.finalPlacement)
