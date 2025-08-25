@tool
extends Node3D

@export var point_count: int = 20:
	set(value):
		point_count = value
		_ready()
@export var map_radius: int = 60:
	set(value):
		map_radius = value
		_ready()
@export var noise_strength:float = 0.25:
	set(value):
		noise_strength = value
		_ready()
@export var point_spacing:int = 1:
	set(value):
		point_spacing = value
		_ready()
@export var trackwidth: int = 8:
	set(value):
		trackwidth = value
		_ready()
@export var car : VehicleBody3D
@export var seed: int = 10:
	set(value):
		seed = value
		_ready()

func _ready():
	if Engine.is_editor_hint():
		if get_parent():
			if !get_parent().name == "mapeditortest":
				return
	for e in get_children():
		e.queue_free()
	var TheLine = generate_line(seed,point_count,map_radius,noise_strength)
	var EvenlySpacedPoints = sample_line(TheLine,point_spacing)
	var EdgePoints = compute_edges(EvenlySpacedPoints,trackwidth)
	
	var TrackMesh = MeshInstance3D.new()
	TrackMesh.mesh = build_track_mesh(EdgePoints[0],EdgePoints[1])
	add_child(TrackMesh)
	var body = StaticBody3D.new()
	var collider = CollisionShape3D.new()
	collider.shape = TrackMesh.mesh.create_trimesh_shape()
	body.add_child(collider)
	add_child(body)
	
	if car:
		car.global_transform = get_track_transform_at(TheLine,25)
		car.position += Vector3(0,1,0)

func get_track_transform_at(curve: Curve3D, distance: float) -> Transform3D:
	var pos = curve.sample_baked(distance)
	
	var pos_ahead = curve.sample_baked(min(distance + 1.0, curve.get_baked_length()))
	var forward = (pos_ahead - pos).normalized()
	
	var up = Vector3.UP
	
	var right = up.cross(forward).normalized()
	var real_up = forward.cross(right).normalized()
	
	var basis = Basis()
	basis.x = right
	basis.y = real_up
	basis.z = forward
	
	return Transform3D(basis, pos)


func generate_line(seed,points,radius,noise): #this generates the curve3D
	var RNG = RandomNumberGenerator.new()
	RNG.seed = seed
	var curve = Curve3D.new()
	
	for I in points:
		var angle = TAU * I / points
		var r = radius * (1.0 + RNG.randf_range(-noise_strength, noise_strength))
		var p = Vector3(r * cos(angle), 0.0, r * sin(angle))
		curve.add_point(p)
	
	curve.add_point(curve.get_point_position(0)) 
	return curve

func sample_line(Line : Curve3D, spacing = 1): #This obtains points in space from the curve3D
	var baked = []
	var length = Line.get_baked_length()
	var t = 0.0
	while t < length:
		baked.append(Line.sample_baked(t))
		t += spacing
	return baked

func compute_edges(points : Array,width = 8):
	var left = []
	var right = []
	
	for E in points.size():
		var PointInQuestion = points[E]
		
		var nextPoint = points[wrap(E + 1,0,points.size())]
		var distance = (nextPoint - PointInQuestion).normalized()
		var leftright = Vector3.UP.cross(distance).normalized()
		left.append(PointInQuestion - leftright * width/2.0)
		right.append(PointInQuestion + leftright * width/2.0)
		
	return [left, right]

func build_track_mesh(left: Array, right: Array):
	var SurfaceT = SurfaceTool.new()
	SurfaceT.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in left.size()-1:
		var l0 = left[i]
		var r0 = right[i]
		var l1 = left[i+1]
		var r1 = right[i+1]
		
		SurfaceT.add_vertex(l0)
		SurfaceT.add_vertex(r0)
		SurfaceT.add_vertex(l1)
		
		SurfaceT.add_vertex(r0)
		SurfaceT.add_vertex(r1)
		SurfaceT.add_vertex(l1)
	
	SurfaceT.index()
	return SurfaceT.commit()
