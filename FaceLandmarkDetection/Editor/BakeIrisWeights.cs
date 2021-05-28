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
        writeBlock(tex, br0, 288, 832, 649, 32); //const0
        writeBlock(tex, br0, 64, 448, 663, 64); //const1
        writeBlock(tex, br0, 64, 640, 661, 64); //const2
        writeBlock(tex, br0, 64, 916, 576, 1); //const3
        writeBlock(tex, br0, 64, 960, 659, 64); //const4
        writeBlock(tex, br0, 32, 416, 664, 32); //const5
        writeBlock(tex, br0, 2048, 0, 640, 64); //const6
        writeBlock(tex, br0, 576, 832, 640, 64); //const7
        writeBlock(tex, br0, 32768, 405, 0, 64); //const8
        writeBlock(tex, br0, 576, 704, 649, 64); //const9
        writeBlock(tex, br0, 128, 1007, 0, 1); //const10
        writeBlock(tex, br0, 64, 960, 660, 64); //const11
        writeBlock(tex, br0, 64, 897, 576, 1); //const12
        writeBlock(tex, br0, 64, 320, 662, 64); //const13
        writeBlock(tex, br0, 64, 576, 662, 64); //const14
        writeBlock(tex, br0, 64, 192, 664, 64); //const15
        writeBlock(tex, br0, 128, 1004, 0, 1); //const16
        writeBlock(tex, br0, 576, 192, 649, 64); //const17
        writeBlock(tex, br0, 576, 960, 640, 64); //const18
        writeBlock(tex, br0, 8192, 804, 384, 128); //const19
        writeBlock(tex, br0, 8192, 548, 384, 128); //const20
        writeBlock(tex, br0, 128, 998, 0, 1); //const21
        writeBlock(tex, br0, 64, 896, 663, 64); //const22
        writeBlock(tex, br0, 64, 917, 576, 1); //const23
        writeBlock(tex, br0, 64, 768, 663, 64); //const24
        writeBlock(tex, br0, 2048, 923, 608, 64); //const25
        writeBlock(tex, br0, 128, 896, 656, 128); //const26
        writeBlock(tex, br0, 2048, 864, 576, 32); //const27
        writeBlock(tex, br0, 128, 320, 660, 128); //const28
        writeBlock(tex, br0, 64, 905, 576, 1); //const29
        writeBlock(tex, br0, 8192, 0, 576, 128); //const30
        writeBlock(tex, br0, 64, 898, 576, 1); //const31
        writeBlock(tex, br0, 8192, 740, 128, 64); //const32
        writeBlock(tex, br0, 576, 640, 640, 64); //const33
        writeBlock(tex, br0, 64, 512, 663, 64); //const34
        writeBlock(tex, br0, 2, 575, 664, 2); //const35
        writeBlock(tex, br0, 32, 288, 664, 32); //const36
        writeBlock(tex, br0, 128, 896, 651, 128); //const37
        writeBlock(tex, br0, 64, 192, 663, 64); //const38
        writeBlock(tex, br0, 64, 896, 662, 64); //const39
        writeBlock(tex, br0, 32768, 277, 0, 64); //const40
        writeBlock(tex, br0, 128, 1013, 0, 1); //const41
        writeBlock(tex, br0, 576, 384, 649, 64); //const42
        writeBlock(tex, br0, 64, 908, 576, 1); //const43
        writeBlock(tex, br0, 64, 832, 662, 64); //const44
        writeBlock(tex, br0, 64, 913, 576, 1); //const45
        writeBlock(tex, br0, 64, 768, 662, 64); //const46
        writeBlock(tex, br0, 8192, 804, 320, 128); //const47
        writeBlock(tex, br0, 2048, 768, 576, 32); //const48
        writeBlock(tex, br0, 8192, 676, 384, 128); //const49
        writeBlock(tex, br0, 64, 918, 576, 1); //const50
        writeBlock(tex, br0, 128, 896, 652, 128); //const51
        writeBlock(tex, br0, 576, 384, 640, 64); //const52
        writeBlock(tex, br0, 128, 896, 655, 128); //const53
        writeBlock(tex, br0, 8192, 0, 512, 128); //const54
        writeBlock(tex, br0, 32, 352, 664, 32); //const55
        writeBlock(tex, br0, 32, 987, 576, 1); //const56
        writeBlock(tex, br0, 8192, 384, 512, 128); //const57
        writeBlock(tex, br0, 8192, 512, 512, 128); //const58
        writeBlock(tex, br0, 8192, 804, 0, 64); //const59
        writeBlock(tex, br0, 64, 192, 662, 64); //const60
        writeBlock(tex, br0, 64, 906, 576, 1); //const61
        writeBlock(tex, br0, 128, 405, 658, 128); //const62
        writeBlock(tex, br0, 64, 911, 576, 1); //const63
        writeBlock(tex, br0, 128, 533, 658, 128); //const64
        writeBlock(tex, br0, 128, 192, 659, 128); //const65
        writeBlock(tex, br0, 8192, 512, 576, 128); //const66
        writeBlock(tex, br0, 64, 704, 661, 64); //const67
        writeBlock(tex, br0, 1728, 128, 640, 64); //const68
        writeBlock(tex, br0, 16384, 548, 0, 64); //const69
        writeBlock(tex, br0, 128, 448, 659, 128); //const70
        writeBlock(tex, br0, 576, 768, 640, 64); //const71
        writeBlock(tex, br0, 64, 512, 661, 64); //const72
        writeBlock(tex, br0, 64, 384, 661, 64); //const73
        writeBlock(tex, br0, 64, 192, 661, 64); //const74
        writeBlock(tex, br0, 32, 990, 576, 1); //const75
        writeBlock(tex, br0, 576, 448, 640, 64); //const76
        writeBlock(tex, br0, 576, 256, 640, 64); //const77
        writeBlock(tex, br0, 288, 800, 649, 32); //const78
        writeBlock(tex, br0, 8, 527, 664, 8); //const79
        writeBlock(tex, br0, 15, 512, 664, 15); //const80
        writeBlock(tex, br0, 64, 832, 660, 64); //const81
        writeBlock(tex, br0, 64, 704, 660, 64); //const82
        writeBlock(tex, br0, 32, 448, 664, 32); //const83
        writeBlock(tex, br0, 8192, 768, 512, 128); //const84
        writeBlock(tex, br0, 576, 704, 640, 64); //const85
        writeBlock(tex, br0, 2048, 800, 576, 32); //const86
        writeBlock(tex, br0, 8192, 548, 256, 64); //const87
        writeBlock(tex, br0, 64, 576, 660, 64); //const88
        writeBlock(tex, br0, 128, 448, 660, 128); //const89
        writeBlock(tex, br0, 64, 914, 576, 1); //const90
        writeBlock(tex, br0, 128, 1015, 0, 1); //const91
        writeBlock(tex, br0, 8192, 128, 512, 128); //const92
        writeBlock(tex, br0, 32, 384, 664, 32); //const93
        writeBlock(tex, br0, 576, 192, 640, 64); //const94
        writeBlock(tex, br0, 64, 256, 661, 64); //const95
        writeBlock(tex, br0, 64, 920, 576, 1); //const96
        writeBlock(tex, br0, 64, 921, 576, 1); //const97
        writeBlock(tex, br0, 128, 192, 660, 128); //const98
        writeBlock(tex, br0, 8192, 640, 576, 128); //const99
        writeBlock(tex, br0, 128, 1000, 0, 1); //const100
        writeBlock(tex, br0, 8192, 256, 512, 128); //const101
        writeBlock(tex, br0, 8192, 640, 512, 128); //const102
        writeBlock(tex, br0, 576, 256, 649, 64); //const103
        writeBlock(tex, br0, 64, 320, 661, 64); //const104
        writeBlock(tex, br0, 64, 909, 576, 1); //const105
        writeBlock(tex, br0, 128, 576, 659, 128); //const106
        writeBlock(tex, br0, 128, 320, 659, 128); //const107
        writeBlock(tex, br0, 64, 768, 661, 64); //const108
        writeBlock(tex, br0, 8192, 256, 576, 128); //const109
        writeBlock(tex, br0, 8192, 676, 128, 64); //const110
        writeBlock(tex, br0, 128, 789, 658, 128); //const111
        writeBlock(tex, br0, 8192, 932, 0, 64); //const112
        writeBlock(tex, br0, 128, 1017, 0, 1); //const113
        writeBlock(tex, br0, 8192, 384, 576, 128); //const114
        writeBlock(tex, br0, 8192, 868, 0, 64); //const115
        writeBlock(tex, br0, 128, 661, 658, 128); //const116
        writeBlock(tex, br0, 64, 832, 661, 64); //const117
        writeBlock(tex, br0, 32768, 469, 0, 64); //const118
        writeBlock(tex, br0, 2048, 832, 576, 32); //const119
        writeBlock(tex, br0, 32, 988, 576, 1); //const120
        writeBlock(tex, br0, 64, 384, 662, 64); //const121
        writeBlock(tex, br0, 128, 896, 654, 128); //const122
        writeBlock(tex, br0, 64, 640, 662, 64); //const123
        writeBlock(tex, br0, 64, 904, 576, 1); //const124
        writeBlock(tex, br0, 64, 915, 576, 1); //const125
        writeBlock(tex, br0, 64, 320, 663, 64); //const126
        writeBlock(tex, br0, 8192, 676, 256, 64); //const127
        writeBlock(tex, br0, 32, 256, 664, 32); //const128
        writeBlock(tex, br0, 576, 576, 649, 64); //const129
        writeBlock(tex, br0, 8192, 804, 448, 128); //const130
        writeBlock(tex, br0, 64, 704, 663, 64); //const131
        writeBlock(tex, br0, 128, 1012, 0, 1); //const132
        writeBlock(tex, br0, 128, 1008, 0, 1); //const133
        writeBlock(tex, br0, 8192, 676, 448, 128); //const134
        writeBlock(tex, br0, 576, 640, 649, 64); //const135
        writeBlock(tex, br0, 8192, 740, 0, 64); //const136
        writeBlock(tex, br0, 64, 256, 663, 64); //const137
        writeBlock(tex, br0, 64, 896, 576, 1); //const138
        writeBlock(tex, br0, 128, 896, 653, 128); //const139
        writeBlock(tex, br0, 128, 1016, 0, 1); //const140
        writeBlock(tex, br0, 64, 512, 662, 64); //const141
        writeBlock(tex, br0, 64, 919, 576, 1); //const142
        writeBlock(tex, br0, 128, 896, 657, 128); //const143
        writeBlock(tex, br0, 64, 896, 661, 64); //const144
        writeBlock(tex, br0, 64, 902, 576, 1); //const145
        writeBlock(tex, br0, 128, 1009, 0, 1); //const146
        writeBlock(tex, br0, 288, 768, 649, 32); //const147
        writeBlock(tex, br0, 8192, 128, 576, 128); //const148
        writeBlock(tex, br0, 8192, 804, 128, 64); //const149
        writeBlock(tex, br0, 32, 480, 664, 32); //const150
        writeBlock(tex, br0, 64, 903, 576, 1); //const151
        writeBlock(tex, br0, 128, 704, 659, 128); //const152
        writeBlock(tex, br0, 128, 1002, 0, 1); //const153
        writeBlock(tex, br0, 32, 989, 576, 1); //const154
        writeBlock(tex, br0, 128, 999, 0, 1); //const155
        writeBlock(tex, br0, 128, 997, 0, 1); //const156
        writeBlock(tex, br0, 64, 960, 658, 64); //const157
        writeBlock(tex, br0, 576, 448, 649, 64); //const158
        writeBlock(tex, br0, 8192, 612, 256, 64); //const159
        writeBlock(tex, br0, 64, 907, 576, 1); //const160
        writeBlock(tex, br0, 8192, 896, 512, 128); //const161
        writeBlock(tex, br0, 64, 768, 660, 64); //const162
        writeBlock(tex, br0, 128, 1001, 0, 1); //const163
        writeBlock(tex, br0, 8192, 868, 128, 64); //const164
        writeBlock(tex, br0, 576, 576, 640, 64); //const165
        writeBlock(tex, br0, 128, 1003, 0, 1); //const166
        writeBlock(tex, br0, 64, 640, 663, 64); //const167
        writeBlock(tex, br0, 128, 832, 659, 128); //const168
        writeBlock(tex, br0, 8192, 612, 128, 64); //const169
        writeBlock(tex, br0, 64, 448, 661, 64); //const170
        writeBlock(tex, br0, 128, 1006, 0, 1); //const171
        writeBlock(tex, br0, 64, 576, 661, 64); //const172
        writeBlock(tex, br0, 576, 896, 640, 64); //const173
        writeBlock(tex, br0, 2048, 64, 640, 64); //const174
        writeBlock(tex, br0, 128, 1010, 0, 1); //const175
        writeBlock(tex, br0, 64, 901, 576, 1); //const176
        writeBlock(tex, br0, 109056, 0, 0, 213); //const177
        writeBlock(tex, br0, 64, 960, 661, 64); //const178
        writeBlock(tex, br0, 8192, 740, 256, 64); //const179
        writeBlock(tex, br0, 64, 256, 662, 64); //const180
        writeBlock(tex, br0, 288, 864, 649, 32); //const181
        writeBlock(tex, br0, 213, 192, 658, 213); //const182
        writeBlock(tex, br0, 64, 448, 662, 64); //const183
        writeBlock(tex, br0, 576, 512, 640, 64); //const184
        writeBlock(tex, br0, 32, 320, 664, 32); //const185
        writeBlock(tex, br0, 8192, 548, 448, 128); //const186
        writeBlock(tex, br0, 64, 704, 662, 64); //const187
        writeBlock(tex, br0, 64, 922, 576, 1); //const188
        writeBlock(tex, br0, 32768, 341, 0, 64); //const189
        writeBlock(tex, br0, 128, 1011, 0, 1); //const190
        writeBlock(tex, br0, 64, 960, 662, 64); //const191
        writeBlock(tex, br0, 64, 899, 576, 1); //const192
        writeBlock(tex, br0, 8192, 612, 0, 64); //const193
        writeBlock(tex, br0, 128, 896, 650, 128); //const194
        writeBlock(tex, br0, 576, 320, 649, 64); //const195
        writeBlock(tex, br0, 64, 910, 576, 1); //const196
        writeBlock(tex, br0, 8192, 804, 256, 128); //const197
        writeBlock(tex, br0, 64, 576, 663, 64); //const198
        writeBlock(tex, br0, 8192, 932, 128, 64); //const199
        writeBlock(tex, br0, 64, 912, 576, 1); //const200
        writeBlock(tex, br0, 128, 996, 0, 1); //const201
        writeBlock(tex, br0, 64, 832, 663, 64); //const202
        writeBlock(tex, br0, 32768, 213, 0, 64); //const203
        writeBlock(tex, br0, 64, 960, 663, 64); //const204
        writeBlock(tex, br0, 576, 320, 640, 64); //const205
        writeBlock(tex, br0, 128, 896, 649, 128); //const206
        writeBlock(tex, br0, 64, 384, 663, 64); //const207
        writeBlock(tex, br0, 128, 1005, 0, 1); //const208
        writeBlock(tex, br0, 64, 900, 576, 1); //const209
        writeBlock(tex, br0, 7680, 533, 0, 15); //const210
        writeBlock(tex, br0, 576, 512, 649, 64); //const211
        writeBlock(tex, br0, 64, 896, 660, 64); //const212
        writeBlock(tex, br0, 64, 640, 660, 64); //const213
        writeBlock(tex, br0, 128, 1014, 0, 1); //const214
        writeBlock(tex, br0, 2048, 923, 576, 64); //const215
        writeBlock(tex, br0, 8192, 676, 0, 64); //const216
        writeBlock(tex, br0, 4, 539, 664, 4); //const217
        writeBlock(tex, br0, 4, 543, 664, 4); //const218
        writeBlock(tex, br0, 4, 547, 664, 4); //const219
        writeBlock(tex, br0, 4, 551, 664, 4); //const220
        writeBlock(tex, br0, 4, 555, 664, 4); //const221
        writeBlock(tex, br0, 4, 559, 664, 4); //const222
        writeBlock(tex, br0, 4, 563, 664, 4); //const223
        writeBlock(tex, br0, 4, 567, 664, 4); //const224
        writeBlock(tex, br0, 4, 571, 664, 4); //const225
        writeBlock(tex, br0, 4, 535, 664, 4); //const226
    }
}

#endif