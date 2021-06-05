#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <stdio.h>

using namespace std;
using namespace cv;

class iris
{
private:
    // weights
    float**** const0, **** const3, **** const6, **** const7, **** const8, **** const9, **** const10,
        **** const12, **** const16, **** const17, **** const18, **** const19, **** const20, **** const21,
        **** const23, **** const25, **** const27, **** const29, **** const30, **** const31, **** const32,
        **** const33, **** const40, **** const41, **** const42, **** const43, **** const45, **** const47,
        **** const48, **** const49, **** const50, **** const52, **** const54, **** const56, **** const57,
        **** const58, **** const59, **** const61, **** const63, **** const66, **** const68, **** const69,
        **** const71, **** const75, **** const76, **** const77, **** const78, **** const84, **** const85,
        **** const86, **** const87, **** const90, **** const91, **** const92, **** const94, **** const96,
        **** const97, **** const99, **** const100, **** const101, **** const102, **** const103, **** const105,
        **** const109, **** const110, **** const112, **** const113, **** const114, **** const115, **** const118,
        **** const119, **** const120, **** const124, **** const125, **** const127, **** const129, **** const130,
        **** const132, **** const133, **** const134, **** const135, **** const136, **** const138, **** const140,
        **** const142, **** const145, **** const146, **** const147, **** const148, **** const149, **** const151,
        **** const153, **** const154, **** const155, **** const156, **** const158, **** const159, **** const160,
        **** const161, **** const163, **** const164, **** const165, **** const166, **** const169, **** const171,
        **** const173, **** const174, **** const175, **** const176, **** const177, **** const179, **** const181,
        **** const184, **** const186, **** const188, **** const189, **** const190, **** const192, **** const193,
        **** const195, **** const196, **** const197, **** const199, **** const200, **** const201, **** const203,
        **** const205, **** const208, **** const209, **** const210, **** const211, **** const214, **** const215,
        **** const216;

    // bias
    float* const1, * const2, * const4, * const5, * const11, * const13, * const14,
        * const15, * const22, * const24, * const26, * const28, * const34, * const35,
        * const36, * const37, * const38, * const39, * const44, * const46, * const51,
        * const53, * const55, * const60, * const62, * const64, * const65, * const67,
        * const70, * const72, * const73, * const74, * const79, * const80, * const81,
        * const82, * const83, * const88, * const89, * const93, * const95, * const98,
        * const104, * const106, * const107, * const108, * const111, * const116, * const117,
        * const121, * const122, * const123, * const126, * const128, * const131, * const137,
        * const139, * const141, * const143, * const144, * const150, * const152, * const157,
        * const162, * const167, * const168, * const170, * const172, * const178, * const180,
        * const182, * const183, * const185, * const187, * const191, * const194, * const198,
        * const202, * const204, * const206, * const207, * const212, * const213, * const217,
        * const218, * const219, * const220, * const221, * const222, * const223, * const224,
        * const225, * const226;

    // input image
    float*** img;

    // layers
    float*** l0, *** l1, *** l2, *** l3, *** l4, *** l5, *** l6, *** l7, *** l8, *** l9,
        *** l10, *** l11, *** l12, *** l13, *** l14, *** l16, *** l17, *** l18, *** l19,
        *** l20, *** l21, *** l22, *** l23, *** l24, *** l25, *** l26, *** l27, *** l28, *** l29,
        *** l30, *** l32, *** l33, *** l34, *** l35, *** l36, *** l37, *** l38, *** l39,
        *** l40, *** l41, *** l42, *** l43, *** l44, *** l45, *** l46, *** l47, *** l48, *** l49,
        *** l50, *** l51, *** l52, *** l53, *** l54, *** l55, *** l56, *** l58, *** l59,
        *** l60, *** l61, *** l62, *** l63, *** l64, *** l65, *** l66, *** l67, *** l68, *** l69,
        *** l70, *** l71, *** l72, *** l73, *** l74, *** l75, *** l76, *** l77, *** l78, *** l79,
        *** l80, *** l81;

    // outputs
    float* l57, * l82;

    float**** getArray(ifstream* fin, int mi, int mj, int mk, int ml)
    {
        float**** buff = (float****)createArray(mi, mj, mk, ml, sizeof(float));
        for (int i = 0; i < mi; i++) {
            for (int j = 0; j < mj; j++) {
                for (int k = 0; k < mk; k++) {
                    fin->read(reinterpret_cast<char*>(buff[i][j][k]), sizeof(float) * ml);
                }
            }
        }
        return buff;
    }

    float*** getArray(ifstream* fin, int mi, int mj, int mk)
    {
        float*** buff = createArray(mi, mj, mk, sizeof(float));
        for (int i = 0; i < mi; i++) {
            for (int j = 0; j < mj; j++) {
                fin->read(reinterpret_cast<char*>(buff[i][j]), sizeof(float) * mk);
            }
        }
        return buff;
    }

    float** getArray(ifstream* fin, int mi, int mj)
    {
        float** buff = (float**)createArray(mi, mj, sizeof(float));
        for (int i = 0; i < mi; i++) {
            fin->read(reinterpret_cast<char*>(buff[i]), sizeof(float) * mj);
        }
        return buff;
    }

    float* getArray(ifstream* fin, int mi)
    {
        float* buff = (float*)malloc(mi * sizeof(float));
        fin->read(reinterpret_cast<char*>(buff), sizeof(float) * mi);
        return buff;
    }

    inline float padLayerEven(float*** layer, uint x, uint y, uint z, uint xm, uint ym)
    {
        if (x == 0 || y == 0 || x > xm || y > ym) return 0.0f;
        return layer[x - 1][y - 1][z];
    }

    inline float padLayerValid(float*** layer, uint x, uint y, uint z, uint xm, uint ym)
    {
        if (x >= xm || y >= ym) return 0.0f;
        return layer[x][y][z];
    }

    // unidirectional broadcasting
    inline float PRelu(float x, float s)
    {
        return x >= 0 ? x : x * s;
    }

public:
    // Annoying mallocs
    static float** createArray(int i, int j, size_t size)
    {
        float** r = new float* [i * sizeof(float*)];
        for (int x = 0; x < i; x++) {
            r[x] = new float [j * size];
        }
        return r;
    }

