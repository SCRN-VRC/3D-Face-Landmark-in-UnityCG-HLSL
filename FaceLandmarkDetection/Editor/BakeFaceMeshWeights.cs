#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEngine.UI;

[ExecuteInEditMode]
public class FaceMeshWeights : EditorWindow
{
    public TextAsset source0;
    string SavePath;

    [MenuItem("Tools/SCRN/Bake FaceMesh Weights")]
    static void Init()
    {
        var window = GetWindowWithRect<FaceMeshWeights>(new Rect(0, 0, 400, 250));
        window.Show();
    }
    
    void OnGUI()
    {
        GUILayout.Label("Bake FaceMesh", EditorStyles.boldLabel);
        EditorGUILayout.BeginVertical();
        source0 = (TextAsset) EditorGUILayout.ObjectField("Bake FaceMesh Weights (.bytes):", source0, typeof(TextAsset), false);
        EditorGUILayout.EndVertical();

        if (GUILayout.Button("Bake!") && source0 != null) {
            string path = AssetDatabase.GetAssetPath(source0);
            int fileDir = path.LastIndexOf("/");
            SavePath = path.Substring(0, fileDir) + "/weights-facemesh.asset";
            OnGenerateTexture();
        }
    }

    void OnGenerateTexture()
    {
        const int width = 1404;
        const int height = 580;

        Texture2D tex = new Texture2D(width, height, TextureFormat.RFloat, false);
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Point;
        tex.anisoLevel = 1;
        
        ExtractFromBin(tex, source0);
        AssetDatabase.CreateAsset(tex, SavePath);
        AssetDatabase.SaveAssets();

        ShowNotification(new GUIContent("Done"));
    }

    void writeBlock(Texture2D tex, BinaryReader br0, int totalFloats, int destX, int destY, int width)
    {
        for (int i = 0; i < totalFloats; i++)
        {
            int x = i % width;
            int y = i / width;
            tex.SetPixel(x + destX, y + destY,
                new Color(br0.ReadSingle(), 0, 0, 0)); //br0.ReadSingle()
        }
    }

