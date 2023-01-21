# Copyright (c) 2022 arcaneenergy
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@tool
extends MultiMeshInstance3D

enum ScatterType { BOX, SPHERE }

@export_group("Multi Mesh Scatter")

@export_subgroup("Scattering")

## The number of instances to generate.
@export var count := 100:
	get: return count
	set(value):
		if value > 1000:
			print("MultiMeshScatter: You tried to set a scatter count above 1000, it's probably a mistake. If you truly want to just edit this check out yourself.")
			return
		count = value
		_update()

## Defines the placement type.
@export_enum("Box", "Sphere") var scatter_type: int = ScatterType.BOX:
	get: return scatter_type
	set(value):
		scatter_type = value

		if Engine.is_editor_hint():
			_create_debug_area()

		_update()

## The placement size of the bounding box.
## Enable [code]show_debug_area[/code] to view the size of the bounding box.
## [br][br] Note: If the [code]scatter_type[/code] is set to Sphere,
## only the x value will be used to specify the radius of the sphere.
@export var scatter_size := Vector3(10.0, 10.0, 10.0):
	get: return scatter_size
	set(value):
		scatter_size = value.clamp(Vector3.ONE * 0.01, Vector3.ONE * 100.0)
		_update()
	
## The physics collision mask that the instances should collide with.
@export_flags_3d_physics var collision_mask := 0x1:
	get: return collision_mask
	set(value):
		collision_mask = value
		_update()

@export_subgroup("Mesh")

## Setting this value will copy over the MeshInstance's Mesh to the MultiMeshInstance3D.
## This is just for convenience.
@export_node_path(MeshInstance3D) var mesh_instance:
	get: return mesh_instance
	set(value):
		if value:
			var i = get_node(value)
			if i.mesh:
				print("MultiMeshScatter: Mesh from MeshInstance added to the MultiMeshInstance3D. You can safely remove it.")
				multimesh.mesh = i.mesh
		mesh_instance = value

@export_group("Multi Mesh Placement")

@export_subgroup("Offset")

## Add an offset to the placed instances.
@export var offset_position := Vector3(0.0, 0.0, 0.0):
	get: return offset_position
	set(value):
		offset_position = value
		_update()

## Add a rotation offset to the placed instances.
@export var offset_rotation := Vector3(0.0, 0.0, 0.0):
	get: return offset_rotation
	set(value):
		offset_rotation = value
		_update()

## Change the base scale of the instanced meshes.
@export var base_scale := Vector3(1.0, 1.0, 1.0):
	get: return base_scale
	set(value):
		base_scale = value.clamp(Vector3.ONE * 0.01, Vector3.ONE * 100.0)
		_update()

@export_subgroup("Random Size")

## The minimum random size for each instance.
@export var min_random_size := Vector3(0.75, 0.75, 0.75):
	get: return min_random_size
	set(value):
		min_random_size = value.clamp(Vector3.ONE * 0.01, Vector3.ONE * 100.0)
		_update()

## The maximum random size for each instance.
@export var max_random_size := Vector3(1.25, 1.25, 1.25):
	get: return max_random_size
	set(value):
		max_random_size = value.clamp(Vector3.ONE * 0.01, Vector3.ONE * 100.0)
		_update()

@export_subgroup("Random Rotation")

## Rotate each instance by a random amount between
## [code]-random_rotation[/code] and +[code]random_rotation[/code].
@export var random_rotation := Vector3(0.0, 0.0, 0.0):
	get: return random_rotation
	set(value):
		random_rotation = value.clamp(Vector3.ONE * 0.00, Vector3.ONE * 180.0)
		_update()

@export_group("Multi Mesh Advanced")

@export_subgroup("Constraints")

## If enabled the scattering will only happen where the collision angle is above the specified threshold.
## This has a non-negligible impact on scattering speed but no impact once the scattering is done.
## This will result in less instances than the set [code]count[/code].
## (Those instances are actually just scaled to 0)
@export var use_angle: bool = false:
	get: return use_angle
	set(value):
		use_angle = value
		_update()
		
