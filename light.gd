extends CanvasLayer
@export var Red : Node
@export var Yellow : Node
@export var Green : Node

func runlights():
	visible = true
	Red.visible = false
	Yellow.visible = false
	Green.visible = false
	
	await get_tree().create_timer(2).timeout
	$Glass04.play()
	Red.visible = true
	
	await get_tree().create_timer(2).timeout
	$Glass04.play()
	Yellow.visible = true
	
	await get_tree().create_timer(2).timeout
	$Glass04.play()
	Green.visible = true
	
	$"..".set_drive()
	$"../Speedomoter".MusicPlaying = true
	$"../Speedomoter".visible = true
	
	await get_tree().create_timer(1).timeout
	visible = false
	
