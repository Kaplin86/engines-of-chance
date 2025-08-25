extends Camera3D
@export var FocusObject : Node3D

enum CameraMode { Circle, FollowBehind, DriverView}

@export var camera_mode: CameraMode

var DesiredPosition = Vector3(0,0,0)
var CircleTime = 0
var CircleDistance = 6.543

var SkipMove = false


func _process(delta):
	
	if camera_mode == CameraMode.Circle:
		CircleTime += delta
		DesiredPosition.x = sin(CircleTime) * CircleDistance + FocusObject.global_position.x
		DesiredPosition.z = cos(CircleTime) * CircleDistance + FocusObject.global_position.z
		DesiredPosition.y = 3.549 - FocusObject.global_position.y
	
	if camera_mode == CameraMode.FollowBehind:
		DesiredPosition.x = sin(FocusObject.rotation.y - 1.570795) * CircleDistance + FocusObject.global_position.x
		DesiredPosition.z = cos(FocusObject.rotation.y - 1.570795) * CircleDistance + FocusObject.global_position.z
		DesiredPosition.y = 3.549 - FocusObject.global_position.y
		
		
		if Input.is_action_pressed("rearview"):
			DesiredPosition.x = sin(FocusObject.rotation.y + 1.570795) * CircleDistance * 0.5 + FocusObject.global_position.x
			DesiredPosition.z = cos(FocusObject.rotation.y + 1.570795) * CircleDistance * 0.5 + FocusObject.global_position.z
			SkipMove = true
			
		else:
			if SkipMove:
				SkipMove = false
				global_position = DesiredPosition
	
	if camera_mode == CameraMode.DriverView:
		DesiredPosition.x = $"../Car/SpriteFront".global_position.x
		DesiredPosition.z = $"../Car/SpriteFront".global_position.z
		DesiredPosition.y = $"../Car/SpriteFront".global_position.y
		SkipMove = true
		
	
	if SkipMove:
		global_position = DesiredPosition
	else:
		global_position = global_position.move_toward(DesiredPosition,delta * 12)
	
	if camera_mode == CameraMode.DriverView:
		rotation = $"../Car".rotation
		rotation.y -= deg_to_rad(90)
	else:
		look_at(FocusObject.global_position)