    static float*** createArray(int i, int j, int k, size_t size)
    {
        float*** r = new float** [i * sizeof(float*)];
        for (int x = 0; x < i; x++) {
            r[x] = new float* [j * sizeof(float*)];
            for (int y = 0; y < j; y++) {
                r[x][y] = new float [k * size];
            }
        }
        return r;
    }

    static float**** createArray(int i, int j, int k, int l, size_t size)
    {
        float**** r = new float*** [i * sizeof(float*)];
        for (int x = 0; x < i; x++) {
            r[x] = new float** [j * sizeof(float*)];
            for (int y = 0; y < j; y++) {
                r[x][y] = new float* [k * sizeof(float*)];
                for (int z = 0; z < k; z++) {
                    r[x][y][z] = new float [l * size];
                }
            }
        }
        return r;
    }

    // Annoying malloc frees
    static void freeArray(int i, float* a)
    {
        delete [] a;
    }

    static void freeArray(int i, int j, float** a)
    {
        for (int x = 0; x < i; x++) {
            delete[] a[x];
        }
        delete[] a;
    }

    static void freeArray(int i, int j, int k, float*** a)
    {
        for (int x = 0; x < i; x++) {
            for (int y = 0; y < j; y++) {
                delete[] a[x][y];
            }
            delete[] a[x];
        }
        delete[] a;
    }

    static void freeArray(int i, int j, int k, int l, float**** a)
    {
        for (int x = 0; x < i; x++) {
            for (int y = 0; y < j; y++) {
                for (int z = 0; z < k; z++) {
                    delete[] a[x][y][z];
                }
                delete[] a[x][y];
            }
            delete[] a[x];
        }
        delete[] a;
    }

