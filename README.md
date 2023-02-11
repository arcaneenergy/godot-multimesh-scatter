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


A simple tool to randomly place meshes.

## 🧩 Features

- Scatter objects in the scene. Instances automatically rotate to the normal of the terrain.
- Adjust the scatter type, size and collision layer and randomize the size and rotation.
- Clustering: Place instances in tight groups together.
- Apply advanced constraint options to scatter according to:
  - Terrain angle
  - Vertex color
- Chunks: Split the MultiMeshScatter node into chunks.

## 🚀 Install & Use

1. Download this [repository](https://github.com/arcaneenergy/godot-multimesh-scatter) or download the addon from the asset library inside Godot.
    - Import the addons folder into your project (if it already isn't present).
2. Activate the MultiMesh Scatter addon under Project > Project Settings > Plugins. If an error dialog appears, restart the engine and try activating it again.
3. Add a MultiMeshScatter node to the scene.

## ⚠️ Notes

- The sphere placement type takes `placement_size.x` for the radius. The y and z values are not used.
- The sphere placement type behaves more like a capsule shape. This means that only the horizontal radius is taken into account when scattering meshes.
- Scattering occurs automatically in the editor whenever you change a parameter or move the MultiMeshScatter node. In game mode, the scatter occurs once at the beginning of the game.

## 🏠 Links

- [MultiMesh Scatter](https://github.com/arcaneenergy/godot-multimesh-scatter)
- [Homepage](https://arcaneenergy.github.io/)
- [YouTube](https://www.youtube.com/c/ArcaneEnergy)
- [Ko-fi](https://ko-fi.com/arcaneenergy)

## 🗒️ License

[MIT License](/LICENSE.md)
