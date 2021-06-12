# 3D Face Landmark in UnityCG HLSL
<img src="./Media/bakapreview.gif" align="middle"/>

### NOTE: This was built and tested with Unity 2018.4.20f1, there may be shader compatibility issues with other versions.

## Overview
Face landmark detection using two MediaPipe models: Facemesh and Iris, implemented inside Unity using over 120 Custom Render Textures.

Designed for mobile platforms, the two networks are perfect for use in VR. Both networks are capped at 60 FPS in this implementation but can be modified to run faster.

<img src="./Media/facemeshout.png" align="middle"/>

***Figure 1. Facemesh Outputs***

The original Facemesh model has three main outputs: face flag, 468 3D face points, and 133 2D contour points (edge points of face, eyes, mouth). My implementation of Facemesh throws out the 133 2D contour outputs to save computation time since I won't be using those.

To retrieve the head rotations, I use SVD (singular value decomposition) on three points outputted from Facemesh to get the rotation matrix. The eye positions are also used to feed into the Iris tracking model.

<img src="./Media/irisout.png" align="middle"/>

***Figure 2. Iris Outputs***

The Iris model has two outputs, same as the original, 71 3D brows and contour points and 5 3D iris points.

At the final step, a shader takes Facemesh and Iris model outputs, calculates blend shape values based on key points and smooths the results.

## Problems
- No face detection, meaning the user must have their face within the center of the input camera.
- SVD (singular value decomposition) not accurate, there isn't any SVD libraries written for HLSL. The only one I found was UnitySVDComputeShader and it only solves 3x3 matrices, meaning I can only use 3 points from Facemesh to solve the rotation.
- Slow implementation, it's only fast cause it's made for mobile devices.

## Setup

**This is more of a tech demo, not made for actual use. If you wish to continue, you'll need to know how to edit shaders.**

## Detailed Rundown

### Facemesh Architecture
<img src="./Media/facemesh.pb.svg" height="512" align="middle"/>

### Iris Architecture
<img src="./Media/iris_landmark.onnx.svg" height="512" align="middle"/>

## Resources
- [MediaPipe Facemesh](https://tfhub.dev/mediapipe/tfjs-model/facemesh/1/default/1)
- [Keijiro's MediaPipe Iris Implementation](https://github.com/keijiro/IrisBarracuda)
- [Procrustes Analysis](https://stackoverflow.com/questions/18925181/procrustes-analysis-with-numpy)
- [UnitySVDComputeShader](https://github.com/vanish87/UnitySVDComputeShader/blob/master/UnitySVDComputeShader/Assets/Math.cginc)
- [CHARLIZE THERON_HEAD](https://sketchfab.com/3d-models/charlize-theron-head-ca8926f4284045c6a2e75a6f7642c851)