@export_range(0, 1, 0.01) var angle = 1.0:
	get: return angle
	set(value):
		angle = value
		_update()

## If enabled the scattering will only happen where vertex color of the surface below the specified threshold.
## This has a non-negligible impact on scattering speed but no impact once the scattering is done.
## This will result in less instances than the set [code]count[/code].
## (Those instances are actually just scaled to 0)
@export var use_vertex_colors: bool = false:
	get: return use_vertex_colors
	set(value):
		use_vertex_colors = value
		_update()

## Scatter threshold for the red channel.
@export_range(0, 1, 0.01) var r_channel = 1.0:
	get: return r_channel
	set(value):
		r_channel = value
		_update()
		
## Scatter threshold for the green channel.
@export_range(0, 1, 0.01) var g_channel = 1.0:
	get: return g_channel
	set(value):
		g_channel = value
		_update()
		
## Scatter threshold for the blue channel.
@export_range(0, 1, 0.01) var b_channel = 1.0:
	get: return b_channel
	set(value):
		b_channel = value
		_update()
		
@export_subgroup("Seed")

## Click to randomize the seed.
@export var randomize_seed := true:
	get: return randomize_seed
	set(value):
		seed = randi()
		randomize_seed = false
		
## A seed to feed for the random number generator if randomize seed is false.
@export var seed := 0:
	get: return seed
	set(value):
		seed = value
		_rng.seed = value
		_update()

@export_subgroup("Debug")

## Toggle the visibility of the bounding box area.
@export var show_debug_area := true:
	get: return show_debug_area
	set(value):
		show_debug_area = value

		if value && Engine.is_editor_hint():
			_create_debug_area()
		else:
			_delete_debug_area()

var _debug_draw_instance: MeshInstance3D
var _rng := RandomNumberGenerator.new()
var _mesh_data_array: Dictionary = {}

@onready var _space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

func _init() -> void:
	_ensure_has_mm()

func _ready() -> void:
	if Engine.is_editor_hint():
		if show_debug_area:
			_create_debug_area()
		else:
			_delete_debug_area()
	else:
		set_notify_transform(false)
		set_ignore_transform_notification(true)
	
	_update()

func _notification(what: int) -> void:
	if !is_inside_tree(): return

	if NOTIFICATION_TRANSFORM_CHANGED:
		_update()

func _ensure_has_mm() -> bool:
	if multimesh == null:
		multimesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
	return multimesh.mesh != null

func _delete_debug_area() -> void:
	if _debug_draw_instance != null && _debug_draw_instance.is_inside_tree():
		_debug_draw_instance.queue_free()
		_debug_draw_instance = null

func _create_debug_area() -> void:
	_delete_debug_area()
	_debug_draw_instance = MeshInstance3D.new()

	var material := StandardMaterial3D.new()
	_debug_draw_instance.material_override = material

	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.0, 0.0, 0.0784313725)
	material.no_depth_test = true

	var mesh: Mesh
	match scatter_type:
		ScatterType.SPHERE:
			mesh = SphereMesh.new()
		ScatterType.BOX, _:
			mesh = BoxMesh.new()

	_debug_draw_instance.mesh = mesh
	_debug_draw_instance.visible = show_debug_area

	add_child(_debug_draw_instance)
	_update_debug_area_size()

func _update_debug_area_size() -> void:
	if _debug_draw_instance != null && _debug_draw_instance.is_inside_tree():
		match scatter_type:
			ScatterType.SPHERE:
				_debug_draw_instance.mesh.radius = scatter_size.x / 2.0
				_debug_draw_instance.mesh.height = scatter_size.x
			ScatterType.BOX, _:
				_debug_draw_instance.mesh.size = scatter_size

func _update() -> void:
	if !_space: return
	scatter()

	if Engine.is_editor_hint():
		_update_debug_area_size()

