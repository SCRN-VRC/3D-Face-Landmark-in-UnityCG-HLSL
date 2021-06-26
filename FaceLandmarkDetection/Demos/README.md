# Demos

Each demo contains a simple scene to show off how the networks are used.

To view this in Unity, either clone the entire repo or download the latest Unity package in [Release](https://github.com/SCRN-VRC/3D-Face-Landmark-in-UnityCG-HLSL/releases)

Prefabs are included for VRChat, however, mesh deformation with **Face Landmark Detection** requires a complex setup process [here](https://github.com/SCRN-VRC/3D-Face-Landmark-in-UnityCG-HLSL#avatar-setup).

### Bricks Game
<img src="https://raw.githubusercontent.com/SCRN-VRC/3D-Face-Landmark-in-UnityCG-HLSL/main/Media/brickspreview.gif" height="256" align="middle"/>

- Simple demo using the rotation of the head to control the paddle.
- Game converted to HLSL from iq's [Bricks Game](https://www.shadertoy.com/view/MddGzf).
- Game is not synced :( people will see different outputs.

### Face Landmark Detection
<img src="https://raw.githubusercontent.com/SCRN-VRC/3D-Face-Landmark-in-UnityCG-HLSL/main/Media/bakapreview.gif" height="256" align="middle"/>

- Demo of using both Facemesh and Iris networks to drive an avatar head and eye positions.
- Setup process [here](https://github.com/SCRN-VRC/3D-Face-Landmark-in-UnityCG-HLSL#avatar-setup).