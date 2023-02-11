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

@export_group("Scattering")

## The number of instances to generate.
@export var count := 100:
	get: return count
	set(value):
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
		scatter_size = value.clamp(Vector3.ONE * 0.01, Vector3.ONE * 1000.0)
		_update()

## The physics collision mask that the instances should collide with.
@export_flags_3d_physics var collision_mask := 0x1:
	get: return collision_mask
	set(value):
		collision_mask = value
		_update()

## Setting this value will copy over the MeshInstance's Mesh to the MultiMeshInstance3D.
## This is just for convenience.
@export_node_path("MeshInstance3D") var mesh_instance:
	get: return mesh_instance
	set(value):
		if value:
			var i := get_node(value)
			if i and i.mesh:
				print("[MultiMeshScatter]: Mesh added. You can safely remove the MeshInstance3D.")
				multimesh.mesh = i.mesh
				mesh_instance = null

@export_group("Instance Placement")

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

@export_group("Clustering")

## Clustering will make instances appear in tight groups.
## At 0, the placement will be entirely random.
## At 1, all instances will be grouped close to each other, according to [code]cluster_density[/code].
@export_range(0, 1, 0.01) var clustering_amount = 0.0:
	get: return clustering_amount
	set(value):
		clustering_amount = value
		_update()

## Higher cluster density means clustered instances will be closer together.
## At 0 clustering will have no effect.
## At 1 clustered instances will spawn on top of each other.
@export_range(0, 1, 0.01) var cluster_density = 0.5:
	get: return cluster_density
	set(value):
		cluster_density = value
		_update()

## Allow clusters to go outside the bounds defined by [code]scatter_size[/code]
## This is useful to avoid grid-like patterns appearing when tiling multiple scatterers,
## such as when using the [code]Chunks[/code] settings.
@export var cluster_out_of_bounds := false:
	get: return cluster_out_of_bounds
	set(value):
		cluster_out_of_bounds = value
		_update()

@export_group("Constraints")

@export_subgroup("Face Angle")

## If enabled the scattering will only happen where the collision angle is above the specified threshold.
## This has a non-negligible impact on scattering speed but no impact once the scattering is done.
## This will result in less instances than the set [code]count[/code].
## (Those instances are actually just scaled to 0)
@export var use_angle: bool = false:
	get: return use_angle
	set(value):
		use_angle = value
		_update()

## The minimum angle at which instances can be placed.
@export_range(0, 90, 1, "degrees") var angle_degrees := 90:
	get: return angle_degrees
	set(value):
		angle_degrees = value
		_update()

@export_subgroup("Vertex Color")

## If enabled the scattering will only happen where vertex color of the surface below the specified threshold.
## Note that this can be very expensive. You will need to use Advanced Settings > Debug > Manual Update to update the scattering.
## This will result in less instances than the set [code]count[/code].
## (Those instances are actually just scaled to 0)
@export var use_vertex_colors: bool = false:
	get: return use_vertex_colors
	set(value):
		use_vertex_colors = value
		if value:
			print("[MultiMeshScatter]: Enabling vertex color checks, from now on you will need to manually update the scattering in Advanced Settings > Debug > Manual Update.")
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

@export_group("Chunks")

## The node used to contain the created chunks.
var _chunk_container: Node3D

## The number of instances for each chunk.
@export var count_per_chunk := 100:
	get: return count_per_chunk
	set(value):
		count_per_chunk = value

## The total size of the covered area.
@export var total_size := Vector3(100.0, 100.0, 100.0):
	get: return total_size
	set(value):
		total_size = value.clamp(Vector3.ONE * 0.0, Vector3.ONE * 10000.0)

## The amount of chunks on each axis.
@export var chunk_count := Vector2i(8, 8):
	get: return chunk_count
	set(value):
		chunk_count = value.clamp(Vector2i.ONE * 1, Vector2i.ONE * 1000)

## Click to split the current MultiMeshScatter into multiple smaller instances.
@export var generate_chunks := false:
	get: return generate_chunks
	set(value):
		generate_chunks = false
		if value: _chunkify()

## Click to delete the chunks and re-enable the base MultiMeshScatter.
@export var delete_chunks := false:
	get: return delete_chunks
	set(value):
		delete_chunks = false
		if value:
			_delete_chunks()
			visible = true

@export_group("Advanced Settings")

@export_subgroup("Seed")

## Click to randomize the seed.
@export var randomize_seed := false:
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

@export var manual_update := false:
	get: return manual_update
	set(value):
		_update(true)
		manual_update = false

var _debug_draw_instance: MeshInstance3D
var _rng := RandomNumberGenerator.new()
var _mesh_data_array := {}
var _last_pos: Vector3

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

func _update(force := false) -> void:
	if !_space: return
	scatter(force)

	if Engine.is_editor_hint():
		_update_debug_area_size()

