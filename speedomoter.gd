extends CanvasLayer
@export var Car : VehicleBody3D

var Tier = 1
var MaxTier = 4
var TierPlaying = 0
var TierTimer = 1

func _process(delta: float) -> void:
	$TextureProgressBar.value = Car.linear_velocity.distance_to(Vector3.ZERO)
	Tier = ceil(($TextureProgressBar.value / $TextureProgressBar.max_value) * MaxTier)
	if Tier > TierPlaying:
		TierPlaying = Tier
		TierTimer = 1.5
		
		ChangeSong()
		
	elif Tier == TierPlaying:
		TierTimer = 1.5
	else:
		TierTimer -= delta
	if TierTimer <= 0:
		TierPlaying = 0

func do_tween(object : Node,property,newvalue,time):
	var NewTween = create_tween()
	NewTween.tween_property(object,property,newvalue,time)
	return NewTween.finished

func ChangeSong():
	await do_tween($"../music","volume_linear",0,0.5)
	$"../music".stream = load("res://music/Tier" + str(int(Tier)) + ".mp3")
	$"../music".play()
	await do_tween($"../music","volume_linear",1,0.5)
