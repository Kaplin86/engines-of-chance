@tool
extends Node3D
class_name MapGenerator

##Generates different racing tracks.

@export var point_count: int = 20:
	set(value):
		point_count = value
		if Engine.is_editor_hint(): 	_ready()
		
@export var map_radius: int = 60:
	set(value):
		map_radius = value
		if Engine.is_editor_hint(): 	_ready()
@export var noise_strength:float = 0.25:
	set(value):
		noise_strength = value
		if Engine.is_editor_hint(): 	_ready()
@export var point_spacing:int = 1:
	set(value):
		point_spacing = value
		if Engine.is_editor_hint(): 	_ready()
@export var trackwidth: int = 8:
	set(value):
		trackwidth = value
		if Engine.is_editor_hint(): 	_ready()
@export var car : VehicleBody3D
@export var seed: int = 10:
	set(value):
		seed = value
		if Engine.is_editor_hint(): 	_ready()


@export_enum("Circle", "Oval", "Square") var shape: int:
	set(value):
		shape = value
		if Engine.is_editor_hint(): 	_ready()

@export var Minimap : SubViewport
@export var Path3D_Result : Path3D
@export var Randomize = false
@export var SkyHolder : WorldEnvironment

#--------------------------------------------------------------------------------------------------------------------

var GrassColors = ["b0ff99","c2ff23","a4f8a8","37c234","e78900","e3ffe3","f1dfff","b289ff"]
var RoadColors = ["808080","484848","999999","5d4625","e4b900","303030"]
var SkyColors = [["ffffff","ffffff","ffffff"],["93c3ff","ffffff","a5a7ab"],["002546","3b475a","3b475a"]]

#--------------------------------------------------------------------------------------------------------------------

signal MapDone

#--------------------------------------------------------------------------------------------------------------------

func _ready(): #the ready is basically 'track generate'
	for e in get_children(): #remove the old track, if found
		e.queue_free()
	
	if !Engine.is_editor_hint():
		if Randomize:
			var NewRng =RandomNumberGenerator.new()
			point_count += NewRng.randi_range(-1,1) 
			seed = NewRng.randi_range(0,100)
			shape = 0
	
	
	
	if Engine.is_editor_hint(): #since this is a tool script, I have an exception so it only runs in editor if the parent is named 'mapeditortest'
		if get_parent():
			if !get_parent().name == "mapeditortest":
				return
	
	var TheLine = generate_line(seed,point_count,map_radius,noise_strength) #Creates a line based on params
	var EvenlySpacedPoints = sample_line(TheLine,point_spacing) #Gets points along the map
	var EdgePoints = compute_edges(EvenlySpacedPoints,trackwidth) #Get left-side and right-side points
	var GrassPoints = compute_edges(EvenlySpacedPoints,trackwidth * 4) #Get left-side and right-side points
	
	var TrackAndGrass = createTrackAndGrass(EdgePoints, TheLine, GrassPoints)
	
	createWalls(GrassPoints,EdgePoints)
	
	
	if Minimap:
		for E in Minimap.find_child("Node3D").get_children():
			E.queue_free()
		var CameraTrack = TrackAndGrass[0].duplicate()
		Minimap.find_child("Node3D").add_child(CameraTrack)
	
	if Path3D_Result:
		Path3D_Result.curve = TheLine
	
	if SkyHolder:
		var ActualSky : Sky = SkyHolder.environment.sky
		var SkyMat : ProceduralSkyMaterial = ActualSky.sky_material
		var ColorPallete = SkyColors.pick_random()
		SkyMat.sky_top_color = Color(ColorPallete[0])
		SkyMat.sky_horizon_color =  Color(ColorPallete[1])
		SkyMat.ground_horizon_color =  Color(ColorPallete[2])
	
	MapDone.emit()

