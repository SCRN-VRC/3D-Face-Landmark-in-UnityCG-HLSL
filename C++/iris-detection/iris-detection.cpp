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
        *** l10, *** l11, *** l12, *** l13, *** l14, *** l15, *** l16, *** l17, *** l18, *** l19;

    float*** test;

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
        float*** buff = (float***)createArray(mi, mj, mk, sizeof(float));
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
    // Annoying callocs
    static void** createArray(int i, int j, size_t size)
    {
        void** r = (void**)calloc(i, sizeof(void*));
        for (int x = 0; x < i; x++) {
            r[x] = (void*)calloc(j, size);
        }
        return r;
    }

    static void*** createArray(int i, int j, int k, size_t size)
    {
        void*** r = (void***)calloc(i, sizeof(void*));
        for (int x = 0; x < i; x++) {
            r[x] = (void**)calloc(j, sizeof(void*));
            for (int y = 0; y < j; y++) {
                r[x][y] = (void*)calloc(k, size);
            }
        }
        return r;
    }

    static void**** createArray(int i, int j, int k, int l, size_t size)
    {
        void**** r = (void****)calloc(i, sizeof(void*));
        for (int x = 0; x < i; x++) {
            r[x] = (void***)calloc(j, sizeof(void*));
            for (int y = 0; y < j; y++) {
                r[x][y] = (void**)calloc(k, sizeof(void*));
                for (int z = 0; z < k; z++) {
                    r[x][y][z] = (void*)calloc(l, size);
                }
            }
        }
        return r;
    }

    // Annoying calloc frees
    static void freeArray(int i, void* a)
    {
        std::free(a);
    }

    static void freeArray(int i, int j, void** a)
    {
        for (int x = 0; x < i; x++) {
            std::free(a[x]);
        }
        std::free(a);
    }

    static void freeArray(int i, int j, int k, void*** a)
    {
        for (int x = 0; x < i; x++) {
            for (int y = 0; y < j; y++) {
                std::free(a[x][y]);
            }
            std::free(a[x]);
        }
        std::free(a);
    }

    static void freeArray(int i, int j, int k, int l, void**** a)
    {
        for (int x = 0; x < i; x++) {
            for (int y = 0; y < j; y++) {
                for (int z = 0; z < k; z++) {
                    std::free(a[x][y][z]);
                }
                std::free(a[x][y]);
            }
            std::free(a[x]);
        }
        std::free(a);
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

        l0 = (float***)createArray(32, 32, 64, sizeof(float));
        l1 = (float***)createArray(32, 32, 32, sizeof(float));
        l2 = (float***)createArray(32, 32, 32, sizeof(float));
        l3 = (float***)createArray(32, 32, 64, sizeof(float));
        l4 = (float***)createArray(32, 32, 32, sizeof(float));
        l5 = (float***)createArray(32, 32, 32, sizeof(float));
        l6 = (float***)createArray(32, 32, 64, sizeof(float));
        l7 = (float***)createArray(32, 32, 32, sizeof(float));
        l8 = (float***)createArray(32, 32, 32, sizeof(float));
        l9 = (float***)createArray(32, 32, 64, sizeof(float));
        l10 = (float***)createArray(32, 32, 32, sizeof(float));
        l11 = (float***)createArray(32, 32, 32, sizeof(float));
        l12 = (float***)createArray(32, 32, 64, sizeof(float));
        l13 = (float***)createArray(16, 16, 64, sizeof(float));
        l14 = (float***)createArray(16, 16, 64, sizeof(float));
        l15 = (float***)createArray(16, 16, 64, sizeof(float));
        l16 = (float***)createArray(16, 16, 128, sizeof(float));
        l17 = (float***)createArray(16, 16, 64, sizeof(float));
    }

    ~iris()
    {
        // fuck it, i'm tired of doing this, the program exits after the passes are done anyway
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

    void conv2D1x1Stride1AddDebug(float*** cl, float**** cw, float* bias, float**** slope, float*** pl, float*** pl2,
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
                cl[i][j][k] = cl[i][j][k] + bias[k];
                // activation
                //cl[i][j][k] = PRelu(cl[i][j][k], slope[0][k][0][0]);
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

    void maxPool2x2Stride2(float*** cl, float*** pl,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1;
                uint j0 = j * 2, j1 = j0 + 1;
                cl[i][j][k] = k < lm ?
                    fmaxf(pl[i0][j0][k], fmaxf(pl[i0][j1][k],
                        fmaxf(pl[i1][j0][k], pl[i1][j1][k]))) :
                    0.0f;
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

        // L1, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l1, const119, const128, const154, l0, 32, 32, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L2, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::depthConv2D3x3, this, l2, const181, const185, l1, 32, 32, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L3, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l3, const215, const4, const23, l2, l0, 32, 32, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L4, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l4, const48, const55, const75, l3, 32, 32, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L5, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::depthConv2D3x3, this, l5, const0, const5, l4, 32, 32, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L6, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l6, const25, const34, const63, l5, l3, 32, 32, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L7, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l7, const86, const93, const120, l6, 32, 32, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L8, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::depthConv2D3x3, this, l8, const147, const150, l7, 32, 32, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L9, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l9, const174, const183, const3, l8, l6, 32, 32, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L10, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l10, const27, const36, const56, l9, 32, 32, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L11, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&iris::depthConv2D3x3, this, l11, const78, const83, l10, 32, 32, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L12, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1Add, this, l12, const6, const13, const43, l11, l9, 32, 32, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L13, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D2x2Stride2, this, l13, const69, const73, const96, l12, 16, 16, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L14, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::depthConv2D3x3, this, l14, const18, const24, l13, 16, 16, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L15, max pool=2x2, stride=2
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::maxPool2x2Stride2, this, l15, l12, 16, 16, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L16, kernel=1x1, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&iris::conv2D1x1Stride1AddDebug, this, l16, const57, const64, const10, l14, l15, 16, 16, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L17, kernel=1x1, stride=1, padding=none
        for (uint k = 0; k < 64; k++) {
            thread t(&iris::conv2D1x1Stride1, this, l17, const32, const38, const50, l16, 16, 16, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        cout << l16[15][2][123] << endl;
    }
};

int main()
{
    Mat img;
    img = imread("D:\\Storage\\Unity\\facemesh-python\\data\\eye1.jpg");

    // opencv read stuff in BGR
    cvtColor(img, img, COLOR_BGR2RGB);
    //resize(img, img, Size(64, 64), 0.0, 0.0, INTER_AREA);
    img.convertTo(img, CV_32FC3);
    // normalize values
    img = img / 255.0;

    // use a 3d array cause fuck opencv mats
    float*** imgArray = (float***)iris::createArray(64, 64, 3, sizeof(float));
    //for (int k = 0; k < 3; k++) {
    //    for (int i = 0; i < 64; i++) {
    //        for (int j = 0; j < 64; j++) {
    //            imgArray[i][j][k] = img.at<Vec3f>(i, j)[k];
    //        }
    //    }
    //}

    for (int k = 0; k < 3; k++) {
    	for (int i = 0; i < 64; i++) {
    		for (int j = 0; j < 64; j++) {
    			if (k == 0) imgArray[i][j][k] = (i / 63.0f) * (j / 63.0f);
    			else if (k == 1) imgArray[i][j][k] = ((63.0f - i) / 63.0f) * (j / 63.0f);
    			else imgArray[i][j][k] = (i / 63.0f) * ((63.0f - j) / 63.0f);
    		}
    	}
    }

    string PATH = "D:\\Storage\\Unity\\facemesh-python\\data\\irisUnity.bytes";
    iris iris_detect = iris(PATH);
    iris_detect.forwardProp(imgArray);
    //iris_detect.drawPoints(img);

    //cvtColor(img, img, COLOR_RGB2BGR);
    //imshow("Display window", img);
    //waitKey(0); // Wait for a keystroke in the window

    iris::freeArray(64, 64, 3, (void***)imgArray);
    return 0;
}