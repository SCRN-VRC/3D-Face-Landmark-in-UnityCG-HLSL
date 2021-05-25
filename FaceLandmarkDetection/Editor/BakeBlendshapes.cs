#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEngine.UI;

[ExecuteInEditMode]
public class BakeBlendshapes : EditorWindow
{
    public Texture2D defaultShape;
    public SkinnedMeshRenderer smr;
    public Mesh bakedMesh;

    [MenuItem("Tools/SCRN/Bake Blendshapes")]
    static void Init()
    {
        var window = GetWindowWithRect<BakeBlendshapes>(new Rect(0, 0, 400, 250));
        window.Show();
    }

    void OnGUI()
    {
        GUILayout.Label("Bake Blendshapes", EditorStyles.boldLabel);
        EditorGUILayout.BeginVertical();
        smr = (SkinnedMeshRenderer) EditorGUILayout.ObjectField("Skinned Mesh", smr, typeof(SkinnedMeshRenderer), true);
        defaultShape = (Texture2D) EditorGUILayout.ObjectField("Default Blendshape", defaultShape, typeof(Texture2D), false);
        EditorGUILayout.EndVertical();
        if (GUILayout.Button("Bake!") && smr != null) {
            onBake();
        }
    }

    void onBake()
    {
        Texture2D tex = new Texture2D(128, 128, TextureFormat.RGBAFloat, false);
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Point;
        tex.anisoLevel = 1;

        bakedMesh = new Mesh();
        smr.BakeMesh(bakedMesh);
        Vector3[] vertices = bakedMesh.vertices;
        for (int i = 0; i < vertices.Length; i++)
        {
            int x = i % 128;
            int y = i / 128;
            if (defaultShape != null)
            {
                Color pix = defaultShape.GetPixel(x, y);
                Color col = new Color(vertices[i].x, vertices[i].y, vertices[i].z, 0);
                col = col - pix;
                tex.SetPixel(x, y, col);
            }
            else
            {
                Color col = new Color(vertices[i].x, vertices[i].y, vertices[i].z, 0);
                tex.SetPixel(x, y, col);
            }
            //Debug.Log(col);
        }

        AssetDatabase.CreateAsset(tex, "Assets/shape.asset");
        AssetDatabase.SaveAssets();
    }
}

#endif