    iris(string path)
    {
        ifstream fin(path, ios::binary);
        if (!fin) {
            cout << "error opening stream" << endl;
            exit(-1);
        }

        const0 = getArray(&fin, 32, 1, 3, 3);
        const1 = getArray(&fin, 64);
        const2 = getArray(&fin, 64);
        const3 = getArray(&fin, 1, 64, 1, 1);
        const4 = getArray(&fin, 64);
        const5 = getArray(&fin, 32);
        const6 = getArray(&fin, 64, 32, 1, 1);
        const7 = getArray(&fin, 64, 1, 3, 3);
        const8 = getArray(&fin, 64, 128, 2, 2);
        const9 = getArray(&fin, 64, 1, 3, 3);
        const10 = getArray(&fin, 1, 128, 1, 1);
        const11 = getArray(&fin, 64);
        const12 = getArray(&fin, 1, 64, 1, 1);
        const13 = getArray(&fin, 64);
        const14 = getArray(&fin, 64);
        const15 = getArray(&fin, 64);
        const16 = getArray(&fin, 1, 128, 1, 1);
        const17 = getArray(&fin, 64, 1, 3, 3);
        const18 = getArray(&fin, 64, 1, 3, 3);
        const19 = getArray(&fin, 128, 64, 1, 1);
        const20 = getArray(&fin, 128, 64, 1, 1);
        const21 = getArray(&fin, 1, 128, 1, 1);
        const22 = getArray(&fin, 64);
        const23 = getArray(&fin, 1, 64, 1, 1);
        const24 = getArray(&fin, 64);
        const25 = getArray(&fin, 64, 32, 1, 1);
        const26 = getArray(&fin, 128);
        const27 = getArray(&fin, 32, 64, 1, 1);
        const28 = getArray(&fin, 128);
        const29 = getArray(&fin, 1, 64, 1, 1);
        const30 = getArray(&fin, 128, 64, 1, 1);
        const31 = getArray(&fin, 1, 64, 1, 1);
        const32 = getArray(&fin, 64, 128, 1, 1);
        const33 = getArray(&fin, 64, 1, 3, 3);
        const34 = getArray(&fin, 64);
        const35 = getArray(&fin, 2);
        const36 = getArray(&fin, 32);
        const37 = getArray(&fin, 128);
        const38 = getArray(&fin, 64);
        const39 = getArray(&fin, 64);
        const40 = getArray(&fin, 64, 128, 2, 2);
        const41 = getArray(&fin, 1, 128, 1, 1);
        const42 = getArray(&fin, 64, 1, 3, 3);
        const43 = getArray(&fin, 1, 64, 1, 1);
        const44 = getArray(&fin, 64);
        const45 = getArray(&fin, 1, 64, 1, 1);
        const46 = getArray(&fin, 64);
        const47 = getArray(&fin, 128, 64, 1, 1);
        const48 = getArray(&fin, 32, 64, 1, 1);
        const49 = getArray(&fin, 128, 64, 1, 1);
        const50 = getArray(&fin, 1, 64, 1, 1);
        const51 = getArray(&fin, 128);
        const52 = getArray(&fin, 64, 1, 3, 3);
        const53 = getArray(&fin, 128);
        const54 = getArray(&fin, 128, 64, 1, 1);
        const55 = getArray(&fin, 32);
        const56 = getArray(&fin, 1, 32, 1, 1);
        const57 = getArray(&fin, 128, 64, 1, 1);
        const58 = getArray(&fin, 128, 64, 1, 1);
        const59 = getArray(&fin, 64, 128, 1, 1);
        const60 = getArray(&fin, 64);
        const61 = getArray(&fin, 1, 64, 1, 1);
        const62 = getArray(&fin, 128);
        const63 = getArray(&fin, 1, 64, 1, 1);
        const64 = getArray(&fin, 128);
        const65 = getArray(&fin, 128);
        const66 = getArray(&fin, 128, 64, 1, 1);
        const67 = getArray(&fin, 64);
        const68 = getArray(&fin, 64, 3, 3, 3);
        const69 = getArray(&fin, 64, 64, 2, 2);
        const70 = getArray(&fin, 128);
        const71 = getArray(&fin, 64, 1, 3, 3);
        const72 = getArray(&fin, 64);
        const73 = getArray(&fin, 64);
        const74 = getArray(&fin, 64);
        const75 = getArray(&fin, 1, 32, 1, 1);
        const76 = getArray(&fin, 64, 1, 3, 3);
        const77 = getArray(&fin, 64, 1, 3, 3);
        const78 = getArray(&fin, 32, 1, 3, 3);
        const79 = getArray(&fin, 8);
        const80 = getArray(&fin, 15);
        const81 = getArray(&fin, 64);
        const82 = getArray(&fin, 64);
        const83 = getArray(&fin, 32);
        const84 = getArray(&fin, 128, 64, 1, 1);
        const85 = getArray(&fin, 64, 1, 3, 3);
        const86 = getArray(&fin, 32, 64, 1, 1);
        const87 = getArray(&fin, 64, 128, 1, 1);
        const88 = getArray(&fin, 64);
        const89 = getArray(&fin, 128);
        const90 = getArray(&fin, 1, 64, 1, 1);
        const91 = getArray(&fin, 1, 128, 1, 1);
        const92 = getArray(&fin, 128, 64, 1, 1);
        const93 = getArray(&fin, 32);
        const94 = getArray(&fin, 64, 1, 3, 3);
        const95 = getArray(&fin, 64);
        const96 = getArray(&fin, 1, 64, 1, 1);
        const97 = getArray(&fin, 1, 64, 1, 1);
        const98 = getArray(&fin, 128);
        const99 = getArray(&fin, 128, 64, 1, 1);
        const100 = getArray(&fin, 1, 128, 1, 1);
        const101 = getArray(&fin, 128, 64, 1, 1);
        const102 = getArray(&fin, 128, 64, 1, 1);
        const103 = getArray(&fin, 64, 1, 3, 3);
        const104 = getArray(&fin, 64);
        const105 = getArray(&fin, 1, 64, 1, 1);
        const106 = getArray(&fin, 128);
        const107 = getArray(&fin, 128);
        const108 = getArray(&fin, 64);
        const109 = getArray(&fin, 128, 64, 1, 1);
        const110 = getArray(&fin, 64, 128, 1, 1);
        const111 = getArray(&fin, 128);
        const112 = getArray(&fin, 64, 128, 1, 1);
        const113 = getArray(&fin, 1, 128, 1, 1);
        const114 = getArray(&fin, 128, 64, 1, 1);
        const115 = getArray(&fin, 64, 128, 1, 1);
        const116 = getArray(&fin, 128);
        const117 = getArray(&fin, 64);
        const118 = getArray(&fin, 64, 128, 2, 2);
        const119 = getArray(&fin, 32, 64, 1, 1);
        const120 = getArray(&fin, 1, 32, 1, 1);
        const121 = getArray(&fin, 64);
        const122 = getArray(&fin, 128);
        const123 = getArray(&fin, 64);
        const124 = getArray(&fin, 1, 64, 1, 1);
        const125 = getArray(&fin, 1, 64, 1, 1);
        const126 = getArray(&fin, 64);
        const127 = getArray(&fin, 64, 128, 1, 1);
        const128 = getArray(&fin, 32);
        const129 = getArray(&fin, 64, 1, 3, 3);
        const130 = getArray(&fin, 128, 64, 1, 1);
        const131 = getArray(&fin, 64);
        const132 = getArray(&fin, 1, 128, 1, 1);
        const133 = getArray(&fin, 1, 128, 1, 1);
        const134 = getArray(&fin, 128, 64, 1, 1);
        const135 = getArray(&fin, 64, 1, 3, 3);
        const136 = getArray(&fin, 64, 128, 1, 1);
        const137 = getArray(&fin, 64);
        const138 = getArray(&fin, 1, 64, 1, 1);
        const139 = getArray(&fin, 128);
        const140 = getArray(&fin, 1, 128, 1, 1);
        const141 = getArray(&fin, 64);
        const142 = getArray(&fin, 1, 64, 1, 1);
        const143 = getArray(&fin, 128);
        const144 = getArray(&fin, 64);
        const145 = getArray(&fin, 1, 64, 1, 1);
        const146 = getArray(&fin, 1, 128, 1, 1);
        const147 = getArray(&fin, 32, 1, 3, 3);
        const148 = getArray(&fin, 128, 64, 1, 1);
        const149 = getArray(&fin, 64, 128, 1, 1);
        const150 = getArray(&fin, 32);
        const151 = getArray(&fin, 1, 64, 1, 1);
        const152 = getArray(&fin, 128);
        const153 = getArray(&fin, 1, 128, 1, 1);
        const154 = getArray(&fin, 1, 32, 1, 1);
        const155 = getArray(&fin, 1, 128, 1, 1);
        const156 = getArray(&fin, 1, 128, 1, 1);
        const157 = getArray(&fin, 64);
        const158 = getArray(&fin, 64, 1, 3, 3);
        const159 = getArray(&fin, 64, 128, 1, 1);
        const160 = getArray(&fin, 1, 64, 1, 1);
        const161 = getArray(&fin, 128, 64, 1, 1);
        const162 = getArray(&fin, 64);
        const163 = getArray(&fin, 1, 128, 1, 1);
        const164 = getArray(&fin, 64, 128, 1, 1);
        const165 = getArray(&fin, 64, 1, 3, 3);
        const166 = getArray(&fin, 1, 128, 1, 1);
        const167 = getArray(&fin, 64);
        const168 = getArray(&fin, 128);
        const169 = getArray(&fin, 64, 128, 1, 1);
        const170 = getArray(&fin, 64);
        const171 = getArray(&fin, 1, 128, 1, 1);
        const172 = getArray(&fin, 64);
        const173 = getArray(&fin, 64, 1, 3, 3);
        const174 = getArray(&fin, 64, 32, 1, 1);
        const175 = getArray(&fin, 1, 128, 1, 1);
        const176 = getArray(&fin, 1, 64, 1, 1);
        const177 = getArray(&fin, 213, 128, 2, 2);
        const178 = getArray(&fin, 64);
        const179 = getArray(&fin, 64, 128, 1, 1);
        const180 = getArray(&fin, 64);
        const181 = getArray(&fin, 32, 1, 3, 3);
        const182 = getArray(&fin, 213);
        const183 = getArray(&fin, 64);
        const184 = getArray(&fin, 64, 1, 3, 3);
        const185 = getArray(&fin, 32);
        const186 = getArray(&fin, 128, 64, 1, 1);
        const187 = getArray(&fin, 64);
        const188 = getArray(&fin, 1, 64, 1, 1);
        const189 = getArray(&fin, 64, 128, 2, 2);
        const190 = getArray(&fin, 1, 128, 1, 1);
        const191 = getArray(&fin, 64);
        const192 = getArray(&fin, 1, 64, 1, 1);
        const193 = getArray(&fin, 64, 128, 1, 1);
        const194 = getArray(&fin, 128);
        const195 = getArray(&fin, 64, 1, 3, 3);
        const196 = getArray(&fin, 1, 64, 1, 1);
        const197 = getArray(&fin, 128, 64, 1, 1);
        const198 = getArray(&fin, 64);
        const199 = getArray(&fin, 64, 128, 1, 1);
        const200 = getArray(&fin, 1, 64, 1, 1);
        const201 = getArray(&fin, 1, 128, 1, 1);
        const202 = getArray(&fin, 64);
        const203 = getArray(&fin, 64, 128, 2, 2);
        const204 = getArray(&fin, 64);
        const205 = getArray(&fin, 64, 1, 3, 3);
        const206 = getArray(&fin, 128);
        const207 = getArray(&fin, 64);
        const208 = getArray(&fin, 1, 128, 1, 1);
        const209 = getArray(&fin, 1, 64, 1, 1);
        const210 = getArray(&fin, 15, 128, 2, 2);
        const211 = getArray(&fin, 64, 1, 3, 3);
        const212 = getArray(&fin, 64);
        const213 = getArray(&fin, 64);
        const214 = getArray(&fin, 1, 128, 1, 1);
        const215 = getArray(&fin, 64, 32, 1, 1);
        const216 = getArray(&fin, 64, 128, 1, 1);
        const217 = getArray(&fin, 4);
        const218 = getArray(&fin, 4);
        const219 = getArray(&fin, 4);
        const220 = getArray(&fin, 4);
        const221 = getArray(&fin, 4);
        const222 = getArray(&fin, 4);
        const223 = getArray(&fin, 4);
        const224 = getArray(&fin, 4);
        const225 = getArray(&fin, 4);
        const226 = getArray(&fin, 4);

        fin.close();

        l0 = createArray(32, 32, 64, sizeof(float));
        l1 = createArray(32, 32, 32, sizeof(float));
        l2 = createArray(32, 32, 32, sizeof(float));
        l3 = createArray(32, 32, 64, sizeof(float));
        l4 = createArray(32, 32, 32, sizeof(float));
        l5 = createArray(32, 32, 32, sizeof(float));
        l6 = createArray(32, 32, 64, sizeof(float));
        l7 = createArray(32, 32, 32, sizeof(float));
        l8 = createArray(32, 32, 32, sizeof(float));
        l9 = createArray(32, 32, 64, sizeof(float));
        l10 = createArray(32, 32, 32, sizeof(float));
        l11 = createArray(32, 32, 32, sizeof(float));
        l12 = createArray(32, 32, 64, sizeof(float));
        l13 = createArray(16, 16, 64, sizeof(float));
        l14 = createArray(16, 16, 64, sizeof(float));
        //l15 = createArray(16, 16, 64, sizeof(float));
        l16 = createArray(16, 16, 128, sizeof(float));
        l17 = createArray(16, 16, 64, sizeof(float));
        l18 = createArray(16, 16, 64, sizeof(float));
        l19 = createArray(16, 16, 128, sizeof(float));
        l20 = createArray(16, 16, 64, sizeof(float));
        l21 = createArray(16, 16, 64, sizeof(float));
        l22 = createArray(16, 16, 128, sizeof(float));
        l23 = createArray(16, 16, 64, sizeof(float));
        l24 = createArray(16, 16, 64, sizeof(float));
        l25 = createArray(16, 16, 128, sizeof(float));
        l26 = createArray(16, 16, 64, sizeof(float));
        l27 = createArray(16, 16, 64, sizeof(float));
        l28 = createArray(16, 16, 128, sizeof(float));
        l29 = createArray(8, 8, 64, sizeof(float));
        l30 = createArray(8, 8, 64, sizeof(float));
        //l31 = createArray(8, 8, 128, sizeof(float));
        l32 = createArray(8, 8, 128, sizeof(float));
        l33 = createArray(8, 8, 64, sizeof(float));
        l34 = createArray(8, 8, 64, sizeof(float));
        l35 = createArray(8, 8, 128, sizeof(float));
        l36 = createArray(8, 8, 64, sizeof(float));
        l37 = createArray(8, 8, 64, sizeof(float));
        l38 = createArray(8, 8, 128, sizeof(float));
        l39 = createArray(4, 4, 64, sizeof(float));
        l40 = createArray(4, 4, 64, sizeof(float));
        l41 = createArray(4, 4, 128, sizeof(float));
        l42 = createArray(4, 4, 64, sizeof(float));
        l43 = createArray(4, 4, 64, sizeof(float));
        l44 = createArray(4, 4, 128, sizeof(float));
        l45 = createArray(4, 4, 64, sizeof(float));
        l46 = createArray(4, 4, 64, sizeof(float));
        l47 = createArray(4, 4, 128, sizeof(float));
        l48 = createArray(2, 2, 64, sizeof(float));
        l49 = createArray(2, 2, 64, sizeof(float));
        l50 = createArray(2, 2, 128, sizeof(float));
        l51 = createArray(2, 2, 64, sizeof(float));
        l52 = createArray(2, 2, 64, sizeof(float));
        l53 = createArray(2, 2, 128, sizeof(float));
        l54 = createArray(2, 2, 64, sizeof(float));
        l55 = createArray(2, 2, 64, sizeof(float));
        l56 = createArray(2, 2, 128, sizeof(float));
        l57 = new float[213];
        l58 = createArray(8, 8, 64, sizeof(float));
        l59 = createArray(8, 8, 64, sizeof(float));
        l60 = createArray(8, 8, 128, sizeof(float));
        l61 = createArray(8, 8, 64, sizeof(float));
        l62 = createArray(8, 8, 64, sizeof(float));
        l63 = createArray(8, 8, 128, sizeof(float));
        l64 = createArray(4, 4, 64, sizeof(float));
        l65 = createArray(4, 4, 64, sizeof(float));
        l66 = createArray(4, 4, 128, sizeof(float));
        l67 = createArray(4, 4, 64, sizeof(float));
        l68 = createArray(4, 4, 64, sizeof(float));
        l69 = createArray(4, 4, 128, sizeof(float));
        l70 = createArray(4, 4, 64, sizeof(float));
        l71 = createArray(4, 4, 64, sizeof(float));
        l72 = createArray(4, 4, 128, sizeof(float));
        l73 = createArray(2, 2, 64, sizeof(float));
        l74 = createArray(2, 2, 64, sizeof(float));
        l75 = createArray(2, 2, 128, sizeof(float));
        l76 = createArray(2, 2, 64, sizeof(float));
        l77 = createArray(2, 2, 64, sizeof(float));
        l78 = createArray(2, 2, 128, sizeof(float));
        l79 = createArray(2, 2, 64, sizeof(float));
        l80 = createArray(2, 2, 64, sizeof(float));
        l81 = createArray(2, 2, 128, sizeof(float));
        l82 = new float[15];
    }