    void ExtractFromBin(Texture2D tex, TextAsset srcIn0)
    {
        Stream s0 = new MemoryStream(srcIn0.bytes);
        BinaryReader br0 = new BinaryReader(s0);
        writeBlock(tex, br0, 432, 1292, 416, 16); //const0
        writeBlock(tex, br0, 16, 1373, 416, 1); //const1
        writeBlock(tex, br0, 256, 1356, 416, 16); //const2
        writeBlock(tex, br0, 16, 1375, 416, 1); //const3
        writeBlock(tex, br0, 256, 1340, 416, 16); //const4
        writeBlock(tex, br0, 16, 1374, 416, 1); //const5
        writeBlock(tex, br0, 512, 1308, 416, 32); //const6
        writeBlock(tex, br0, 1024, 1210, 416, 32); //const7
        writeBlock(tex, br0, 32, 1286, 416, 1); //const8
        writeBlock(tex, br0, 1024, 1178, 416, 32); //const9
        writeBlock(tex, br0, 32, 1283, 416, 1); //const10
        writeBlock(tex, br0, 1024, 1114, 416, 32); //const11
        writeBlock(tex, br0, 32, 1279, 416, 1); //const12
        writeBlock(tex, br0, 32, 1275, 416, 1); //const13
        writeBlock(tex, br0, 2048, 1050, 416, 64); //const14
        writeBlock(tex, br0, 64, 1046, 416, 1); //const15
        writeBlock(tex, br0, 4096, 980, 416, 64); //const16
        writeBlock(tex, br0, 64, 1047, 416, 1); //const17
        writeBlock(tex, br0, 4096, 916, 416, 64); //const18
        writeBlock(tex, br0, 64, 1045, 416, 1); //const19
        writeBlock(tex, br0, 8192, 788, 416, 128); //const20
        writeBlock(tex, br0, 128, 785, 416, 1); //const21
        writeBlock(tex, br0, 16384, 267, 416, 128); //const22
        writeBlock(tex, br0, 128, 1392, 288, 1); //const23
        writeBlock(tex, br0, 16384, 1163, 288, 128); //const24
        writeBlock(tex, br0, 128, 1394, 288, 1); //const25
        writeBlock(tex, br0, 16384, 1035, 288, 128); //const26
        writeBlock(tex, br0, 128, 1396, 288, 1); //const27
        writeBlock(tex, br0, 16384, 907, 288, 128); //const28
        writeBlock(tex, br0, 128, 1398, 288, 1); //const29
        writeBlock(tex, br0, 16384, 779, 288, 128); //const30
        writeBlock(tex, br0, 128, 1400, 288, 1); //const31
        writeBlock(tex, br0, 16384, 651, 288, 128); //const32
        writeBlock(tex, br0, 128, 1402, 288, 1); //const33
        writeBlock(tex, br0, 16384, 267, 288, 128); //const34
        writeBlock(tex, br0, 128, 779, 416, 1); //const35
        writeBlock(tex, br0, 16384, 395, 288, 128); //const36
        writeBlock(tex, br0, 1024, 1146, 416, 32); //const37
        writeBlock(tex, br0, 128, 782, 416, 1); //const38
        writeBlock(tex, br0, 4096, 1355, 288, 32); //const39
        writeBlock(tex, br0, 32, 1287, 416, 1); //const40
        writeBlock(tex, br0, 16384, 523, 416, 128); //const41
        writeBlock(tex, br0, 32, 1291, 416, 1); //const42
        writeBlock(tex, br0, 128, 786, 416, 1); //const43
        writeBlock(tex, br0, 16384, 523, 288, 128); //const44
        writeBlock(tex, br0, 128, 781, 416, 1); //const45
        writeBlock(tex, br0, 1024, 1242, 416, 32); //const46
        writeBlock(tex, br0, 32, 1284, 416, 1); //const47
        writeBlock(tex, br0, 16384, 395, 416, 128); //const48
        writeBlock(tex, br0, 128, 1388, 288, 1); //const49
        writeBlock(tex, br0, 16384, 651, 416, 128); //const50
        writeBlock(tex, br0, 128, 1387, 288, 1); //const51
        writeBlock(tex, br0, 4096, 1291, 288, 32); //const52
        writeBlock(tex, br0, 32, 1288, 416, 1); //const53
        writeBlock(tex, br0, 4096, 1323, 288, 32); //const54
        writeBlock(tex, br0, 32, 1281, 416, 1); //const55
        writeBlock(tex, br0, 16, 1376, 416, 1); //const56
        writeBlock(tex, br0, 144, 1370, 468, 16); //const57
        writeBlock(tex, br0, 16, 1372, 416, 1); //const58
        writeBlock(tex, br0, 144, 1354, 468, 16); //const59
        writeBlock(tex, br0, 16, 1377, 416, 1); //const60
        writeBlock(tex, br0, 8, 1402, 454, 2); //const61
        writeBlock(tex, br0, 144, 1338, 468, 16); //const62
        writeBlock(tex, br0, 32, 1278, 416, 1); //const63
        writeBlock(tex, br0, 288, 1372, 441, 32); //const64
        writeBlock(tex, br0, 32, 1280, 416, 1); //const65
        writeBlock(tex, br0, 288, 1306, 468, 32); //const66
        writeBlock(tex, br0, 32, 1282, 416, 1); //const67
        writeBlock(tex, br0, 8, 1402, 450, 2); //const68
        writeBlock(tex, br0, 288, 1306, 459, 32); //const69
        writeBlock(tex, br0, 64, 1049, 416, 1); //const70
        writeBlock(tex, br0, 576, 1308, 432, 64); //const71
        writeBlock(tex, br0, 64, 1044, 416, 1); //const72
        writeBlock(tex, br0, 576, 1308, 441, 64); //const73
        writeBlock(tex, br0, 64, 1048, 416, 1); //const74
        writeBlock(tex, br0, 8, 1402, 458, 2); //const75
        writeBlock(tex, br0, 576, 1306, 450, 64); //const76
        writeBlock(tex, br0, 128, 787, 416, 1); //const77
        writeBlock(tex, br0, 1152, 1172, 484, 128); //const78
        writeBlock(tex, br0, 128, 784, 416, 1); //const79
        writeBlock(tex, br0, 1152, 1178, 475, 128); //const80
        writeBlock(tex, br0, 128, 780, 416, 1); //const81
        writeBlock(tex, br0, 1152, 1050, 466, 128); //const82
        writeBlock(tex, br0, 128, 1399, 288, 1); //const83
        writeBlock(tex, br0, 1152, 1050, 457, 128); //const84
        writeBlock(tex, br0, 128, 1397, 288, 1); //const85
        writeBlock(tex, br0, 1152, 1178, 448, 128); //const86
        writeBlock(tex, br0, 128, 1395, 288, 1); //const87
        writeBlock(tex, br0, 1152, 1044, 484, 128); //const88
        writeBlock(tex, br0, 128, 1393, 288, 1); //const89
        writeBlock(tex, br0, 1152, 1178, 457, 128); //const90
        writeBlock(tex, br0, 128, 1391, 288, 1); //const91
        writeBlock(tex, br0, 1152, 1178, 466, 128); //const92
        writeBlock(tex, br0, 128, 1390, 288, 1); //const93
        writeBlock(tex, br0, 32, 1285, 416, 1); //const94
        writeBlock(tex, br0, 288, 1370, 450, 32); //const95
        writeBlock(tex, br0, 32, 1276, 416, 1); //const96
        writeBlock(tex, br0, 404352, 0, 0, 1404); //const97
        writeBlock(tex, br0, 1404, 0, 576, 1404); //const98
        writeBlock(tex, br0, 2, 1402, 462, 1); //const99
        writeBlock(tex, br0, 1152, 916, 480, 128); //const100
        writeBlock(tex, br0, 288, 1370, 459, 32); //const101
        writeBlock(tex, br0, 1, 0, 577, 1); //const102
        writeBlock(tex, br0, 288, 1338, 459, 32); //const103
        writeBlock(tex, br0, 1152, 1050, 475, 128); //const104
        writeBlock(tex, br0, 32, 1274, 416, 1); //const105
        writeBlock(tex, br0, 1152, 1050, 448, 128); //const106
        writeBlock(tex, br0, 128, 1389, 288, 1); //const107
        writeBlock(tex, br0, 32, 1277, 416, 1); //const108
        writeBlock(tex, br0, 128, 1401, 288, 1); //const109
        writeBlock(tex, br0, 266, 266, 288, 1); //const110
        writeBlock(tex, br0, 1152, 788, 480, 128); //const111
        writeBlock(tex, br0, 128, 1403, 288, 1); //const112
        writeBlock(tex, br0, 76608, 0, 288, 266); //const113
        writeBlock(tex, br0, 288, 1372, 432, 32); //const114
        writeBlock(tex, br0, 32, 1290, 416, 1); //const115
        writeBlock(tex, br0, 32, 1289, 416, 1); //const116
        writeBlock(tex, br0, 128, 783, 416, 1); //const117
    }
}

#endif