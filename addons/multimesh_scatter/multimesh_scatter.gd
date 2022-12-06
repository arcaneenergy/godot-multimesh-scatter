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

tool
extends MultiMeshInstance

enum PlacementType { BOX, SPHERE }

## The number of instances to generate.
export(int, 0, 10000) var count := 100 setget set_count, get_count
func get_count(): return count
func set_count(value):
	count = value
	_update()

## Defines the placement type.
export(int, "Box", "Sphere") var placement_type: int = PlacementType.BOX setget set_placement_type, get_placement_type
func get_placement_type(): return placement_type
func set_placement_type(value):
	placement_type = value

	if Engine.is_editor_hint():
		_create_debug_area()

	_update()

## The placement size of the bounding box.
## Enable [code]show_debug_area[/code] to view the size of the bounding box.
## [br][br] Note: If the [code]placement_type[/code] is set to Sphere,
## only the x value will be used to specify the radius of the sphere.
export var placement_size := Vector3(10.0, 10.0, 10.0) setget set_placement_size, get_placement_size
func get_placement_size(): return placement_size
func set_placement_size(value):
	placement_size = Vector3(
		clamp(value.x, 0.01, 100.0),
		clamp(value.y, 0.01, 100.0),
		clamp(value.z, 0.01, 100.0))
	_update()

## The physics collision mask that the instances should collide with.
export(int, LAYERS_3D_PHYSICS) var collision_mask := 0x1 setget set_collision_mask, get_collision_mask
func get_collision_mask(): return collision_mask
func set_collision_mask(value):
	collision_mask = value
	_update()

#export_group("Offset")

## Add an offset to the placed instances.
export var offset_position := Vector3(0.0, 0.0, 0.0) setget set_offset_position, get_offset_position
func get_offset_position(): return offset_position
func set_offset_position(value):
	offset_position = value
	_update()

## Add a rotation offset to the placed instances.
export var offset_rotation := Vector3(0.0, 0.0, 0.0) setget set_offset_rotation, get_offset_rotation
func get_offset_rotation(): return offset_rotation
func set_offset_rotation(value):
	offset_rotation = value
	_update()

## Change the base scale of the instanced meshes.
export var base_scale := Vector3(1.0, 1.0, 1.0) setget set_base_scale, get_base_scale
func get_base_scale(): return base_scale
func set_base_scale(value):
#	base_scale = value
	base_scale = Vector3(
		clamp(value.x, 0.01, 100.0),
		clamp(value.y, 0.01, 100.0),
		clamp(value.z, 0.01, 100.0))
	_update()

#export_group("Random Size")

## The minimum random size for each instance.
export var min_random_size := Vector3(0.75, 0.75, 0.75) setget set_min_random_size, get_min_random_size
func get_min_random_size(): return min_random_size
func set_min_random_size(value):
	min_random_size = Vector3(
		clamp(value.x, 0.01, 100.0),
		clamp(value.y, 0.01, 100.0),
		clamp(value.z, 0.01, 100.0))
	_update()

## The maximum random size for each instance.
export var max_random_size := Vector3(1.25, 1.25, 1.25) setget set_max_random_size, get_max_random_size
func get_max_random_size(): return max_random_size
func set_max_random_size(value):
	max_random_size = Vector3(
		clamp(value.x, 0.01, 100.0),
		clamp(value.y, 0.01, 100.0),
		clamp(value.z, 0.01, 100.0))
	_update()

#export_group("Random Rotation")

## Rotate each instance by a random amount between
## [code]-random_rotation[/code] and +[code]random_rotation[/code].
export var random_rotation := Vector3(0.0, 0.0, 0.0) setget set_random_rotation, get_random_rotation
func get_random_rotation(): return random_rotation
func set_random_rotation(value):
	random_rotation = Vector3(
		clamp(value.x, 0.0, 180.0),
		clamp(value.y, 0.0, 180.0),
		clamp(value.z, 0.0, 180.0))
	_update()

#export_group("Advanced parameters")

## A seed to feed for the random number generator.
export(int, 0, 10000) var seed_p := 0 setget set_seed_p, get_seed_p
func get_seed_p(): return seed_p
func set_seed_p(value):
	seed_p = value
	_rng.seed = value
	_update()

#@export_group("Debug")

## Toggle the visibility of the bounding box area.
export var show_debug_area := true setget set_show_debug_area, get_show_debug_area
func get_show_debug_area(): return show_debug_area
func set_show_debug_area(value):
	show_debug_area = value

	if value && Engine.is_editor_hint():
		_create_debug_area()
	else:
		_delete_debug_area()

var _debug_draw_instance: MeshInstance
var _rng := RandomNumberGenerator.new()

onready var _space: PhysicsDirectSpaceState = get_world().direct_space_state

func _init() -> void:
	if multimesh == null:
		multimesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D

func _ready() -> void:
	_rng.seed = seed_p

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
	_debug_draw_instance = MeshInstance.new()

	var material := SpatialMaterial.new()
	_debug_draw_instance.material_override = material

	material.flags_transparent = true
	material.flags_no_depth_test = true
#	material.cull_mode = SpatialMaterial.CULL_DISABLED
#	material.shading_mode = SpatialMaterial.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.0, 0.0, 0.0784313725)

	var mesh: Mesh
	match placement_type:
		PlacementType.SPHERE:
			mesh = SphereMesh.new()
		PlacementType.BOX, _:
			mesh = CubeMesh.new()

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
	_rng.seed = seed_p

	multimesh.instance_count = 0
	multimesh.instance_count = count

	for i in range(count):
		var pos := global_translation

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

		var hit := _space.intersect_ray(
			pos + Vector3.UP * (placement_size.y / 2.0),
			pos + Vector3.DOWN * (placement_size.y / 2.0),
			[],
			collision_mask)
		if hit.empty(): continue

		var t := Transform(
			Basis(
				hit.normal.cross(global_transform.basis.z),
				hit.normal,
				global_transform.basis.x.cross(hit.normal)
			).orthonormalized()
		)
		t = t\
			.rotated(Vector3.RIGHT, deg2rad(_rng.randf_range(-random_rotation.x, random_rotation.x) + offset_rotation.x))\
			.rotated(Vector3.UP, deg2rad(_rng.randf_range(-random_rotation.y, random_rotation.y) + offset_rotation.y))\
			.rotated(Vector3.FORWARD, deg2rad(_rng.randf_range(-random_rotation.z, random_rotation.z) + offset_rotation.z))\
			.scaled(base_scale * Vector3(
				_rng.randf_range(min_random_size.x, max_random_size.x),
				_rng.randf_range(min_random_size.y, max_random_size.y),
				_rng.randf_range(min_random_size.z, max_random_size.z)))
		t.origin = hit.position - global_translation + offset_position
		multimesh.set_instance_transform(i, t)