func createWalls(points,roadpoints): 
	var LeftPoints = points[0]
	var RightPoints = points[1]
	var LeftRoadPoints = roadpoints[0]
	var RightRoadPoints = roadpoints[1]
	
	#left first --------------------------------
	var LeftWallPoints = []
	var UsingLeftPoints = LeftPoints.duplicate()
	for E in LeftPoints.size():
		if LeftPoints[E].distance_to(LeftRoadPoints[E]) <= 2:
			UsingLeftPoints.erase(LeftPoints[E])
		else:
			LeftWallPoints.append(LeftPoints[E] + Vector3(0,2,0))
	
	LeftPoints = UsingLeftPoints.duplicate()
	UsingLeftPoints = []
	for E in LeftPoints:
		UsingLeftPoints.append(E - Vector3(0,2,0))
	
	
	var LeftMesh = MeshInstance3D.new() #Creates a empty mesh instance
	LeftMesh.mesh = build_track_mesh(LeftWallPoints,UsingLeftPoints)
	add_child(LeftMesh) 
	var OthersideLeftMesh = MeshInstance3D.new() #Creates a empty mesh instance
	OthersideLeftMesh.mesh = build_track_mesh(LeftPoints,LeftWallPoints)
	add_child(OthersideLeftMesh) 
	
	var body = StaticBody3D.new()
	var collider = CollisionShape3D.new()
	collider.shape = LeftMesh.mesh.create_trimesh_shape() 
	body.add_child(collider) 
	add_child(body) 
	
	body = StaticBody3D.new()
	collider = CollisionShape3D.new()
	collider.shape = OthersideLeftMesh.mesh.create_trimesh_shape() 
	body.add_child(collider) 
	add_child(body) 
	
	#right wall ----------------------------------
	var RightWallPoints = []
	var UsingRightPoints = RightPoints.duplicate()
	for E in RightPoints.size():
		if RightPoints[E].distance_to(RightRoadPoints[E]) <= 2:
			UsingRightPoints.erase(RightPoints[E])
		else:
			RightWallPoints.append(RightPoints[E] + Vector3(0,2,0))
	
	
	var RightMesh = MeshInstance3D.new() #Creates a empty mesh instance
	RightMesh.mesh = build_track_mesh(RightPoints,RightWallPoints)
	add_child(RightMesh) 
	
	body = StaticBody3D.new()
	collider = CollisionShape3D.new()
	collider.shape = RightMesh.mesh.create_trimesh_shape() 
	body.add_child(collider) 
	add_child(body) 

func createTrackAndGrass(EdgePoints,TheLine, GrassPoints):
	var TrackMesh = MeshInstance3D.new() #Creates a empty mesh instance
	TrackMesh.mesh = build_track_mesh(EdgePoints[0],EdgePoints[1]) #Generates a mesh from the track
	add_child(TrackMesh) #Add the cool mesh
	
	var TrackVisualMaterial = StandardMaterial3D.new()
	TrackVisualMaterial.albedo_color = Color(RoadColors.pick_random())
	TrackMesh.set_surface_override_material(0,TrackVisualMaterial)
	
	var body = StaticBody3D.new() #creates an empty track collider
	var collider = CollisionShape3D.new() #new collision shape yap yap
	collider.shape = TrackMesh.mesh.create_trimesh_shape() #this is kinda cool ig. turns the mesh to a collision shape
	body.add_child(collider) #adds collision shape to collider
	add_child(body) #add le collider
	
	
	body.name = "Track"
	
	var GrassMesh = MeshInstance3D.new() 
	GrassMesh.mesh = build_track_mesh(GrassPoints[0],GrassPoints[1]) 
	add_child(GrassMesh) 
	
	var GrassVisualMaterial = StandardMaterial3D.new()
	GrassVisualMaterial.albedo_color = Color(GrassColors.pick_random())
	GrassMesh.set_surface_override_material(0,GrassVisualMaterial)
	
	var Grassbody = StaticBody3D.new() 
	var Grasscollider = CollisionShape3D.new() 
	Grasscollider.shape = GrassMesh.mesh.create_trimesh_shape() 
	Grassbody.add_child(Grasscollider)
	add_child(Grassbody)
	
	var GrassPhysicalMaterial = PhysicsMaterial.new()
	GrassPhysicalMaterial.rough = true
	GrassPhysicalMaterial.friction = 1
	
	Grassbody.physics_material_override = GrassPhysicalMaterial
	
	Grassbody.position = Vector3(0,-0.2,0)
	GrassMesh.position = Grassbody.position
	
	Grassbody.name = "Grass"
	if car:
		car.GrassBody = Grassbody
	
	return [TrackMesh, GrassMesh]

func get_track_transform_at(curve: Curve3D, distance: float) -> Transform3D: #This gets a point along the curve and turns it into a transform 3D
	var pos = curve.sample_baked(distance) #get the point along the curve
	
	var pos_ahead = curve.sample_baked(min(distance + 1.0, curve.get_baked_length())) #get the position 1 unit away
	var forward = (pos_ahead - pos).normalized() #gets the normalized from point and point 1 away.
	
	var up = Vector3.UP #guess what this does chat
	
	var right = up.cross(forward).normalized() #using silly cross stuff get leftright
	var real_up = forward.cross(right).normalized() #using silly cross stuff to get real up
	
	var basis = Basis()
	basis.x = right
	basis.y = real_up
	basis.z = forward
	
	return Transform3D(basis, pos)