    ~iris()
    {
        freeArray(32, 1, 3, 3, const0);
        freeArray(64, const1);
        freeArray(64, const2);
        freeArray(1, 64, 1, 1, const3);
        freeArray(64, const4);
        freeArray(32, const5);
        freeArray(64, 32, 1, 1, const6);
        freeArray(64, 1, 3, 3, const7);
        freeArray(64, 128, 2, 2, const8);
        freeArray(64, 1, 3, 3, const9);
        freeArray(1, 128, 1, 1, const10);
        freeArray(64, const11);
        freeArray(1, 64, 1, 1, const12);
        freeArray(64, const13);
        freeArray(64, const14);
        freeArray(64, const15);
        freeArray(1, 128, 1, 1, const16);
        freeArray(64, 1, 3, 3, const17);
        freeArray(64, 1, 3, 3, const18);
        freeArray(128, 64, 1, 1, const19);
        freeArray(128, 64, 1, 1, const20);
        freeArray(1, 128, 1, 1, const21);
        freeArray(64, const22);
        freeArray(1, 64, 1, 1, const23);
        freeArray(64, const24);
        freeArray(64, 32, 1, 1, const25);
        freeArray(128, const26);
        freeArray(32, 64, 1, 1, const27);
        freeArray(128, const28);
        freeArray(1, 64, 1, 1, const29);
        freeArray(128, 64, 1, 1, const30);
        freeArray(1, 64, 1, 1, const31);
        freeArray(64, 128, 1, 1, const32);
        freeArray(64, 1, 3, 3, const33);
        freeArray(64, const34);
        freeArray(2, const35);
        freeArray(32, const36);
        freeArray(128, const37);
        freeArray(64, const38);
        freeArray(64, const39);
        freeArray(64, 128, 2, 2, const40);
        freeArray(1, 128, 1, 1, const41);
        freeArray(64, 1, 3, 3, const42);
        freeArray(1, 64, 1, 1, const43);
        freeArray(64, const44);
        freeArray(1, 64, 1, 1, const45);
        freeArray(64, const46);
        freeArray(128, 64, 1, 1, const47);
        freeArray(32, 64, 1, 1, const48);
        freeArray(128, 64, 1, 1, const49);
        freeArray(1, 64, 1, 1, const50);
        freeArray(128, const51);
        freeArray(64, 1, 3, 3, const52);
        freeArray(128, const53);
        freeArray(128, 64, 1, 1, const54);
        freeArray(32, const55);
        freeArray(1, 32, 1, 1, const56);
        freeArray(128, 64, 1, 1, const57);
        freeArray(128, 64, 1, 1, const58);
        freeArray(64, 128, 1, 1, const59);
        freeArray(64, const60);
        freeArray(1, 64, 1, 1, const61);
        freeArray(128, const62);
        freeArray(1, 64, 1, 1, const63);
        freeArray(128, const64);
        freeArray(128, const65);
        freeArray(128, 64, 1, 1, const66);
        freeArray(64, const67);
        freeArray(64, 3, 3, 3, const68);
        freeArray(64, 64, 2, 2, const69);
        freeArray(128, const70);
        freeArray(64, 1, 3, 3, const71);
        freeArray(64, const72);
        freeArray(64, const73);
        freeArray(64, const74);
        freeArray(1, 32, 1, 1, const75);
        freeArray(64, 1, 3, 3, const76);
        freeArray(64, 1, 3, 3, const77);
        freeArray(32, 1, 3, 3, const78);
        freeArray(8, const79);
        freeArray(15, const80);
        freeArray(64, const81);
        freeArray(64, const82);
        freeArray(32, const83);
        freeArray(128, 64, 1, 1, const84);
        freeArray(64, 1, 3, 3, const85);
        freeArray(32, 64, 1, 1, const86);
        freeArray(64, 128, 1, 1, const87);
        freeArray(64, const88);
        freeArray(128, const89);
        freeArray(1, 64, 1, 1, const90);
        freeArray(1, 128, 1, 1, const91);
        freeArray(128, 64, 1, 1, const92);
        freeArray(32, const93);
        freeArray(64, 1, 3, 3, const94);
        freeArray(64, const95);
        freeArray(1, 64, 1, 1, const96);
        freeArray(1, 64, 1, 1, const97);
        freeArray(128, const98);
        freeArray(128, 64, 1, 1, const99);
        freeArray(1, 128, 1, 1, const100);
        freeArray(128, 64, 1, 1, const101);
        freeArray(128, 64, 1, 1, const102);
        freeArray(64, 1, 3, 3, const103);
        freeArray(64, const104);
        freeArray(1, 64, 1, 1, const105);
        freeArray(128, const106);
        freeArray(128, const107);
        freeArray(64, const108);
        freeArray(128, 64, 1, 1, const109);
        freeArray(64, 128, 1, 1, const110);
        freeArray(128, const111);
        freeArray(64, 128, 1, 1, const112);
        freeArray(1, 128, 1, 1, const113);
        freeArray(128, 64, 1, 1, const114);
        freeArray(64, 128, 1, 1, const115);
        freeArray(128, const116);
        freeArray(64, const117);
        freeArray(64, 128, 2, 2, const118);
        freeArray(32, 64, 1, 1, const119);
        freeArray(1, 32, 1, 1, const120);
        freeArray(64, const121);
        freeArray(128, const122);
        freeArray(64, const123);
        freeArray(1, 64, 1, 1, const124);
        freeArray(1, 64, 1, 1, const125);
        freeArray(64, const126);
        freeArray(64, 128, 1, 1, const127);
        freeArray(32, const128);
        freeArray(64, 1, 3, 3, const129);
        freeArray(128, 64, 1, 1, const130);
        freeArray(64, const131);
        freeArray(1, 128, 1, 1, const132);
        freeArray(1, 128, 1, 1, const133);
        freeArray(128, 64, 1, 1, const134);
        freeArray(64, 1, 3, 3, const135);
        freeArray(64, 128, 1, 1, const136);
        freeArray(64, const137);
        freeArray(1, 64, 1, 1, const138);
        freeArray(128, const139);
        freeArray(1, 128, 1, 1, const140);
        freeArray(64, const141);
        freeArray(1, 64, 1, 1, const142);
        freeArray(128, const143);
        freeArray(64, const144);
        freeArray(1, 64, 1, 1, const145);
        freeArray(1, 128, 1, 1, const146);
        freeArray(32, 1, 3, 3, const147);
        freeArray(128, 64, 1, 1, const148);
        freeArray(64, 128, 1, 1, const149);
        freeArray(32, const150);
        freeArray(1, 64, 1, 1, const151);
        freeArray(128, const152);
        freeArray(1, 128, 1, 1, const153);
        freeArray(1, 32, 1, 1, const154);
        freeArray(1, 128, 1, 1, const155);
        freeArray(1, 128, 1, 1, const156);
        freeArray(64, const157);
        freeArray(64, 1, 3, 3, const158);
        freeArray(64, 128, 1, 1, const159);
        freeArray(1, 64, 1, 1, const160);
        freeArray(128, 64, 1, 1, const161);
        freeArray(64, const162);
        freeArray(1, 128, 1, 1, const163);
        freeArray(64, 128, 1, 1, const164);
        freeArray(64, 1, 3, 3, const165);
        freeArray(1, 128, 1, 1, const166);
        freeArray(64, const167);
        freeArray(128, const168);
        freeArray(64, 128, 1, 1, const169);
        freeArray(64, const170);
        freeArray(1, 128, 1, 1, const171);
        freeArray(64, const172);
        freeArray(64, 1, 3, 3, const173);
        freeArray(64, 32, 1, 1, const174);
        freeArray(1, 128, 1, 1, const175);
        freeArray(1, 64, 1, 1, const176);
        freeArray(213, 128, 2, 2, const177);
        freeArray(64, const178);
        freeArray(64, 128, 1, 1, const179);
        freeArray(64, const180);
        freeArray(32, 1, 3, 3, const181);
        freeArray(213, const182);
        freeArray(64, const183);
        freeArray(64, 1, 3, 3, const184);
        freeArray(32, const185);
        freeArray(128, 64, 1, 1, const186);
        freeArray(64, const187);
        freeArray(1, 64, 1, 1, const188);
        freeArray(64, 128, 2, 2, const189);
        freeArray(1, 128, 1, 1, const190);
        freeArray(64, const191);
        freeArray(1, 64, 1, 1, const192);
        freeArray(64, 128, 1, 1, const193);
        freeArray(128, const194);
        freeArray(64, 1, 3, 3, const195);
        freeArray(1, 64, 1, 1, const196);
        freeArray(128, 64, 1, 1, const197);
        freeArray(64, const198);
        freeArray(64, 128, 1, 1, const199);
        freeArray(1, 64, 1, 1, const200);
        freeArray(1, 128, 1, 1, const201);
        freeArray(64, const202);
        freeArray(64, 128, 2, 2, const203);
        freeArray(64, const204);
        freeArray(64, 1, 3, 3, const205);
        freeArray(128, const206);
        freeArray(64, const207);
        freeArray(1, 128, 1, 1, const208);
        freeArray(1, 64, 1, 1, const209);
        freeArray(15, 128, 2, 2, const210);
        freeArray(64, 1, 3, 3, const211);
        freeArray(64, const212);
        freeArray(64, const213);
        freeArray(1, 128, 1, 1, const214);
        freeArray(64, 32, 1, 1, const215);
        freeArray(64, 128, 1, 1, const216);
        freeArray(4, const217);
        freeArray(4, const218);
        freeArray(4, const219);
        freeArray(4, const220);
        freeArray(4, const221);
        freeArray(4, const222);
        freeArray(4, const223);
        freeArray(4, const224);
        freeArray(4, const225);
        freeArray(4, const226);
    }

