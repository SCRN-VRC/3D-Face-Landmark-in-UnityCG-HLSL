#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEngine.UI;

[ExecuteInEditMode]
public class IrisWeights : EditorWindow
{
    public TextAsset source0;
    string SavePath;

    [MenuItem("Tools/SCRN/Bake Iris Weights")]
    static void Init()
    {
        var window = GetWindowWithRect<IrisWeights>(new Rect(0, 0, 400, 250));
        window.Show();
    }
    
    void OnGUI()
    {
        GUILayout.Label("Bake Iris", EditorStyles.boldLabel);
        EditorGUILayout.BeginVertical();
        source0 = (TextAsset) EditorGUILayout.ObjectField("Bake Iris Weights (.bytes):", source0, typeof(TextAsset), false);
        EditorGUILayout.EndVertical();

        if (GUILayout.Button("Bake!") && source0 != null) {
            string path = AssetDatabase.GetAssetPath(source0);
            int fileDir = path.LastIndexOf("/");
            SavePath = path.Substring(0, fileDir) + "/weights-iris.asset";
            OnGenerateTexture();
        }
    }

    void OnGenerateTexture()
    {
        const int width = 1024;
        const int height = 700;

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
        writeBlock(tex, br0, 288, 411, 597, 9); //const0
        writeBlock(tex, br0, 64, 136, 597, 1); //const1
        writeBlock(tex, br0, 64, 132, 597, 1); //const2
        writeBlock(tex, br0, 64, 927, 641, 64); //const3
        writeBlock(tex, br0, 64, 116, 597, 1); //const4
        writeBlock(tex, br0, 32, 445, 597, 1); //const5
        writeBlock(tex, br0, 2048, 800, 576, 32); //const6
        writeBlock(tex, br0, 576, 1013, 576, 9); //const7
        writeBlock(tex, br0, 32768, 512, 384, 512); //const8
        writeBlock(tex, br0, 576, 81, 597, 9); //const9
        writeBlock(tex, br0, 128, 671, 641, 128); //const10
        writeBlock(tex, br0, 64, 102, 597, 1); //const11
        writeBlock(tex, br0, 64, 915, 653, 64); //const12
        writeBlock(tex, br0, 64, 114, 597, 1); //const13
        writeBlock(tex, br0, 64, 118, 597, 1); //const14
        writeBlock(tex, br0, 64, 120, 597, 1); //const15
        writeBlock(tex, br0, 128, 670, 642, 128); //const16
        writeBlock(tex, br0, 576, 27, 597, 9); //const17
        writeBlock(tex, br0, 576, 63, 597, 9); //const18
        writeBlock(tex, br0, 8192, 192, 213, 64); //const19
        writeBlock(tex, br0, 8192, 256, 213, 64); //const20
        writeBlock(tex, br0, 128, 798, 643, 128); //const21
        writeBlock(tex, br0, 64, 140, 597, 1); //const22
        writeBlock(tex, br0, 64, 851, 653, 64); //const23
        writeBlock(tex, br0, 64, 144, 597, 1); //const24
        writeBlock(tex, br0, 2048, 864, 576, 32); //const25
        writeBlock(tex, br0, 128, 963, 0, 1); //const26
        writeBlock(tex, br0, 2048, 210, 597, 64); //const27
        writeBlock(tex, br0, 128, 965, 0, 1); //const28
        writeBlock(tex, br0, 64, 787, 653, 64); //const29
        writeBlock(tex, br0, 8192, 448, 213, 64); //const30
        writeBlock(tex, br0, 64, 723, 653, 64); //const31
        writeBlock(tex, br0, 8192, 256, 533, 128); //const32
        writeBlock(tex, br0, 576, 995, 576, 9); //const33
        writeBlock(tex, br0, 64, 138, 597, 1); //const34
        writeBlock(tex, br0, 2, 670, 640, 1); //const35
        writeBlock(tex, br0, 32, 442, 597, 1); //const36
        writeBlock(tex, br0, 128, 974, 0, 1); //const37
        writeBlock(tex, br0, 64, 134, 597, 1); //const38
        writeBlock(tex, br0, 64, 131, 597, 1); //const39
        writeBlock(tex, br0, 32768, 0, 405, 512); //const40
        writeBlock(tex, br0, 128, 788, 645, 128); //const41
        writeBlock(tex, br0, 576, 986, 576, 9); //const42
        writeBlock(tex, br0, 64, 851, 652, 64); //const43
        writeBlock(tex, br0, 64, 129, 597, 1); //const44
        writeBlock(tex, br0, 64, 723, 652, 64); //const45
        writeBlock(tex, br0, 64, 126, 597, 1); //const46
        writeBlock(tex, br0, 8192, 128, 213, 64); //const47
        writeBlock(tex, br0, 2048, 146, 597, 64); //const48
        writeBlock(tex, br0, 8192, 64, 213, 64); //const49
        writeBlock(tex, br0, 64, 659, 652, 64); //const50
        writeBlock(tex, br0, 128, 980, 0, 1); //const51
        writeBlock(tex, br0, 576, 0, 597, 9); //const52
        writeBlock(tex, br0, 128, 979, 0, 1); //const53
        writeBlock(tex, br0, 8192, 0, 213, 64); //const54
        writeBlock(tex, br0, 32, 438, 597, 1); //const55
        writeBlock(tex, br0, 32, 990, 642, 32); //const56
        writeBlock(tex, br0, 8192, 897, 128, 64); //const57
        writeBlock(tex, br0, 8192, 833, 128, 64); //const58
        writeBlock(tex, br0, 8192, 640, 512, 128); //const59
        writeBlock(tex, br0, 64, 117, 597, 1); //const60
        writeBlock(tex, br0, 64, 851, 651, 64); //const61
        writeBlock(tex, br0, 128, 976, 0, 1); //const62
        writeBlock(tex, br0, 64, 659, 651, 64); //const63
        writeBlock(tex, br0, 128, 973, 0, 1); //const64
        writeBlock(tex, br0, 128, 972, 0, 1); //const65
        writeBlock(tex, br0, 8192, 769, 128, 64); //const66
        writeBlock(tex, br0, 64, 113, 597, 1); //const67
        writeBlock(tex, br0, 1728, 896, 576, 27); //const68
        writeBlock(tex, br0, 16384, 512, 448, 256); //const69
        writeBlock(tex, br0, 128, 970, 0, 1); //const70
        writeBlock(tex, br0, 576, 1004, 576, 9); //const71
        writeBlock(tex, br0, 64, 112, 597, 1); //const72
        writeBlock(tex, br0, 64, 109, 597, 1); //const73
        writeBlock(tex, br0, 64, 108, 597, 1); //const74
        writeBlock(tex, br0, 32, 991, 640, 32); //const75
        writeBlock(tex, br0, 576, 950, 576, 9); //const76
        writeBlock(tex, br0, 576, 959, 576, 9); //const77
        writeBlock(tex, br0, 288, 420, 597, 9); //const78
        writeBlock(tex, br0, 8, 659, 640, 1); //const79
        writeBlock(tex, br0, 15, 658, 640, 1); //const80
        writeBlock(tex, br0, 64, 104, 597, 1); //const81
        writeBlock(tex, br0, 64, 141, 597, 1); //const82
        writeBlock(tex, br0, 32, 441, 597, 1); //const83
        writeBlock(tex, br0, 8192, 641, 128, 64); //const84
        writeBlock(tex, br0, 576, 9, 597, 9); //const85
        writeBlock(tex, br0, 2048, 274, 597, 64); //const86
        writeBlock(tex, br0, 8192, 128, 469, 128); //const87
        writeBlock(tex, br0, 64, 100, 597, 1); //const88
        writeBlock(tex, br0, 128, 962, 0, 1); //const89
        writeBlock(tex, br0, 64, 915, 649, 64); //const90
        writeBlock(tex, br0, 128, 788, 647, 128); //const91
        writeBlock(tex, br0, 8192, 577, 128, 64); //const92
        writeBlock(tex, br0, 32, 439, 597, 1); //const93
        writeBlock(tex, br0, 576, 90, 597, 9); //const94
        writeBlock(tex, br0, 64, 1022, 576, 1); //const95
        writeBlock(tex, br0, 64, 916, 647, 64); //const96
        writeBlock(tex, br0, 64, 916, 646, 64); //const97
        writeBlock(tex, br0, 128, 964, 0, 1); //const98
        writeBlock(tex, br0, 8192, 833, 0, 64); //const99
        writeBlock(tex, br0, 128, 787, 650, 128); //const100
        writeBlock(tex, br0, 8192, 769, 0, 64); //const101
        writeBlock(tex, br0, 8192, 705, 0, 64); //const102
        writeBlock(tex, br0, 576, 45, 597, 9); //const103
        writeBlock(tex, br0, 64, 106, 597, 1); //const104
        writeBlock(tex, br0, 64, 926, 642, 64); //const105
        writeBlock(tex, br0, 128, 967, 0, 1); //const106
        writeBlock(tex, br0, 128, 968, 0, 1); //const107
        writeBlock(tex, br0, 64, 110, 597, 1); //const108
        writeBlock(tex, br0, 8192, 897, 0, 64); //const109
        writeBlock(tex, br0, 8192, 0, 533, 128); //const110
        writeBlock(tex, br0, 128, 971, 0, 1); //const111
        writeBlock(tex, br0, 8192, 512, 576, 128); //const112
        writeBlock(tex, br0, 128, 659, 650, 128); //const113
        writeBlock(tex, br0, 8192, 577, 0, 64); //const114
        writeBlock(tex, br0, 8192, 768, 512, 128); //const115
        writeBlock(tex, br0, 128, 977, 0, 1); //const116
        writeBlock(tex, br0, 64, 119, 597, 1); //const117
        writeBlock(tex, br0, 32768, 512, 320, 512); //const118
        writeBlock(tex, br0, 2048, 338, 597, 64); //const119
        writeBlock(tex, br0, 32, 991, 641, 32); //const120
        writeBlock(tex, br0, 64, 123, 597, 1); //const121
        writeBlock(tex, br0, 128, 981, 0, 1); //const122
        writeBlock(tex, br0, 64, 125, 597, 1); //const123
        writeBlock(tex, br0, 64, 926, 643, 64); //const124
        writeBlock(tex, br0, 64, 916, 644, 64); //const125
        writeBlock(tex, br0, 64, 128, 597, 1); //const126
        writeBlock(tex, br0, 8192, 512, 512, 128); //const127
        writeBlock(tex, br0, 32, 440, 597, 1); //const128
        writeBlock(tex, br0, 576, 977, 576, 9); //const129
        writeBlock(tex, br0, 8192, 513, 128, 64); //const130
        writeBlock(tex, br0, 64, 133, 597, 1); //const131
        writeBlock(tex, br0, 128, 787, 649, 128); //const132
        writeBlock(tex, br0, 128, 787, 648, 128); //const133
        writeBlock(tex, br0, 8192, 641, 0, 64); //const134
        writeBlock(tex, br0, 576, 18, 597, 9); //const135
        writeBlock(tex, br0, 8192, 640, 576, 128); //const136
        writeBlock(tex, br0, 64, 139, 597, 1); //const137
        writeBlock(tex, br0, 64, 915, 648, 64); //const138
        writeBlock(tex, br0, 128, 961, 0, 1); //const139
        writeBlock(tex, br0, 128, 788, 646, 128); //const140
        writeBlock(tex, br0, 64, 143, 597, 1); //const141
        writeBlock(tex, br0, 64, 787, 652, 64); //const142
        writeBlock(tex, br0, 128, 978, 0, 1); //const143
        writeBlock(tex, br0, 64, 101, 597, 1); //const144
        writeBlock(tex, br0, 64, 915, 652, 64); //const145
        writeBlock(tex, br0, 128, 660, 645, 128); //const146
        writeBlock(tex, br0, 288, 402, 597, 9); //const147
        writeBlock(tex, br0, 8192, 384, 213, 64); //const148
        writeBlock(tex, br0, 8192, 256, 469, 128); //const149
        writeBlock(tex, br0, 32, 444, 597, 1); //const150
        writeBlock(tex, br0, 64, 659, 653, 64); //const151
        writeBlock(tex, br0, 128, 975, 0, 1); //const152
        writeBlock(tex, br0, 128, 660, 644, 128); //const153
        writeBlock(tex, br0, 32, 990, 643, 32); //const154
        writeBlock(tex, br0, 128, 670, 643, 128); //const155
        writeBlock(tex, br0, 128, 798, 642, 128); //const156
        writeBlock(tex, br0, 64, 105, 597, 1); //const157
        writeBlock(tex, br0, 576, 968, 576, 9); //const158
        writeBlock(tex, br0, 8192, 896, 512, 128); //const159
        writeBlock(tex, br0, 64, 659, 654, 64); //const160
        writeBlock(tex, br0, 8192, 320, 213, 64); //const161
        writeBlock(tex, br0, 64, 137, 597, 1); //const162
        writeBlock(tex, br0, 128, 799, 641, 128); //const163
        writeBlock(tex, br0, 8192, 896, 448, 128); //const164
        writeBlock(tex, br0, 576, 932, 576, 9); //const165
        writeBlock(tex, br0, 128, 671, 640, 128); //const166
        writeBlock(tex, br0, 64, 122, 597, 1); //const167
        writeBlock(tex, br0, 128, 969, 0, 1); //const168
        writeBlock(tex, br0, 8192, 384, 533, 128); //const169
        writeBlock(tex, br0, 64, 111, 597, 1); //const170
        writeBlock(tex, br0, 128, 788, 644, 128); //const171
        writeBlock(tex, br0, 64, 145, 597, 1); //const172
        writeBlock(tex, br0, 576, 941, 576, 9); //const173
        writeBlock(tex, br0, 2048, 832, 576, 32); //const174
        writeBlock(tex, br0, 128, 799, 640, 128); //const175
        writeBlock(tex, br0, 64, 915, 650, 64); //const176
        writeBlock(tex, br0, 109056, 0, 0, 512); //const177
        writeBlock(tex, br0, 64, 121, 597, 1); //const178
        writeBlock(tex, br0, 8192, 768, 448, 128); //const179
        writeBlock(tex, br0, 64, 103, 597, 1); //const180
        writeBlock(tex, br0, 288, 429, 597, 9); //const181
        writeBlock(tex, br0, 213, 512, 0, 1); //const182
        writeBlock(tex, br0, 64, 130, 597, 1); //const183
        writeBlock(tex, br0, 576, 36, 597, 9); //const184
        writeBlock(tex, br0, 32, 443, 597, 1); //const185
        writeBlock(tex, br0, 8192, 705, 128, 64); //const186
        writeBlock(tex, br0, 64, 142, 597, 1); //const187
        writeBlock(tex, br0, 64, 723, 651, 64); //const188
        writeBlock(tex, br0, 32768, 0, 341, 512); //const189
        writeBlock(tex, br0, 128, 659, 648, 128); //const190
        writeBlock(tex, br0, 64, 135, 597, 1); //const191
        writeBlock(tex, br0, 64, 916, 645, 64); //const192
        writeBlock(tex, br0, 8192, 128, 533, 128); //const193
        writeBlock(tex, br0, 128, 982, 0, 1); //const194
        writeBlock(tex, br0, 576, 72, 597, 9); //const195
        writeBlock(tex, br0, 64, 927, 640, 64); //const196
        writeBlock(tex, br0, 8192, 513, 0, 64); //const197
        writeBlock(tex, br0, 64, 107, 597, 1); //const198
        writeBlock(tex, br0, 8192, 384, 469, 128); //const199
        writeBlock(tex, br0, 64, 915, 651, 64); //const200
        writeBlock(tex, br0, 128, 659, 649, 128); //const201
        writeBlock(tex, br0, 64, 99, 597, 1); //const202
        writeBlock(tex, br0, 32768, 512, 256, 512); //const203
        writeBlock(tex, br0, 64, 1023, 576, 1); //const204
        writeBlock(tex, br0, 576, 54, 597, 9); //const205
        writeBlock(tex, br0, 128, 966, 0, 1); //const206
        writeBlock(tex, br0, 64, 115, 597, 1); //const207
        writeBlock(tex, br0, 128, 660, 647, 128); //const208
        writeBlock(tex, br0, 64, 787, 651, 64); //const209
        writeBlock(tex, br0, 7680, 146, 640, 512); //const210
        writeBlock(tex, br0, 576, 923, 576, 9); //const211
        writeBlock(tex, br0, 64, 124, 597, 1); //const212
        writeBlock(tex, br0, 64, 127, 597, 1); //const213
        writeBlock(tex, br0, 128, 660, 646, 128); //const214
        writeBlock(tex, br0, 2048, 768, 576, 32); //const215
        writeBlock(tex, br0, 8192, 0, 469, 128); //const216
        writeBlock(tex, br0, 4, 662, 640, 1); //const217
        writeBlock(tex, br0, 4, 661, 640, 1); //const218
        writeBlock(tex, br0, 4, 660, 640, 1); //const219
        writeBlock(tex, br0, 4, 667, 640, 1); //const220
        writeBlock(tex, br0, 4, 663, 640, 1); //const221
        writeBlock(tex, br0, 4, 664, 640, 1); //const222
        writeBlock(tex, br0, 4, 665, 640, 1); //const223
        writeBlock(tex, br0, 4, 666, 640, 1); //const224
        writeBlock(tex, br0, 4, 668, 640, 1); //const225
        writeBlock(tex, br0, 4, 669, 640, 1); //const226
    }
}

#endif