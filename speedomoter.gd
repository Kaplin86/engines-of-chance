extends CanvasLayer
@export var Car : VehicleBody3D


var Layers = 13
var MusicPlaying = false

func _ready():
	$TextureRect/Player.set_meta("Target",Car.get_path())

func _process(delta: float) -> void:
	if Car:
		$TextureProgressBar.value = Car.linear_velocity.distance_to(Vector3.ZERO)
	
	
	var Percentage = $TextureProgressBar.value / $TextureProgressBar.max_value
	var Sync :AudioStreamSynchronized = $AudioStreamPlayer.stream
	
	
	for E in Sync.stream_count - 1:
		E += 1
		var start = float(E) / Layers
		var end = float(E + 1) / Layers
		
		var vol = clamp((Percentage - start) / (end - start), 0.0, 1.0)
		Sync.set_sync_stream_volume(E, linear_to_db(vol))
	
	if MusicPlaying:
		if !$AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()
	
	for E in $TextureRect.get_children():
		var Target = get_node( E.get_meta("Target"))
		if Target:
			E.position = Vector2(1.69 * Target.global_position.x,1.69925485378 * Target.global_position.z)
			E.position += $TextureRect.size / 2
			E.position -= E.pivot_offset
	
	

func do_tween(object : Node,property,newvalue,time):
	var NewTween = create_tween()
	NewTween.tween_property(object,property,newvalue,time)
	return NewTween.finished
