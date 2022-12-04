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

enum PlacementType { BOX, SPHERE }

## The number of instances to generate.
@export_range(0, 10000, 1) var count := 100:
	get: return count
	set(value):
		count = value
		_update()

## Defines the placement type.
@export_enum("Box", "Sphere") var placement_type: int = PlacementType.BOX:
	get: return placement_type
	set(value):
		placement_type = value

		if Engine.is_editor_hint():
			_create_debug_area()

		_update()

## The placement size of the bounding box.
## Enable [code]show_debug_area[/code] to view the size of the bounding box.
## [br][br] Note: If the [code]placement_type[/code] is set to Sphere,
## only the x value will be used to specify the radius of the sphere.
@export var placement_size := Vector3(10.0, 10.0, 10.0):
	get: return placement_size
	set(value):
		placement_size = value.clamp(Vector3.ONE * 0.01, Vector3.ONE * 100.0)
		_update()

## The physics collision mask that the instances should collide with.
@export_flags_3d_physics var collision_mask := 0x1:
	get: return collision_mask
	set(value):
		collision_mask = value
		_update()

@export_group("Offset")

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

@export_group("Random Size")

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

@export_group("Random Rotation")

## Rotate each instance by a random amount between
## [code]-random_rotation[/code] and +[code]random_rotation[/code].
@export var random_rotation := Vector3(0.0, 0.0, 0.0):
	get: return random_rotation
	set(value):
		random_rotation = value.clamp(Vector3.ONE * 0.00, Vector3.ONE * 180.0)
		_update()

@export_group("Advanced parameters")

## A seed to feed for the random number generator.
@export_range(0, 10000, 1) var seed := 0:
	get: return seed
	set(value):
		seed = value
		_rng.seed = value
		_update()

@export_group("Debug")

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

@onready var _space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

func _init() -> void:
	if multimesh == null:
		multimesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D

func _ready() -> void:
	_rng.seed = seed

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
	match placement_type:
		PlacementType.SPHERE:
			mesh = SphereMesh.new()
		PlacementType.BOX, _:
			mesh = BoxMesh.new()

	_debug_draw_instance.mesh = mesh
	_debug_draw_instance.visible = show_debug_area

	add_child(_debug_draw_instance)
	_update_debug_area_size()

func _update_debug_area_size() -> void:
	if _debug_draw_instance != null && _debug_draw_instance.is_inside_tree():
		match placement_type:
			PlacementType.SPHERE:
				_debug_draw_instance.mesh.radius = placement_size.x / 2.0
				_debug_draw_instance.mesh.height = placement_size.x
			PlacementType.BOX, _:
				_debug_draw_instance.mesh.size = placement_size

func _update() -> void:
	if !_space: return
	scatter()

	if Engine.is_editor_hint():
		_update_debug_area_size()

func scatter() -> void:
	_rng.state = 0
	_rng.seed = seed

	multimesh.instance_count = 0
	multimesh.instance_count = count

	for i in range(count):
		var pos := global_position

		match placement_type:
			PlacementType.SPHERE:
				var radius := sqrt(_rng.randf()) * (placement_size.x / 2.0)
				var theta := _rng.randf_range(0.0, 360.0)
				pos += Vector3(
					radius * cos(theta),
					0.0,
					radius * sin(theta))
			PlacementType.BOX, _:
				pos += Vector3(
					_rng.randf_range(-placement_size.x / 2.0, placement_size.x / 2.0),
					0.0,
					_rng.randf_range(-placement_size.z / 2.0, placement_size.z / 2.0))

		var ray := PhysicsRayQueryParameters3D.create(
			pos + Vector3.UP * (placement_size.y / 2.0),
			pos + Vector3.DOWN * (placement_size.y / 2.0),
			collision_mask)

		var hit := _space.intersect_ray(ray)
		if hit.is_empty(): continue

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
			.scaled(base_scale * Vector3(
				_rng.randf_range(min_random_size.x, max_random_size.x),
				_rng.randf_range(min_random_size.y, max_random_size.y),
				_rng.randf_range(min_random_size.z, max_random_size.z)))
		t.origin = hit.position - global_position + offset_position
		multimesh.set_instance_transform(i, t)