func scatter() -> void:
	_rng.state = 0
	_rng.seed = seed
	
	if not _ensure_has_mm(): 
		print("MultiMeshScatter: The MultiMeshInstance3D doesn't have an assigned Mesh. Set it yourself or set a MeshInstance on the MultiMeshScatter so it can copy it for you.")
		return
	
	multimesh.instance_count = count

	for i in range(count):
		var pos := global_position

		match scatter_type:
			ScatterType.SPHERE:
				var radius := sqrt(_rng.randf()) * (scatter_size.x / 2.0)
				var theta := _rng.randf_range(0.0, 360.0)
				pos += Vector3(
					radius * cos(theta),
					0.0,
					radius * sin(theta))
			ScatterType.BOX, _:
				pos += Vector3(
					_rng.randf_range(-scatter_size.x / 2.0, scatter_size.x / 2.0),
					0.0,
					_rng.randf_range(-scatter_size.z / 2.0, scatter_size.z / 2.0))

		var ray := PhysicsRayQueryParameters3D.create(
			pos + Vector3.UP * (scatter_size.y / 2.0),
			pos + Vector3.DOWN * (scatter_size.y / 2.0),
			collision_mask)

		var hit := _space.intersect_ray(ray)
		if hit.is_empty(): continue

		var iteration_scale = base_scale

		# Constraints Checks
		if use_angle:
			var off = (abs(hit.normal.x) + abs(hit.normal.z)) / 2
			if not off < angle:
				iteration_scale = Vector3.ZERO

		if iteration_scale > Vector3.ZERO and use_vertex_colors:
			var mesh = find_mesh(hit.collider)
			if mesh:
				var mesh_id = mesh.get_instance_id()
				if not _mesh_data_array.has(mesh_id):
					var mdt = MeshDataTool.new()
					mdt.create_from_surface(mesh.mesh, 0)
					_mesh_data_array[mesh_id] = mdt
				var color = _mesh_data_array[mesh_id].get_vertex_color(get_closest_vertex(_mesh_data_array[mesh_id], mesh.global_transform.origin, hit.position))
				if not (color.r < r_channel && color.g < g_channel && color.b < b_channel):
					iteration_scale = Vector3.ZERO
		
		var t := Transform3D(
			Basis(
				hit.normal.cross(global_transform.basis.z),
				hit.normal,
				global_transform.basis.x.cross(hit.normal),
			).orthonormalized()
		)
		t = t\
			.rotated(Vector3.RIGHT, deg_to_rad(_rng.randf_range(-random_rotation.x, random_rotation.x) + offset_rotation.x))\
			.rotated(Vector3.UP, deg_to_rad(_rng.randf_range(-random_rotation.y, random_rotation.y) + offset_rotation.y))\
			.rotated(Vector3.FORWARD, deg_to_rad(_rng.randf_range(-random_rotation.z, random_rotation.z) + offset_rotation.z))\
			.scaled(iteration_scale * Vector3(
				_rng.randf_range(min_random_size.x, max_random_size.x),
				_rng.randf_range(min_random_size.y, max_random_size.y),
				_rng.randf_range(min_random_size.z, max_random_size.z)))
		t.origin = hit.position - global_position + offset_position
		multimesh.set_instance_transform(i, t)

func get_closest_vertex(mdt: MeshDataTool, mesh_pos: Vector3, hit_pos: Vector3):
	var closest_dist = INF
	var closest_vertex = -1

	for v in range(mdt.get_vertex_count()):
		var v_pos = mdt.get_vertex(v) + mesh_pos
		var tmp = hit_pos.distance_squared_to(v_pos)
		if (tmp <= closest_dist):
			closest_dist = tmp
			closest_vertex = v
	
	return closest_vertex

# Search up and down the tree until a mesh is found (dumb)
func find_mesh(node) -> MeshInstance3D:
	if node is MeshInstance3D: return node
	var up = find_mesh_in_parent(node)
	var down = find_mesh_in_children(node)
	return down if down else up if up else null

func find_mesh_in_parent(node):
	var p = node.get_parent()
	if p == null: return p
	return p if p is MeshInstance3D else find_mesh_in_parent(p)

func find_mesh_in_children(node):
	for c in node.get_children():
		return c if c is MeshInstance3D else find_mesh_in_children(c)
	return null