func scatter(force := false) -> void:
	if use_vertex_colors and not force:
		return

	if not _ensure_has_mm():
		printerr("[MultiMeshScatter]: The MultiMeshInstance3D doesn't have an assigned mesh.")
		return

	_rng.state = 0
	_rng.seed = seed

	multimesh.instance_count = 0
	multimesh.instance_count = count

	for i in range(count):
		var offset := Vector3.ZERO

		match scatter_type:
			ScatterType.SPHERE:
				var radius := sqrt(_rng.randf()) * (scatter_size.x / 2.0)
				var theta := _rng.randf_range(0.0, 360.0)
				offset += Vector3(
					radius * cos(theta),
					0.0,
					radius * sin(theta))
			ScatterType.BOX, _:
				offset += Vector3(
					_rng.randf_range(-scatter_size.x / 2.0, scatter_size.x / 2.0),
					0.0,
					_rng.randf_range(-scatter_size.z / 2.0, scatter_size.z / 2.0))

		var pos := global_position + offset

		if _rng.randf() <= clustering_amount:
			if cluster_out_of_bounds:
				pos = _last_pos + offset * (1 - cluster_density)
			else:
				pos = _last_pos + ((pos - _last_pos) * (1 - cluster_density))
		else:
			_last_pos = pos

		var ray := PhysicsRayQueryParameters3D.create(
			pos + Vector3.UP * (scatter_size.y / 2.0),
			pos + Vector3.DOWN * (scatter_size.y / 2.0),
			collision_mask)

		var hit := _space.intersect_ray(ray)
		if hit.is_empty(): continue

		var iteration_scale := base_scale

		# Angle constraints check
		if use_angle:
			var off: float = rad_to_deg((abs(hit.normal.x) + abs(hit.normal.z)) / 2.0)
			if not off < angle_degrees:
				iteration_scale = Vector3.ZERO

		# Vertex color placement
		if iteration_scale > Vector3.ZERO and use_vertex_colors:
			var mesh := _find_mesh(hit.collider)
			if mesh:
				var mesh_id := mesh.get_instance_id()
				if not _mesh_data_array.has(mesh_id):
					var mdt := MeshDataTool.new()
					mdt.create_from_surface(mesh.mesh, 0)
					_mesh_data_array[mesh_id] = mdt
				var color: Color = _mesh_data_array[mesh_id].get_vertex_color(_get_closest_vertex(_mesh_data_array[mesh_id], mesh.global_transform.origin, hit.position))
				if not (color.r <= r_channel && color.g <= g_channel && color.b <= b_channel):
					iteration_scale = Vector3.ZERO
			else:
				printerr("[MultiMeshScatter]: Cannot find mesh for the vertex color check. Make sure '", hit.collider.name, "' has a MeshInstance3D as a parent.")

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

func _get_closest_vertex(mdt: MeshDataTool, mesh_pos: Vector3, hit_pos: Vector3) -> int:
	var closest_dist := INF
	var closest_vertex := -1

	for v in range(mdt.get_vertex_count()):
		var v_pos := mdt.get_vertex(v) + mesh_pos
		var tmp := hit_pos.distance_squared_to(v_pos)
		if tmp <= closest_dist:
			closest_dist = tmp
			closest_vertex = v

	return closest_vertex

func _find_mesh(node: Node) -> MeshInstance3D:
	var p := node.get_parent()
	if p == null: return p
	return p if p is MeshInstance3D else _find_mesh(p)

func _chunkify() -> void:
	var container := _get_chunk_container()
	if not container:
		printerr("[MultiMeshScatter]: No container found for the chunks.")
		return

	_empty_chunks()
	visible = true

	var chunks := []
	var size := Vector2(total_size.x / chunk_count.x, total_size.z / chunk_count.y)
	for i in chunk_count.x:
		for j in chunk_count.y:
			var chunk := duplicate()
			chunk.multimesh = null

			chunk.set_meta('pos', Vector3(
				global_transform.origin.x + (i * size.x) - (total_size.x/2) + (size.x/2),
				global_transform.origin.y,
				global_transform.origin.z + (j * size.y) - (total_size.z/2) + (size.y/2)
			))

			chunk._ensure_has_mm()
			chunk.multimesh.mesh = multimesh.mesh

			chunk.count = count_per_chunk
			chunk.scatter_size = Vector3(size.x, scatter_size.y, size.y)

			chunks.push_back(chunk)

	visible = false
	for chunk in chunks:
		container.add_child(chunk)
		chunk.owner = container.owner
		chunk.global_transform.origin = chunk.get_meta("pos")
		chunk.randomize_seed = true
		if use_vertex_colors:
			chunk.manual_update = true

func _get_chunk_container() -> Node3D:
	if not _chunk_container or not _chunk_container.get_parent():
		_chunk_container = Node3D.new()
		_chunk_container.name = name + "Chunks"
		get_parent().add_child(_chunk_container)
		_chunk_container.owner = owner
	return _chunk_container

func _empty_chunks() -> void:
	var container := _get_chunk_container()
	for c in container.get_children():
		container.remove_child(c)
		c.queue_free()

func _delete_chunks() -> void:
	_empty_chunks()
	if _chunk_container:
		if _chunk_container.is_inside_tree():
			_chunk_container.get_parent().remove_child(_chunk_container)
		_chunk_container.queue_free()