func generate_line(seed,points,radius,noise) -> Curve3D: #this generates the curve3D
	var RNG = RandomNumberGenerator.new() #gambling
	RNG.seed = seed
	var curve = Curve3D.new()
	
	if shape == 0: #circle
		for I in points:
			var angle = TAU * I / points
			var r = radius * (1.0 + RNG.randf_range(-noise_strength, noise_strength))
			var p = Vector3(r * cos(angle), 0.0, r * sin(angle))
			curve.add_point(p)
	
	if shape == 1: #oval
		for I in points:
			var angle = TAU * I / points
			var r = radius * (1.0 + RNG.randf_range(-noise_strength, noise_strength))
			var p = Vector3(r * cos(angle) * 0.5, 0.0, r * sin(angle))
			curve.add_point(p)
	
	if shape == 2: #square
		for I in points:
			var Placement = float(I) / points
			var angleplacement = Placement * 4
			
			var x = 0.0
			var z = 0.0
			
			if angleplacement < 1: #top
				x = lerp(-radius, radius, angleplacement)
				z = -radius
			elif angleplacement < 2: #right
				x = radius
				z = lerp(-radius, radius, angleplacement - 1.0)
			elif angleplacement < 3: #bottom
				x = lerp(radius, -radius, angleplacement - 2.0)
				z = radius
			elif angleplacement < 4: #right
				x = -radius
				z = lerp(radius, -radius, angleplacement - 3.0)
			
			x += RNG.randf_range(-noise_strength * radius, noise_strength * radius)
			z += RNG.randf_range(-noise_strength * radius, noise_strength * radius)
			
			var p = Vector3(x, 0.0, z)
			curve.add_point(p)

	
	curve.add_point(curve.get_point_position(0)) #add in the first point at the end that way it loops
	return curve

func sample_line(Line : Curve3D, spacing = 1): #This obtains points in space from the curve3D
	var baked = []
	var length = Line.get_baked_length()
	var t = 0.0
	while t < length: #keep going until all the length is covered
		baked.append(Line.sample_baked(t))
		t += spacing
	return baked

func compute_edges(points : Array,width = 8): #takes mid-track points and makes left and right points
	var left = [] #points alongside the left-side of the track
	var right = [] #points alongside the right side of hte track
	
	for E in points.size(): #for each of the mid point
		var PointInQuestion = points[E] #actual point (e is a number)
		
		var nextPoint = points[wrap(E + 1,0,points.size())] #Get the next points
		var distanceangle = (nextPoint - PointInQuestion).normalized() #get angle from current point to next point
		var leftright = Vector3.UP.cross(distanceangle).normalized() #turn said angle into a vector referring to the left-right movement on the track
		left.append(PointInQuestion - leftright * width/2.0) #add left point
		right.append(PointInQuestion + leftright * width/2.0) #add right
		
	return [left, right]

func build_track_mesh(left: Array, right: Array) -> ArrayMesh: #build an array mesh from the left-right points along the track 
	var SurfaceT = SurfaceTool.new() #empty surface tools
	SurfaceT.begin(Mesh.PRIMITIVE_TRIANGLES) #begin the process
	
	for i in left.size()-1: #go through all items at a offset of -1
		var l0 = left[i] #bottom left (birds eye view, 'next track point' is north)
		var r0 = right[i] #bottom right
		var l1 = left[i+1] #top left
		var r1 = right[i+1] #top right
		
		var u0 = float(i) / left.size()
		var u1 = float(i+1) / left.size()
		
		
		SurfaceT.set_uv(Vector2(u0, 0)) #make first triangle using the bottom left, bottom right, and top left points
		SurfaceT.add_vertex(l0)
		SurfaceT.set_uv(Vector2(u0, 1))
		SurfaceT.add_vertex(r0)
		SurfaceT.set_uv(Vector2(u1, 0))
		SurfaceT.add_vertex(l1)
		
		
		SurfaceT.set_uv(Vector2(u0, 1))  #make second triangle using bottom right, top right, and top left points
		SurfaceT.add_vertex(r0)
		SurfaceT.set_uv(Vector2(u1, 1))
		SurfaceT.add_vertex(r1)
		SurfaceT.set_uv(Vector2(u1, 0))
		SurfaceT.add_vertex(l1)
	
	var l0 = left[-1] #add track between the last point (-1) and the first (0). Missing due to offset approach in the loop
	var r0 = right[-1]
	var l1 = left[0]
	var r1 = right[0]
	
	var u0 = 1.0
	var u1 = 0.0
	
	SurfaceT.set_uv(Vector2(u0, 0))
	SurfaceT.add_vertex(l0)
	SurfaceT.set_uv(Vector2(u0, 1))
	SurfaceT.add_vertex(r0)
	SurfaceT.set_uv(Vector2(u1, 0))
	SurfaceT.add_vertex(l1)
	
	SurfaceT.set_uv(Vector2(u0, 1))
	SurfaceT.add_vertex(r0)
	SurfaceT.set_uv(Vector2(u1, 1))
	SurfaceT.add_vertex(r1)
	SurfaceT.set_uv(Vector2(u1, 0))
	SurfaceT.add_vertex(l1)
	
	SurfaceT.index()
	return SurfaceT.commit() #arraymesh
