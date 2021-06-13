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
    public SkinnedMeshRenderer smr;
    private Vector2 scrollPos;
    private int [] shapes;
    private string [] blendList;
    private string [] labels =
    {
        "1. blink right",
        "2. blink left",
        "3. right brow inner down",
        "4. right brow outer down",
        "5. left brow inner down",
        "6. left brow outer down",
        "7. right eye looking in",
        "8. right eye looking out",
        "9. right eye looking up",
        "10. right eye looking down",
        "11. left eye looking in",
        "12. left eye looking out",
        "13. left eye looking up",
        "14. left eye looking down",
        "15. mouth wide open",
        "16. mouth shrink",
        "17. mouth smile",
        "18. mouth frown",
    };

    [MenuItem("Tools/SCRN/Bake Blendshapes")]
    static void Init()
    {
        var window = GetWindowWithRect<BakeBlendshapes>(new Rect(0, 0, 350, 600));
        window.Show();
    }

    public string [] getBlendShapeNames (Mesh m)
    {
        string[] arr;
        arr = new string [m.blendShapeCount];
        for (int i= 0; i < m.blendShapeCount; i++)
        {
            string s = m.GetBlendShapeName(i);
            //Debug.Log("Blend Shape: " + i + " " + s);
            arr[i] = s;
        }
        return arr;
    }

    void onBake()
    {
        Texture2D tex = new Texture2D(640, 512, TextureFormat.RGBAFloat, false);
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Point;
        tex.anisoLevel = 1;

        Mesh mesh = smr.sharedMesh;
        for (int i = 0; i < 18; i++)
        {
            // Thank you Raliv for the example :)
            Vector3[] dV = new Vector3[mesh.vertexCount];
            Vector3[] dN = new Vector3[mesh.vertexCount];
            Vector3[] dT = new Vector3[mesh.vertexCount];
            Vector3[] v = mesh.vertices;
            Vector3[] n = mesh.normals;
            Vector4[] t = mesh.tangents;

            mesh.GetBlendShapeFrameVertices(shapes[i], 0, dV, dN, dT);
            for (int j = 0; j < mesh.vertexCount; j++)
            {
                if (j > 16383) continue; // 128 x 128 max texture block size
                int x = j % 128 + (i % 5) * 128;
                int y = j / 128 + (i / 5) * 128;
                Vector3 deltaVert = dV[j];
                float tn=Vector3.Project(deltaVert, n[j]).magnitude * Mathf.Sign(Vector3.Dot(deltaVert, n[j]));
                float tt=Vector3.Project(deltaVert, t[j]).magnitude * Mathf.Sign(Vector3.Dot(deltaVert, t[j]));
                float tb=Vector3.Project(deltaVert, Vector3.Cross(n[j].normalized, t[j].normalized)).magnitude * Mathf.Sign(Vector3.Dot(deltaVert, Vector3.Cross(n[j].normalized, t[j].normalized)));
                Color col = new Color(tn, tt, tb, 0);
                //Debug.Log(dV);
                tex.SetPixel(x, y, col);
            }
        }
        string savePath = "Assets/FaceLandmarkDetection/" + smr.name + "_blendBaked.asset";
        AssetDatabase.CreateAsset(tex, savePath);
        AssetDatabase.SaveAssets();
    }

    void OnGUI()
    {
        GUILayout.Label("Bake Blendshapes", EditorStyles.boldLabel);
        EditorGUILayout.BeginVertical();
        smr = (SkinnedMeshRenderer) EditorGUILayout.ObjectField("Skinned Mesh", smr, typeof(SkinnedMeshRenderer), true);
        if (smr == null)
        {
            this.ShowNotification(new GUIContent("No game object selected"));
        }
        else
        {
            this.RemoveNotification();
            if (shapes == null) shapes = new int[18];
            if (blendList == null) blendList = getBlendShapeNames(smr.GetComponent<SkinnedMeshRenderer>().sharedMesh);
            scrollPos = EditorGUILayout.BeginScrollView(scrollPos, GUILayout.Width(350), GUILayout.Height(530));
            for (int i = 0; i < 18; i++)
            {
                EditorGUILayout.LabelField(labels[i], EditorStyles.label);
                shapes[i] = EditorGUILayout.Popup(shapes[i], blendList);
            }
            EditorGUILayout.EndScrollView();
            if (GUILayout.Button("Bake!") && smr != null) {
                onBake();
            }
        }
        EditorGUILayout.EndVertical();
    }
}

#endif