    // Using seperate methods for each layer easier to debug
    void conv2D3x3Stride2(float*** cl, float**** cw, float* bias, float**** slope, float*** pl,
        uint im, uint jm, uint k, uint lm)
    {
        // Max index to pad
        uint h_im = im * 2;
        uint h_jm = jm * 2;

        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;
                // kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] +=
                        padLayerValid(pl, i0, j0, l, h_im, h_jm) * cw[k][l][0][0] +
                        padLayerValid(pl, i0, j1, l, h_im, h_jm) * cw[k][l][0][1] +
                        padLayerValid(pl, i0, j2, l, h_im, h_jm) * cw[k][l][0][2] +
                        padLayerValid(pl, i1, j0, l, h_im, h_jm) * cw[k][l][1][0] +
                        padLayerValid(pl, i1, j1, l, h_im, h_jm) * cw[k][l][1][1] +
                        padLayerValid(pl, i1, j2, l, h_im, h_jm) * cw[k][l][1][2] +
                        padLayerValid(pl, i2, j0, l, h_im, h_jm) * cw[k][l][2][0] +
                        padLayerValid(pl, i2, j1, l, h_im, h_jm) * cw[k][l][2][1] +
                        padLayerValid(pl, i2, j2, l, h_im, h_jm) * cw[k][l][2][2];
                }
                // bias
                cl[i][j][k] = cl[i][j][k] + bias[k];

