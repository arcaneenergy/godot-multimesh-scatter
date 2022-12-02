<img src="addons/multimesh_scatter/icon.svg" width="64" align="left" />

## MultiMesh Scatter

**A simple tool to randomly place meshes.**

<br clear="left" />

---

![random_rotation](https://arcaneenergy.github.io/assets/multimesh_scatter/random_rotation.jpg)


https://arcaneenergy.github.io/assets/multimesh_scatter/video_01.mp4

https://arcaneenergy.github.io/assets/multimesh_scatter/video_02.mp4

https://arcaneenergy.github.io/assets/multimesh_scatter/video_03.mp4

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/E1E5CVWWE)

## How to use

1. Download this [repository](https://github.com/arcaneenergy/godot-multimesh-scatter) or download the addon from the AsseLib in Godot.
2. Import the addons folder into your project.
3. Activate MultiMesh Scatter under Project > Project Settings > Plugins.
4. Add a MultiMeshScatter node to the scene.

## Parameters

- `count`: The number of instances to generate.
- `placement_type`: Defines the placement type.
- `placement_size`: The placement size of the bounding box. Enable `show_debug_area` to view the size of the bounding box. Note: If the `placement_type` is set to Sphere, only the x value will be used to specify the radius of the sphere.
- `collision_mask`: The physics collision mask that the instances should collide with.
- `offset_position`: Add an offset to the placed instances.
- `offset_rotation`: Add a rotation offset to the placed instances.
- `base_scale`: Change the base scale of the instanced meshes.
- `min_random_size`: The minimum random size for each instance.
- `max_random_size`: The maximum random size for each instance.
- `random_rotation`: Rotate each instance by a random amount between. `-random_rotation` and `+random_rotation`.
- `seed`: A seed to feed for the random number generator.
- `show_debug_area`: Toggle the visibility of the bounding box area.

## Links

- [MultiMesh Scatter](https://github.com/arcaneenergy/godot-multimesh-scatter)
- [Homepage](https://arcaneenergy.github.io/)
- [YouTube](https://www.youtube.com/c/ArcaneEnergy)
- [Ko-fi](https://ko-fi.com/arcaneenergy)

## License

[MIT License](/LICENSE.md)
