<img src="addons/multimesh_scatter/icon.svg" width="64" align="left" />

## MultiMesh Scatter

**A simple tool to randomly place meshes.**

<br clear="left" />

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/E1E5CVWWE)

---

**Note: This plugin was created for Godot v4. If you are using Godot 3.5 (or older), you can find the corresponding plugin in the [3.5 branch](https://github.com/arcaneenergy/godot-multimesh-scatter/tree/3.5).**

---

![random_rotation](https://arcaneenergy.github.io/assets/multimesh_scatter/random_rotation.jpg)

https://user-images.githubusercontent.com/52855634/205499151-2fed5529-d116-400e-817d-a37fefeb8989.mp4

https://user-images.githubusercontent.com/52855634/205499155-1d9bd480-21a9-4b51-9225-40db23342474.mp4

https://user-images.githubusercontent.com/52855634/205499157-723e4ab5-bd87-441a-98ba-3b5a482bf655.mp4

## Features

- Scatter objects in the scene using a MultiMeshInstance node.
- Adjust the instance count, size, and collision layer.
- Randomize size and rotation of each instance.
- Automatically rotates each instance to the normal of the terrain.

## How to use

1. Download this [repository](https://github.com/arcaneenergy/godot-multimesh-scatter) or download the addon from the AsseLib in Godot.
2. Import the addons folder into your project.
3. Activate MultiMesh Scatter under Project > Project Settings > Plugins.
4. Add a MultiMeshScatter node to the scene.

## Parameters

### Scattering
- `count`: The number of instances to generate.
- `scatter_type`: Defines the scatter type. (Box / Sphere)
- `scatter_size`: The size of the bounding box. Enable `show_debug_area` to view the size of the bounding box. Note: If the `scatter_type` is set to Sphere, only the x value will be used to specify the radius of the sphere.
- `collision_mask`: The physics collision mask that the instances should collide with.
- `mesh_instance`: A helper parameter, set a MeshInstance3D here and it's mesh will be used for scattering (avoids having to copy/paste)
### Placement
- `offset_position`: Add an offset to the placed instances.
- `offset_rotation`: Add a rotation offset to the placed instances.
- `base_scale`: Change the base scale of the instanced meshes.
- `min_random_size`: The minimum random size for each instance.
- `max_random_size`: The maximum random size for each instance.
- `random_rotation`: Rotate each instance by a random amount between. `-random_rotation` and `+random_rotation`.
### Advanced
- `use_vertex_colors`: If enabled the scattering will only happen where vertex color of the surface below the specified threshold. (See Below)
- `r_channel`: Scatter threshold for the red channel.
- `g_channel`: Scatter threshold for the green channel.
- `b_channel`: Scatter threshold for the blue channel. 
- `randomize_seed`: Enabling this will randomize the seed then turn this off again (kind of a button in the editor)
- `seed`: A seed to feed for the random number generator.
- `show_debug_area`: Toggle the visibility of the bounding box area.

## Notes

- The sphere placement type takes `placement_size.x` for the radius. The y and z values are not used.
- The sphere placement type behaves more like a capsule shape. This means that only the horizontal radius is taken
  into account when scattering meshes.
- Scattering occurs automatically in the editor whenever you change a parameter or move the MultiMeshScatter node.
  In game mode, the scatter occurs once at the beginning of the game.

## Links

- [MultiMesh Scatter](https://github.com/arcaneenergy/godot-multimesh-scatter)
- [Homepage](https://arcaneenergy.github.io/)
- [YouTube](https://www.youtube.com/c/ArcaneEnergy)
- [Ko-fi](https://ko-fi.com/arcaneenergy)

## License

[MIT License](/LICENSE.md)