                // activation
                cl[i][j][k] = PRelu(cl[i][j][k], slope[0][k][0][0]);
            }
        }
    }

    void conv2D1x1Stride1(float*** cl, float**** cw, float* bias, float**** slope, float*** pl,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;

                // kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[k][l][0][0];
                }
                // bias
                cl[i][j][k] = cl[i][j][k] + bias[k];

                // activation
                cl[i][j][k] = PRelu(cl[i][j][k], slope[0][k][0][0]);
            }
        }
    }

    void depthConv2D3x3(float*** cl, float**** cw, float* bias, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[k][0][0][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[k][0][0][1] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[k][0][0][2] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[k][0][1][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[k][0][1][1] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[k][0][1][2] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[k][0][2][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[k][0][2][1] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[k][0][2][2];

                // bias
                cl[i][j][k] = cl[i][j][k] + bias[k];
            }
        }
    }

    void conv2D1x1Stride1Add(float*** cl, float**** cw, float* bias, float**** slope, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;

                // kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[k][l][0][0];
                }
                // bias + skip in
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];
                // activation
                cl[i][j][k] = PRelu(cl[i][j][k], slope[0][k][0][0]);
            }
        }
    }

    void conv2D2x2Stride2(float*** cl, float**** cw, float* bias, float**** slope, float*** pl,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                uint i0 = i * 2, i1 = i0 + 1;
                uint j0 = j * 2, j1 = j0 + 1;
                // 2x2 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] +=
                        pl[i0][j0][l] * cw[k][l][0][0] +
                        pl[i0][j1][l] * cw[k][l][0][1] +
                        pl[i1][j0][l] * cw[k][l][1][0] +
                        pl[i1][j1][l] * cw[k][l][1][1];
                }
                // bias
                cl[i][j][k] = cl[i][j][k] + bias[k];

                // activation
                cl[i][j][k] = PRelu(cl[i][j][k], slope[0][k][0][0]);
            }
        }
    }

    void conv2D2x2Stride1(float* cl, float**** cw, float* bias, float*** pl,
       uint k, uint lm)
    {
        cl[k] = 0.0f;
        for (uint l = 0; l < lm; l++) {
            cl[k] +=
                pl[0][0][l] * cw[k][l][0][0] +
                pl[0][1][l] * cw[k][l][0][1] +
                pl[1][0][l] * cw[k][l][1][0] +
                pl[1][1][l] * cw[k][l][1][1];
        }
        // bias
        cl[k] = cl[k] + bias[k];
    }

    void maxPool2x2Stride2Padded(float*** cl, float**** cw, float* bias, float**** slope, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                uint i0 = i * 2, i1 = i0 + 1;
                uint j0 = j * 2, j1 = j0 + 1;

                // kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[k][l][0][0];
                }

                // max pool
                float mp = 0.0f;
                if (k < lm)
                {
                    mp = fmaxf(pl2[i0][j0][k], fmaxf(pl2[i0][j1][k],
                        fmaxf(pl2[i1][j0][k], pl2[i1][j1][k])));
                }

                // bias + skip in
                cl[i][j][k] = cl[i][j][k] + bias[k] + mp;
                // activation
                cl[i][j][k] = PRelu(cl[i][j][k], slope[0][k][0][0]);
            }
        }
    }

    void maxPool2x2Stride2NoPad(float*** cl, float**** cw, float* bias, float**** slope, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                uint i0 = i * 2, i1 = i0 + 1;
                uint j0 = j * 2, j1 = j0 + 1;

                // kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[k][l][0][0];
                }

                // max pool
                float mp = fmaxf(pl2[i0][j0][k], fmaxf(pl2[i0][j1][k],
                    fmaxf(pl2[i1][j0][k], pl2[i1][j1][k])));

                // bias + skip in
                cl[i][j][k] = cl[i][j][k] + bias[k] + mp;
                // activation
                cl[i][j][k] = PRelu(cl[i][j][k], slope[0][k][0][0]);
            }
        }
    }

    void forwardProp(float*** imgIn)
    {
        img = imgIn;

        vector<thread> threads;

        // L0, kernel=3x3, stride=2, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D3x3Stride2, this, l0, const68, const72, const90, img, 32, 32, k, 3);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu

        // L1, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l1, const119, const128, const154, l0, 32, 32, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_1

        // L2, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::depthConv2D3x3, this, l2, const181, const185, l1, 32, 32, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: depthwise_conv2d

        // L3, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l3, const215, const4, const23, l2, l0, 32, 32, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_2

        // L4, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l4, const48, const55, const75, l3, 32, 32, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_3

        // L5, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::depthConv2D3x3, this, l5, const0, const5, l4, 32, 32, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: depthwise_conv2d_1

        // L6, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l6, const25, const34, const63, l5, l3, 32, 32, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_4

        // L7, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l7, const86, const93, const120, l6, 32, 32, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_5

        // L8, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::depthConv2D3x3, this, l8, const147, const150, l7, 32, 32, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: depthwise_conv2d_2

        // L9, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l9, const174, const183, const3, l8, l6, 32, 32, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_6

        // L10, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l10, const27, const36, const56, l9, 32, 32, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_7

        // L11, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::depthConv2D3x3, this, l11, const78, const83, l10, 32, 32, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: depthwise_conv2d_3

        // L12, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l12, const6, const13, const43, l11, l9, 32, 32, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_8

        // L13, kernel=2x2, stride=2, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D2x2Stride2, this, l13, const69, const73, const96, l12, 16, 16, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_9

        // L14, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l14, const18, const24, l13, 16, 16, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: depthwise_conv2d_4

        // L16, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::maxPool2x2Stride2Padded, this, l16, const57, const64, const10, l14, l12, 16, 16, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_10

        // L17, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l17, const32, const38, const50, l16, 16, 16, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_11

        // L18, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l18, const76, const81, l17, 16, 16, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L19, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l19, const99, const106, const140, l18, l16, 16, 16, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_12

        // L20, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l20, const164, const170, const192, l19, 16, 16, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_13

        // L21, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l21, const103, const108, l20, 16, 16, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L22, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l22, const130, const139, const171, l21, l19, 16, 16, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_14

        // L23, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l23, const199, const207, const105, l22, 16, 16, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_15

        // L24, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l24, const135, const141, l23, 16, 16, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L25, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l25, const161, const168, const208, l24, l22, 16, 16, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L26, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l26, const112, const121, const138, l25, 16, 16, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_17

        // L27, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l27, const165, const172, l26, 16, 16, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L28, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l28, const197, const206, const16, l27, l25, 16, 16, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L29, kernel=2x2, stride=2, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D2x2Stride2, this, l29, const40, const44, const61, l28, 8, 8, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_19

        // L30, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l30, const85, const88, l29, 8, 8, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L32, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::maxPool2x2Stride2NoPad, this, l32, const109, const116, const166, l30, l28, 8, 8, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // Network splits up into two sections: [1] Contours/brows and [2] iris tracking

        // [1] Contours/brows
        // L33, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l33, const193, const202, const125, l32, 8, 8, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_21

        // L34, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l34, const184, const191, l33, 8, 8, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L35, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l35, const20, const28, const91, l34, l32, 8, 8, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L36, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l36, const136, const144, const200, l35, 8, 8, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_23

        // L37, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l37, const129, const137, l36, 8, 8, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L38, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l38, const186, const194, const155, l37, l35, 8, 8, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L39, kernel=2x2, stride=2, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D2x2Stride2, this, l39, const203, const212, const145, l38, 4, 4, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_25

        // L40, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l40, const195, const204, l39, 4, 4, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L41, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::maxPool2x2Stride2NoPad, this, l41, const30, const37, const133, l40, l38, 4, 4, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L42, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l42, const179, const187, const124, l41, 4, 4, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_27

        // L43, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l43, const173, const180, l42, 4, 4, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L44, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l44, const114, const122, const201, l43, l41, 4, 4, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L45, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l45, const127, const131, const188, l44, 4, 4, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_29

        // L46, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l46, const17, const22, l45, 4, 4, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L47, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l47, const66, const70, const146, l46, l44, 4, 4, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L48, kernel=2x2, stride=2, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D2x2Stride2, this, l48, const189, const198, const31, l47, 2, 2, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_31

        // L49, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l49, const71, const74, l48, 2, 2, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L50, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::maxPool2x2Stride2NoPad, this, l50, const19, const26, const21, l49, l47, 2, 2, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L51, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l51, const59, const67, const12, l50, 2, 2, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_33

        // L52, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l52, const52, const60, l51, 2, 2, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L53, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l53, const101, const107, const190, l52, l50, 2, 2, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L54, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l54, const115, const123, const176, l53, 2, 2, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_35

        // L55, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l55, const9, const15, l54, 2, 2, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L56, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l56, const54, const62, const132, l55, l53, 2, 2, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L57, kernel=2x2, stride=1, padding=none
        for (uint k = 0; k < 213; k++) {
            thread t(&iris::conv2D2x2Stride1, this, l57, const177, const182, l56, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: conv_eyes_contours_and_brows

        // [2] Iris
        // L58, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l58, const110, const117, const151, l32, 8, 8, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_37

        // L59, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l59, const211, const2, l58, 8, 8, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L60, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l60, const49, const53, const113, l59, l32, 8, 8, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_38

        // L61, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l61, const169, const178, const97, l60, 8, 8, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_39

        // L62, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l62, const158, const162, l61, 8, 8, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L63, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l63, const102, const111, const175, l62, l60, 8, 8, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L64, kernel=2x2, stride=2, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D2x2Stride2, this, l64, const118, const126, const160, l63, 4, 4, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_41

        // L65, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l65, const7, const11, l64, 4, 4, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L66, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::maxPool2x2Stride2NoPad, this, l66, const58, const65, const156, l65, l63, 4, 4, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L67, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l67, const216, const104, const142, l66, 4, 4, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_43

        // L68, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l68, const205, const213, l67, 4, 4, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L69, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l69, const148, const152, const100, l68, l66, 4, 4, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L70, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l70, const159, const167, const209, l69, 4, 4, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_45

        // L71, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l71, const42, const46, l70, 4, 4, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L72, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l72, const92, const98, const163, l71, l69, 4, 4, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L73, kernel=2x2, stride=2, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D2x2Stride2, this, l73, const8, const14, const45, l72, 2, 2, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_47

        // L74, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l74, const94, const1, l73, 2, 2, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L75, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::maxPool2x2Stride2NoPad, this, l75, const47, const51, const41, l74, l72, 2, 2, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L76, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l76, const87, const95, const29, l75, 2, 2, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_49

        // L77, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l77, const77, const82, l76, 2, 2, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L78, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l78, const134, const143, const214, l77, l75, 2, 2, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L79, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l79, const149, const157, const196, l78, 2, 2, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: p_re_lu_51

        // L80, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l80, const33, const39, l79, 2, 2, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L81, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l81, const84, const89, const153, l80, l78, 2, 2, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L82, kernel=2x2, stride=1, padding=none
        for (uint k = 0; k < 15; k++) {
            thread t(&iris::conv2D2x2Stride1, this, l82, const210, const80, l81, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // output layer: conv_iris

        //cout << l82[14] << endl;
    }

    void drawPoints(Mat img)
    {
        // brows + contours
        for (int i = 0; i < 71; i++)
        {
            float x = l57[i * 3];
            float y = l57[i * 3 + 1];
            float z = l57[i * 3 + 2];
            circle(img, Point(x, y), 1, Scalar(255, 255, 255), 0.1, 8, 0);
        }
        // iris
        for (int i = 0; i < 5; i++)
        {
            float x = l82[i * 3];
            float y = l82[i * 3 + 1];
            float z = l82[i * 3 + 2];
            circle(img, Point(x, y), 1, Scalar(255, 0, 0), 0.1, 8, 0);
        }
    }
};

int main()
{
    Mat img;
    img = imread("D:\\Storage\\Unity\\facemesh-python\\data\\eye1.jpg");

    // opencv read stuff in BGR
    cvtColor(img, img, COLOR_BGR2RGB);
    resize(img, img, Size(64, 64), 0.0, 0.0, INTER_AREA);
    img.convertTo(img, CV_32FC3);
    // normalize values
    img = img / 255.0;

    // use a 3d array cause fuck opencv mats
    float*** imgArray = iris::createArray(64, 64, 3, sizeof(float));
    for (int k = 0; k < 3; k++) {
        for (int i = 0; i < 64; i++) {
            for (int j = 0; j < 64; j++) {
                imgArray[i][j][k] = img.at<Vec3f>(i, j)[k];
            }
        }
    }

    //for (int k = 0; k < 3; k++) {
    //    for (int i = 0; i < 64; i++) {
    //        for (int j = 0; j < 64; j++) {
    //            if (k == 0) imgArray[i][j][k] = (i / 63.0f) * (j / 63.0f);
    //            else if (k == 1) imgArray[i][j][k] = ((63.0f - i) / 63.0f) * (j / 63.0f);
    //            else imgArray[i][j][k] = (i / 63.0f) * ((63.0f - j) / 63.0f);
    //        }
    //    }
    //}

    string PATH = "D:\\Storage\\Unity\\facemesh-python\\data\\irisUnity.bytes";
    iris iris_detect = iris(PATH);
    iris_detect.forwardProp(imgArray);
    iris_detect.drawPoints(img);

    cvtColor(img, img, COLOR_RGB2BGR);
    imshow("Display window", img);
    waitKey(0); // Wait for a keystroke in the window

    //getchar();
    iris::freeArray(64, 64, 3, imgArray);
    return 0;
}
