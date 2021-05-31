#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <stdio.h>

using namespace std;
using namespace cv;

class facemesh
{
private:

    // weights
    float**** const0, **** const2, **** const4, **** const6, **** const7, **** const9,
        **** const11, **** const14, **** const16, **** const18, **** const20, **** const22,
        **** const24, **** const26, **** const28, **** const30, **** const32, **** const34,
        **** const36, **** const37, **** const39, **** const41, **** const44, **** const46,
        **** const48, **** const50, **** const52, **** const54, **** const57, **** const59,
        **** const62, **** const64, **** const66, **** const69, **** const71, **** const73,
        **** const76, **** const78, **** const80, **** const82, **** const84, **** const86,
        **** const88, **** const90, **** const92, **** const95, **** const97, **** const100,
        **** const101, **** const103, **** const104, **** const106, **** const111, **** const113,
        **** const114;

    // multiplies
    float*** const56, *** const58, *** const60, *** const63, *** const65, *** const67,
        *** const70, *** const72, *** const74, *** const77, *** const79, *** const81,
        *** const83, *** const85, *** const87, *** const89, *** const91, *** const93,
        *** const94, *** const96, *** const105, *** const107, *** const108, *** const109,
        *** const112, *** const115, *** const116, *** const117;

    // 2d array
    float** const61, ** const68, ** const75;

    // bias
    float* const1, * const3, * const5, * const8, * const10, * const12, * const13, * const15,
        * const17, * const19, * const21, * const23, * const25, * const27, * const29, * const31,
        * const33, * const35, * const38, * const40, * const42, * const43, * const45, * const47,
        * const49, * const51, * const53, * const55, * const98, * const99, * const102, * const110;

    // input image
    float*** img;

    // layers
    float*** l0, *** l1, *** bnl1, *** l2, *** bnl2, *** l3, *** mp_bnl3, *** l4, *** bnl4,
        *** l5, *** bnl5, *** l6, *** mp_bnl6, *** l7, *** bnl7, *** l8, *** bnl8, *** l9,
        *** mp_bnl9, *** l10, *** bnl10, *** l11, *** bnl11, *** l12, *** mp_bnl12, *** l13,
        *** bnl13, *** l14, *** bnl14, *** l15, *** mp_bnl15, *** l16, *** bnl16, *** l17,
        *** bnl17, *** l18, *** l19, *** bnl19, * l20, *** l21, *** mp_bnl21, *** l22, *** l23,
        *** bnl23, * l24;

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

    inline float padLayerRight(float*** layer, uint x, uint y, uint z, uint xm, uint ym)
    {
        if (x == xm || y == ym) return 0.0f;
        return layer[x][y][z];
    }

    inline float padLayerEven(float*** layer, uint x, uint y, uint z, uint xm, uint ym)
    {
        if (x == 0 || y == 0 || x > xm || y > ym) return 0.0f;
        return layer[x - 1][y - 1][z];
    }

    inline float relu(float x)
    {
        return fmaxf(0.0f, x);
    }

    inline float sigmoid(float x)
    {
        return 1.0f / (1.0f + expf(-x));
    }

public:
    // Annoying mallocs
    static float** createArray(int i, int j, size_t size)
    {
        float** r = new float* [i * sizeof(float*)];
        for (int x = 0; x < i; x++) {
            r[x] = new float[j * size];
        }
        return r;
    }

    static float*** createArray(int i, int j, int k, size_t size)
    {
        float*** r = new float** [i * sizeof(float*)];
        for (int x = 0; x < i; x++) {
            r[x] = new float* [j * sizeof(float*)];
            for (int y = 0; y < j; y++) {
                r[x][y] = new float[k * size];
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
                    r[x][y][z] = new float[l * size];
                }
            }
        }
        return r;
    }

    // Annoying malloc frees
    static void freeArray(int i, float* a)
    {
        delete[] a;
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

    facemesh(string path)
    {
        ifstream fin(path, ios::binary);
        if (!fin) {
            cout << "error opening stream" << endl;
            exit(-1);
        }

        const0 = getArray(&fin, 3, 3, 3, 16);
        const1 = getArray(&fin, 16);
        const2 = getArray(&fin, 1, 1, 16, 16);
        const3 = getArray(&fin, 16);
        const4 = getArray(&fin, 1, 1, 16, 16);
        const5 = getArray(&fin, 16);
        const6 = getArray(&fin, 1, 1, 16, 32);
        const7 = getArray(&fin, 1, 1, 32, 32);
        const8 = getArray(&fin, 32);
        const9 = getArray(&fin, 1, 1, 32, 32);
        const10 = getArray(&fin, 32);
        const11 = getArray(&fin, 1, 1, 32, 32);
        const12 = getArray(&fin, 32);
        const13 = getArray(&fin, 32);
        const14 = getArray(&fin, 1, 1, 32, 64);
        const15 = getArray(&fin, 64);
        const16 = getArray(&fin, 1, 1, 64, 64);
        const17 = getArray(&fin, 64);
        const18 = getArray(&fin, 1, 1, 64, 64);
        const19 = getArray(&fin, 64);
        const20 = getArray(&fin, 1, 1, 64, 128);
        const21 = getArray(&fin, 128);
        const22 = getArray(&fin, 1, 1, 128, 128);
        const23 = getArray(&fin, 128);
        const24 = getArray(&fin, 1, 1, 128, 128);
        const25 = getArray(&fin, 128);
        const26 = getArray(&fin, 1, 1, 128, 128);
        const27 = getArray(&fin, 128);
        const28 = getArray(&fin, 1, 1, 128, 128);
        const29 = getArray(&fin, 128);
        const30 = getArray(&fin, 1, 1, 128, 128);
        const31 = getArray(&fin, 128);
        const32 = getArray(&fin, 1, 1, 128, 128);
        const33 = getArray(&fin, 128);
        const34 = getArray(&fin, 1, 1, 128, 128);
        const35 = getArray(&fin, 128);
        const36 = getArray(&fin, 1, 1, 128, 128);
        const37 = getArray(&fin, 1, 1, 32, 32);
        const38 = getArray(&fin, 128);
        const39 = getArray(&fin, 1, 1, 128, 32);
        const40 = getArray(&fin, 32);
        const41 = getArray(&fin, 1, 1, 128, 128);
        const42 = getArray(&fin, 32);
        const43 = getArray(&fin, 128);
        const44 = getArray(&fin, 1, 1, 128, 128);
        const45 = getArray(&fin, 128);
        const46 = getArray(&fin, 1, 1, 32, 32);
        const47 = getArray(&fin, 32);
        const48 = getArray(&fin, 1, 1, 128, 128);
        const49 = getArray(&fin, 128);
        const50 = getArray(&fin, 1, 1, 128, 128);
        const51 = getArray(&fin, 128);
        const52 = getArray(&fin, 1, 1, 128, 32);
        const53 = getArray(&fin, 32);
        const54 = getArray(&fin, 1, 1, 128, 32);
        const55 = getArray(&fin, 32);
        const56 = getArray(&fin, 1, 1, 16);
        const57 = getArray(&fin, 3, 3, 16, 1);
        const58 = getArray(&fin, 1, 1, 16);
        const59 = getArray(&fin, 3, 3, 16, 1);
        const60 = getArray(&fin, 1, 1, 16);
        const61 = getArray(&fin, 4, 2);
        const62 = getArray(&fin, 3, 3, 16, 1);
        const63 = getArray(&fin, 1, 1, 32);
        const64 = getArray(&fin, 3, 3, 32, 1);
        const65 = getArray(&fin, 1, 1, 32);
        const66 = getArray(&fin, 3, 3, 32, 1);
        const67 = getArray(&fin, 1, 1, 32);
        const68 = getArray(&fin, 4, 2);
        const69 = getArray(&fin, 3, 3, 32, 1);
        const70 = getArray(&fin, 1, 1, 64);
        const71 = getArray(&fin, 3, 3, 64, 1);
        const72 = getArray(&fin, 1, 1, 64);
        const73 = getArray(&fin, 3, 3, 64, 1);
        const74 = getArray(&fin, 1, 1, 64);
        const75 = getArray(&fin, 4, 2);
        const76 = getArray(&fin, 3, 3, 64, 1);
        const77 = getArray(&fin, 1, 1, 128);
        const78 = getArray(&fin, 3, 3, 128, 1);
        const79 = getArray(&fin, 1, 1, 128);
        const80 = getArray(&fin, 3, 3, 128, 1);
        const81 = getArray(&fin, 1, 1, 128);
        const82 = getArray(&fin, 3, 3, 128, 1);
        const83 = getArray(&fin, 1, 1, 128);
        const84 = getArray(&fin, 3, 3, 128, 1);
        const85 = getArray(&fin, 1, 1, 128);
        const86 = getArray(&fin, 3, 3, 128, 1);
        const87 = getArray(&fin, 1, 1, 128);
        const88 = getArray(&fin, 3, 3, 128, 1);
        const89 = getArray(&fin, 1, 1, 128);
        const90 = getArray(&fin, 3, 3, 128, 1);
        const91 = getArray(&fin, 1, 1, 128);
        const92 = getArray(&fin, 3, 3, 128, 1);
        const93 = getArray(&fin, 1, 1, 128);
        const94 = getArray(&fin, 1, 1, 32);
        const95 = getArray(&fin, 3, 3, 32, 1);
        const96 = getArray(&fin, 1, 1, 32);
        const97 = getArray(&fin, 3, 3, 32, 1404);
        const98 = getArray(&fin, 1404);
        const99 = getArray(&fin, 2);
        const100 = getArray(&fin, 3, 3, 128, 1);
        const101 = getArray(&fin, 3, 3, 32, 1);
        const102 = getArray(&fin, 1);
        const103 = getArray(&fin, 3, 3, 32, 1);
        const104 = getArray(&fin, 3, 3, 128, 1);
        const105 = getArray(&fin, 1, 1, 32);
        const106 = getArray(&fin, 3, 3, 128, 1);
        const107 = getArray(&fin, 1, 1, 128);
        const108 = getArray(&fin, 1, 1, 32);
        const109 = getArray(&fin, 1, 1, 128);
        const110 = getArray(&fin, 266);
        const111 = getArray(&fin, 3, 3, 128, 1);
        const112 = getArray(&fin, 1, 1, 128);
        const113 = getArray(&fin, 3, 3, 32, 266);
        const114 = getArray(&fin, 3, 3, 32, 1);
        const115 = getArray(&fin, 1, 1, 32);
        const116 = getArray(&fin, 1, 1, 32);
        const117 = getArray(&fin, 1, 1, 128);

        fin.close();

        l0 = (float***)createArray(96, 96, 16, sizeof(float));
        l1 = (float***)createArray(96, 96, 16, sizeof(float));
        bnl1 = (float***)createArray(96, 96, 16, sizeof(float));
        l2 = (float***)createArray(96, 96, 16, sizeof(float));
        bnl2 = (float***)createArray(96, 96, 16, sizeof(float));
        l3 = (float***)createArray(48, 48, 16, sizeof(float));
        mp_bnl3 = (float***)createArray(48, 48, 32, sizeof(float));
        l4 = (float***)createArray(48, 48, 32, sizeof(float));
        bnl4 = (float***)createArray(48, 48, 32, sizeof(float));
        l5 = (float***)createArray(48, 48, 32, sizeof(float));
        bnl5 = (float***)createArray(48, 48, 32, sizeof(float));
        l6 = (float***)createArray(24, 24, 32, sizeof(float));
        mp_bnl6 = (float***)createArray(24, 24, 64, sizeof(float));
        l7 = (float***)createArray(24, 24, 64, sizeof(float));
        bnl7 = (float***)createArray(24, 24, 64, sizeof(float));
        l8 = (float***)createArray(24, 24, 64, sizeof(float));
        bnl8 = (float***)createArray(24, 24, 64, sizeof(float));
        l9 = (float***)createArray(12, 12, 64, sizeof(float));
        mp_bnl9 = (float***)createArray(12, 12, 128, sizeof(float));
        l10 = (float***)createArray(12, 12, 128, sizeof(float));
        bnl10 = (float***)createArray(12, 12, 128, sizeof(float));
        l11 = (float***)createArray(12, 12, 128, sizeof(float));
        bnl11 = (float***)createArray(12, 12, 128, sizeof(float));
        l12 = (float***)createArray(6, 6, 128, sizeof(float));
        mp_bnl12 = (float***)createArray(6, 6, 128, sizeof(float));
        l13 = (float***)createArray(6, 6, 128, sizeof(float));
        bnl13 = (float***)createArray(6, 6, 128, sizeof(float));
        l14 = (float***)createArray(6, 6, 128, sizeof(float));
        bnl14 = (float***)createArray(6, 6, 128, sizeof(float));
        l15 = (float***)createArray(3, 3, 128, sizeof(float));
        mp_bnl15 = (float***)createArray(3, 3, 128, sizeof(float));
        l16 = (float***)createArray(3, 3, 128, sizeof(float));
        bnl16 = (float***)createArray(3, 3, 128, sizeof(float));
        l17 = (float***)createArray(3, 3, 128, sizeof(float));
        bnl17 = (float***)createArray(3, 3, 128, sizeof(float));
        l18 = (float***)createArray(3, 3, 32, sizeof(float));
        l19 = (float***)createArray(3, 3, 32, sizeof(float));
        bnl19 = (float***)createArray(3, 3, 32, sizeof(float));
        l20 = (float*)malloc(1404 * sizeof(float));
        l21 = (float***)createArray(3, 3, 128, sizeof(float));
        mp_bnl21 = (float***)createArray(3, 3, 128, sizeof(float));
        l22 = (float***)createArray(3, 3, 32, sizeof(float));
        l23 = (float***)createArray(3, 3, 32, sizeof(float));
        bnl23 = (float***)createArray(3, 3, 32, sizeof(float));
        l24 = (float*)malloc(sizeof(float));
    }

    ~facemesh()
    {
        freeArray(3, 3, 3, 16, const0);
        freeArray(16, const1);
        freeArray(1, 1, 16, 16, const2);
        freeArray(16, const3);
        freeArray(1, 1, 16, 16, const4);
        freeArray(16, const5);
        freeArray(1, 1, 16, 32, const6);
        freeArray(1, 1, 32, 32, const7);
        freeArray(32, const8);
        freeArray(1, 1, 32, 32, const9);
        freeArray(32, const10);
        freeArray(1, 1, 32, 32, const11);
        freeArray(32, const12);
        freeArray(32, const13);
        freeArray(1, 1, 32, 64, const14);
        freeArray(64, const15);
        freeArray(1, 1, 64, 64, const16);
        freeArray(64, const17);
        freeArray(1, 1, 64, 64, const18);
        freeArray(64, const19);
        freeArray(1, 1, 64, 128, const20);
        freeArray(128, const21);
        freeArray(1, 1, 128, 128, const22);
        freeArray(128, const23);
        freeArray(1, 1, 128, 128, const24);
        freeArray(128, const25);
        freeArray(1, 1, 128, 128, const26);
        freeArray(128, const27);
        freeArray(1, 1, 128, 128, const28);
        freeArray(128, const29);
        freeArray(1, 1, 128, 128, const30);
        freeArray(128, const31);
        freeArray(1, 1, 128, 128, const32);
        freeArray(128, const33);
        freeArray(1, 1, 128, 128, const34);
        freeArray(128, const35);
        freeArray(1, 1, 128, 128, const36);
        freeArray(1, 1, 32, 32, const37);
        freeArray(128, const38);
        freeArray(1, 1, 128, 32, const39);
        freeArray(32, const40);
        freeArray(1, 1, 128, 128, const41);
        freeArray(32, const42);
        freeArray(128, const43);
        freeArray(1, 1, 128, 128, const44);
        freeArray(128, const45);
        freeArray(1, 1, 32, 32, const46);
        freeArray(32, const47);
        freeArray(1, 1, 128, 128, const48);
        freeArray(128, const49);
        freeArray(1, 1, 128, 128, const50);
        freeArray(128, const51);
        freeArray(1, 1, 128, 32, const52);
        freeArray(32, const53);
        freeArray(1, 1, 128, 32, const54);
        freeArray(32, const55);
        freeArray(1, 1, 16, const56);
        freeArray(3, 3, 16, 1, const57);
        freeArray(1, 1, 16, const58);
        freeArray(3, 3, 16, 1, const59);
        freeArray(1, 1, 16, const60);
        freeArray(4, 2, const61);
        freeArray(3, 3, 16, 1, const62);
        freeArray(1, 1, 32, const63);
        freeArray(3, 3, 32, 1, const64);
        freeArray(1, 1, 32, const65);
        freeArray(3, 3, 32, 1, const66);
        freeArray(1, 1, 32, const67);
        freeArray(4, 2, const68);
        freeArray(3, 3, 32, 1, const69);
        freeArray(1, 1, 64, const70);
        freeArray(3, 3, 64, 1, const71);
        freeArray(1, 1, 64, const72);
        freeArray(3, 3, 64, 1, const73);
        freeArray(1, 1, 64, const74);
        freeArray(4, 2, const75);
        freeArray(3, 3, 64, 1, const76);
        freeArray(1, 1, 128, const77);
        freeArray(3, 3, 128, 1, const78);
        freeArray(1, 1, 128, const79);
        freeArray(3, 3, 128, 1, const80);
        freeArray(1, 1, 128, const81);
        freeArray(3, 3, 128, 1, const82);
        freeArray(1, 1, 128, const83);
        freeArray(3, 3, 128, 1, const84);
        freeArray(1, 1, 128, const85);
        freeArray(3, 3, 128, 1, const86);
        freeArray(1, 1, 128, const87);
        freeArray(3, 3, 128, 1, const88);
        freeArray(1, 1, 128, const89);
        freeArray(3, 3, 128, 1, const90);
        freeArray(1, 1, 128, const91);
        freeArray(3, 3, 128, 1, const92);
        freeArray(1, 1, 128, const93);
        freeArray(1, 1, 32, const94);
        freeArray(3, 3, 32, 1, const95);
        freeArray(1, 1, 32, const96);
        freeArray(3, 3, 32, 1404, const97);
        freeArray(1404, const98);
        freeArray(2, const99);
        freeArray(3, 3, 128, 1, const100);
        freeArray(3, 3, 32, 1, const101);
        freeArray(1, const102);
        freeArray(3, 3, 32, 1, const103);
        freeArray(3, 3, 128, 1, const104);
        freeArray(1, 1, 32, const105);
        freeArray(3, 3, 128, 1, const106);
        freeArray(1, 1, 128, const107);
        freeArray(1, 1, 32, const108);
        freeArray(1, 1, 128, const109);
        freeArray(266, const110);
        freeArray(3, 3, 128, 1, const111);
        freeArray(1, 1, 128, const112);
        freeArray(3, 3, 32, 266, const113);
        freeArray(3, 3, 32, 1, const114);
        freeArray(1, 1, 32, const115);
        freeArray(1, 1, 32, const116);
        freeArray(1, 1, 128, const117);
    }

    // Using seperate methods for each layer easier to debug
    void kernelPaddedRightL0(float*** cl, float**** cw, float* bias, float*** cm, float*** pl,
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
                        padLayerRight(pl, i0, j0, l, h_im, h_jm) * cw[0][0][l][k] +
                        padLayerRight(pl, i0, j1, l, h_im, h_jm) * cw[0][1][l][k] +
                        padLayerRight(pl, i0, j2, l, h_im, h_jm) * cw[0][2][l][k] +
                        padLayerRight(pl, i1, j0, l, h_im, h_jm) * cw[1][0][l][k] +
                        padLayerRight(pl, i1, j1, l, h_im, h_jm) * cw[1][1][l][k] +
                        padLayerRight(pl, i1, j2, l, h_im, h_jm) * cw[1][2][l][k] +
                        padLayerRight(pl, i2, j0, l, h_im, h_jm) * cw[2][0][l][k] +
                        padLayerRight(pl, i2, j1, l, h_im, h_jm) * cw[2][1][l][k] +
                        padLayerRight(pl, i2, j2, l, h_im, h_jm) * cw[2][2][l][k];
                }
                // bias
                cl[i][j][k] = cl[i][j][k] + bias[k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L1, depth wise convolution
    void kernelPaddedEvenL1(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL1, batch norm
    void batchNormL1(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L2, depth wise convolution
    void kernelPaddedEvenL2(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL2, batch norm
    void batchNormL2(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L3, depth wise convolution, stride=2
    void kernelPaddedEvenL3(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        // Max index to pad
        uint h_im = im * 2;
        uint h_jm = jm * 2;

        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerRight(pl, i0, j0, k, h_im, h_jm) * cw[0][0][k][0] +
                    padLayerRight(pl, i0, j1, k, h_im, h_jm) * cw[0][1][k][0] +
                    padLayerRight(pl, i0, j2, k, h_im, h_jm) * cw[0][2][k][0] +
                    padLayerRight(pl, i1, j0, k, h_im, h_jm) * cw[1][0][k][0] +
                    padLayerRight(pl, i1, j1, k, h_im, h_jm) * cw[1][1][k][0] +
                    padLayerRight(pl, i1, j2, k, h_im, h_jm) * cw[1][2][k][0] +
                    padLayerRight(pl, i2, j0, k, h_im, h_jm) * cw[2][0][k][0] +
                    padLayerRight(pl, i2, j1, k, h_im, h_jm) * cw[2][1][k][0] +
                    padLayerRight(pl, i2, j2, k, h_im, h_jm) * cw[2][2][k][0];
            }
        }
    }

    // L3 Max pool + batch norm
    void maxPoolBatchNormL3(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1;
                uint j0 = j * 2, j1 = j0 + 1;
                if (k < lm) {
                    cl[i][j][k] = fmaxf(fmaxf(fmaxf(pl[i0][j0][k], pl[i0][j1][k]),
                        pl[i1][j0][k]), pl[i1][j1][k]);
                }
                else {
                    cl[i][j][k] = 0.0f;
                }

                float c2 = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    c2 += pl2[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                c2 = c2 + bias[k];
                cl[i][j][k] = cl[i][j][k] + c2;

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L4, depth wise convolution
    void kernelPaddedEvenL4(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL4, batch norm
    void batchNormL4(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L5, depth wise convolution
    void kernelPaddedEvenL5(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL5, batch norm
    void batchNormL5(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L6, depth wise convolution, stride=2
    void kernelPaddedEvenL6(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        // Max index to pad
        uint h_im = im * 2;
        uint h_jm = jm * 2;

        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerRight(pl, i0, j0, k, h_im, h_jm) * cw[0][0][k][0] +
                    padLayerRight(pl, i0, j1, k, h_im, h_jm) * cw[0][1][k][0] +
                    padLayerRight(pl, i0, j2, k, h_im, h_jm) * cw[0][2][k][0] +
                    padLayerRight(pl, i1, j0, k, h_im, h_jm) * cw[1][0][k][0] +
                    padLayerRight(pl, i1, j1, k, h_im, h_jm) * cw[1][1][k][0] +
                    padLayerRight(pl, i1, j2, k, h_im, h_jm) * cw[1][2][k][0] +
                    padLayerRight(pl, i2, j0, k, h_im, h_jm) * cw[2][0][k][0] +
                    padLayerRight(pl, i2, j1, k, h_im, h_jm) * cw[2][1][k][0] +
                    padLayerRight(pl, i2, j2, k, h_im, h_jm) * cw[2][2][k][0];
            }
        }
    }

    // L6 Max pool + batch norm
    void maxPoolBatchNormL6(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1;
                uint j0 = j * 2, j1 = j0 + 1;
                if (k < lm) {
                    cl[i][j][k] = fmaxf(fmaxf(fmaxf(pl[i0][j0][k], pl[i0][j1][k]),
                        pl[i1][j0][k]), pl[i1][j1][k]);
                }
                else {
                    cl[i][j][k] = 0.0f;
                }

                float c2 = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    c2 += pl2[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                c2 = c2 + bias[k];
                cl[i][j][k] = cl[i][j][k] + c2;

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L7, depth wise convolution
    void kernelPaddedEvenL7(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL7, batch norm
    void batchNormL7(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L8, depth wise convolution
    void kernelPaddedEvenL8(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL8, batch norm
    void batchNormL8(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L9, depth wise convolution, stride=2
    void kernelPaddedEvenL9(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        // Max index to pad
        uint h_im = im * 2;
        uint h_jm = jm * 2;

        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerRight(pl, i0, j0, k, h_im, h_jm) * cw[0][0][k][0] +
                    padLayerRight(pl, i0, j1, k, h_im, h_jm) * cw[0][1][k][0] +
                    padLayerRight(pl, i0, j2, k, h_im, h_jm) * cw[0][2][k][0] +
                    padLayerRight(pl, i1, j0, k, h_im, h_jm) * cw[1][0][k][0] +
                    padLayerRight(pl, i1, j1, k, h_im, h_jm) * cw[1][1][k][0] +
                    padLayerRight(pl, i1, j2, k, h_im, h_jm) * cw[1][2][k][0] +
                    padLayerRight(pl, i2, j0, k, h_im, h_jm) * cw[2][0][k][0] +
                    padLayerRight(pl, i2, j1, k, h_im, h_jm) * cw[2][1][k][0] +
                    padLayerRight(pl, i2, j2, k, h_im, h_jm) * cw[2][2][k][0];
            }
        }
    }

    // L9 Max pool + batch norm
    void maxPoolBatchNormL9(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1;
                uint j0 = j * 2, j1 = j0 + 1;
                if (k < lm) {
                    cl[i][j][k] = fmaxf(fmaxf(fmaxf(pl[i0][j0][k], pl[i0][j1][k]),
                        pl[i1][j0][k]), pl[i1][j1][k]);
                }
                else {
                    cl[i][j][k] = 0.0f;
                }

                float c2 = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    c2 += pl2[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                c2 = c2 + bias[k];
                cl[i][j][k] = cl[i][j][k] + c2;

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L10, depth wise convolution
    void kernelPaddedEvenL10(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL10, batch norm
    void batchNormL10(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L11, depth wise convolution
    void kernelPaddedEvenL11(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL11, batch norm
    void batchNormL11(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L12, depth wise convolution, stride=2
    void kernelPaddedEvenL12(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        // Max index to pad
        uint h_im = im * 2;
        uint h_jm = jm * 2;

        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerRight(pl, i0, j0, k, h_im, h_jm) * cw[0][0][k][0] +
                    padLayerRight(pl, i0, j1, k, h_im, h_jm) * cw[0][1][k][0] +
                    padLayerRight(pl, i0, j2, k, h_im, h_jm) * cw[0][2][k][0] +
                    padLayerRight(pl, i1, j0, k, h_im, h_jm) * cw[1][0][k][0] +
                    padLayerRight(pl, i1, j1, k, h_im, h_jm) * cw[1][1][k][0] +
                    padLayerRight(pl, i1, j2, k, h_im, h_jm) * cw[1][2][k][0] +
                    padLayerRight(pl, i2, j0, k, h_im, h_jm) * cw[2][0][k][0] +
                    padLayerRight(pl, i2, j1, k, h_im, h_jm) * cw[2][1][k][0] +
                    padLayerRight(pl, i2, j2, k, h_im, h_jm) * cw[2][2][k][0];
            }
        }
    }

    // L12 Max pool + batch norm
    void maxPoolBatchNormL12(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1;
                uint j0 = j * 2, j1 = j0 + 1;
                cl[i][j][k] = fmaxf(fmaxf(fmaxf(pl[i0][j0][k], pl[i0][j1][k]),
                    pl[i1][j0][k]), pl[i1][j1][k]);

                float c2 = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    c2 += pl2[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                c2 = c2 + bias[k];
                cl[i][j][k] = cl[i][j][k] + c2;

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L13, depth wise convolution
    void kernelPaddedEvenL13(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL13, batch norm
    void batchNormL13(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L14, depth wise convolution
    void kernelPaddedEvenL14(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL14, batch norm
    void batchNormL14(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L15, depth wise convolution, stride=2
    void kernelPaddedEvenL15(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        // Max index to pad
        uint h_im = im * 2;
        uint h_jm = jm * 2;

        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerRight(pl, i0, j0, k, h_im, h_jm) * cw[0][0][k][0] +
                    padLayerRight(pl, i0, j1, k, h_im, h_jm) * cw[0][1][k][0] +
                    padLayerRight(pl, i0, j2, k, h_im, h_jm) * cw[0][2][k][0] +
                    padLayerRight(pl, i1, j0, k, h_im, h_jm) * cw[1][0][k][0] +
                    padLayerRight(pl, i1, j1, k, h_im, h_jm) * cw[1][1][k][0] +
                    padLayerRight(pl, i1, j2, k, h_im, h_jm) * cw[1][2][k][0] +
                    padLayerRight(pl, i2, j0, k, h_im, h_jm) * cw[2][0][k][0] +
                    padLayerRight(pl, i2, j1, k, h_im, h_jm) * cw[2][1][k][0] +
                    padLayerRight(pl, i2, j2, k, h_im, h_jm) * cw[2][2][k][0];
            }
        }
    }

    // L15 Max pool + batch norm
    void maxPoolBatchNormL15(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1;
                uint j0 = j * 2, j1 = j0 + 1;
                cl[i][j][k] = fmaxf(fmaxf(fmaxf(pl[i0][j0][k], pl[i0][j1][k]),
                    pl[i1][j0][k]), pl[i1][j1][k]);

                float c2 = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    c2 += pl2[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                c2 = c2 + bias[k];
                cl[i][j][k] = cl[i][j][k] + c2;

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L16, depth wise convolution
    void kernelPaddedEvenL16(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL16, batch norm
    void batchNormL16(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L17, depth wise convolution
    void kernelPaddedEvenL17(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL17, batch norm
    void batchNormL17(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L18, kernel=1x1, stride=1, pading=valid
    void kernelPaddedRightL18(float*** cl, float**** cw, float* bias, float*** cm, float*** pl,
        uint im, uint jm, uint k, uint lm)
    {
        // Max index to pad
        uint h_im = im;
        uint h_jm = jm;

        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] +=
                        padLayerRight(pl, i, j, l, h_im, h_jm) * cw[0][0][l][k];
                }
                // bias
                cl[i][j][k] = cl[i][j][k] + bias[k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L19, depth wise convolution
    void kernelPaddedEvenL19(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL19, batch norm
    void batchNormL19(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L20, kernel=3x3, stride=1, padding=valid
    void kernelPaddedRightL20(float* cl, float**** cw, float* bias, float*** pl,
        uint im, uint jm, uint k, uint lm)
    {
        // Max index to pad
        uint h_im = im;
        uint h_jm = jm;

        cl[k] = 0.0f;
        uint i0 = 0, i1 = i0 + 1, i2 = i0 + 2;
        uint j0 = 0, j1 = j0 + 1, j2 = j0 + 2;
        // kernel
        for (uint l = 0; l < lm; l++) {
            cl[k] +=
                padLayerRight(pl, i0, j0, l, h_im, h_jm) * cw[0][0][l][k] +
                padLayerRight(pl, i0, j1, l, h_im, h_jm) * cw[0][1][l][k] +
                padLayerRight(pl, i0, j2, l, h_im, h_jm) * cw[0][2][l][k] +
                padLayerRight(pl, i1, j0, l, h_im, h_jm) * cw[1][0][l][k] +
                padLayerRight(pl, i1, j1, l, h_im, h_jm) * cw[1][1][l][k] +
                padLayerRight(pl, i1, j2, l, h_im, h_jm) * cw[1][2][l][k] +
                padLayerRight(pl, i2, j0, l, h_im, h_jm) * cw[2][0][l][k] +
                padLayerRight(pl, i2, j1, l, h_im, h_jm) * cw[2][1][l][k] +
                padLayerRight(pl, i2, j2, l, h_im, h_jm) * cw[2][2][l][k];
        }
        // bias
        cl[k] = cl[k] + bias[k];
    }

    // L21, depth wise convolution, stride=2
    void kernelPaddedEvenL21(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        // Max index to pad
        uint h_im = im * 2;
        uint h_jm = jm * 2;

        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerRight(pl, i0, j0, k, h_im, h_jm) * cw[0][0][k][0] +
                    padLayerRight(pl, i0, j1, k, h_im, h_jm) * cw[0][1][k][0] +
                    padLayerRight(pl, i0, j2, k, h_im, h_jm) * cw[0][2][k][0] +
                    padLayerRight(pl, i1, j0, k, h_im, h_jm) * cw[1][0][k][0] +
                    padLayerRight(pl, i1, j1, k, h_im, h_jm) * cw[1][1][k][0] +
                    padLayerRight(pl, i1, j2, k, h_im, h_jm) * cw[1][2][k][0] +
                    padLayerRight(pl, i2, j0, k, h_im, h_jm) * cw[2][0][k][0] +
                    padLayerRight(pl, i2, j1, k, h_im, h_jm) * cw[2][1][k][0] +
                    padLayerRight(pl, i2, j2, k, h_im, h_jm) * cw[2][2][k][0];
            }
        }
    }

    // L21 Max pool + batch norm
    void maxPoolBatchNormL21(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i * 2, i1 = i0 + 1;
                uint j0 = j * 2, j1 = j0 + 1;
                cl[i][j][k] = fmaxf(fmaxf(fmaxf(pl[i0][j0][k], pl[i0][j1][k]),
                    pl[i1][j0][k]), pl[i1][j1][k]);

                float c2 = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    c2 += pl2[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                c2 = c2 + bias[k];
                cl[i][j][k] = cl[i][j][k] + c2;

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L122, kernel=1x1, stride=1, pading=valid
    void kernelPaddedRightL22(float*** cl, float**** cw, float* bias, float*** cm, float*** pl,
        uint im, uint jm, uint k, uint lm)
    {
        // Max index to pad
        uint h_im = im;
        uint h_jm = jm;

        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] +=
                        padLayerRight(pl, i, j, l, h_im, h_jm) * cw[0][0][l][k];
                }
                // bias
                cl[i][j][k] = cl[i][j][k] + bias[k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L23, depth wise convolution
    void kernelPaddedEvenL23(float*** cl, float**** cw, float*** pl,
        uint im, uint jm, uint k)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 depth wise kernel
                cl[i][j][k] =
                    padLayerEven(pl, i0, j0, k, im, jm) * cw[0][0][k][0] +
                    padLayerEven(pl, i0, j1, k, im, jm) * cw[0][1][k][0] +
                    padLayerEven(pl, i0, j2, k, im, jm) * cw[0][2][k][0] +
                    padLayerEven(pl, i1, j0, k, im, jm) * cw[1][0][k][0] +
                    padLayerEven(pl, i1, j1, k, im, jm) * cw[1][1][k][0] +
                    padLayerEven(pl, i1, j2, k, im, jm) * cw[1][2][k][0] +
                    padLayerEven(pl, i2, j0, k, im, jm) * cw[2][0][k][0] +
                    padLayerEven(pl, i2, j1, k, im, jm) * cw[2][1][k][0] +
                    padLayerEven(pl, i2, j2, k, im, jm) * cw[2][2][k][0];
            }
        }
    }

    // bnL23, batch norm
    void batchNormL23(float*** cl, float**** cw, float* bias, float*** cm, float*** pl, float*** pl2,
        uint im, uint jm, uint k, uint lm)
    {
        for (uint i = 0; i < im; i++) {
            for (uint j = 0; j < jm; j++) {
                cl[i][j][k] = 0.0f;
                // 1x1 kernel
                for (uint l = 0; l < lm; l++) {
                    cl[i][j][k] += pl[i][j][l] * cw[0][0][l][k];
                }
                // bias + add another layer
                cl[i][j][k] = cl[i][j][k] + bias[k] + pl2[i][j][k];

                // activation
                cl[i][j][k] = relu(cl[i][j][k]) + relu(-cl[i][j][k]) * cm[0][0][k];
            }
        }
    }

    // L24, kernel=3x3, stride=1, padding=valid
    void kernelPaddedRightL24(float* cl, float**** cw, float* bias, float*** pl,
        uint im, uint jm, uint k, uint lm)
    {
        // Max index to pad
        uint h_im = im;
        uint h_jm = jm;

        cl[k] = 0.0f;
        uint i0 = 0, i1 = i0 + 1, i2 = i0 + 2;
        uint j0 = 0, j1 = j0 + 1, j2 = j0 + 2;
        // kernel
        for (uint l = 0; l < lm; l++) {
            cl[k] +=
                padLayerRight(pl, i0, j0, l, h_im, h_jm) * cw[0][0][l][k] +
                padLayerRight(pl, i0, j1, l, h_im, h_jm) * cw[0][1][l][k] +
                padLayerRight(pl, i0, j2, l, h_im, h_jm) * cw[0][2][l][k] +
                padLayerRight(pl, i1, j0, l, h_im, h_jm) * cw[1][0][l][k] +
                padLayerRight(pl, i1, j1, l, h_im, h_jm) * cw[1][1][l][k] +
                padLayerRight(pl, i1, j2, l, h_im, h_jm) * cw[1][2][l][k] +
                padLayerRight(pl, i2, j0, l, h_im, h_jm) * cw[2][0][l][k] +
                padLayerRight(pl, i2, j1, l, h_im, h_jm) * cw[2][1][l][k] +
                padLayerRight(pl, i2, j2, l, h_im, h_jm) * cw[2][2][l][k];
        }
        // bias and activation
        cl[k] = sigmoid(cl[k] + bias[k]);
    }

    void forwardProp(float*** imgIn)
    {
        img = imgIn;

        vector<thread> threads;

        // L0, kernel=3x3, stride=2, padding=even
        for (uint k = 0; k < 16; k++) {
            thread t(&facemesh::kernelPaddedRightL0, this, l0, const0, const1, const56, img, 96, 96, k, 3);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L1, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 16; k++) {
            thread t(&facemesh::kernelPaddedEvenL1, this, l1, const57, l0, 96, 96, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL1, batch norm
        for (uint k = 0; k < 16; k++) {
            thread t(&facemesh::batchNormL1, this, bnl1, const2, const3, const58, l1, l0, 96, 96, k, 16);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L2, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 16; k++) {
            thread t(&facemesh::kernelPaddedEvenL2, this, l2, const59, bnl1, 96, 96, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL2, batch norm
        for (uint k = 0; k < 16; k++) {
            thread t(&facemesh::batchNormL2, this, bnl2, const4, const5, const60, l2, bnl1, 96, 96, k, 16);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L3, depthwise conv, kernel=3x3, stride=2, padding=even
        for (uint k = 0; k < 16; k++) {
            thread t(&facemesh::kernelPaddedEvenL3, this, l3, const62, bnl2, 48, 48, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // mp_bnL3, max pool + batch norm
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::maxPoolBatchNormL3, this, mp_bnl3, const6, const8, const63, bnl2, l3, 48, 48, k, 16);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L4, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::kernelPaddedEvenL4, this, l4, const64, mp_bnl3, 48, 48, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL4, batch norm
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::batchNormL4, this, bnl4, const9, const10, const65, l4, mp_bnl3, 48, 48, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L5, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::kernelPaddedEvenL5, this, l5, const66, bnl4, 48, 48, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL5, batch norm
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::batchNormL5, this, bnl5, const11, const13, const67, l5, bnl4, 48, 48, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L6, depthwise conv, kernel=3x3, stride=2, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::kernelPaddedEvenL6, this, l6, const69, bnl5, 24, 24, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // mp_bnL6, max pool + batch norm
        for (uint k = 0; k < 64; k++) {
            thread t(&facemesh::maxPoolBatchNormL6, this, mp_bnl6, const14, const15, const70, bnl5, l6, 24, 24, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L7, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&facemesh::kernelPaddedEvenL7, this, l7, const71, mp_bnl6, 24, 24, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL7, batch norm
        for (uint k = 0; k < 64; k++) {
            thread t(&facemesh::batchNormL7, this, bnl7, const16, const17, const72, l7, mp_bnl6, 24, 24, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L8, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&facemesh::kernelPaddedEvenL8, this, l8, const73, bnl7, 24, 24, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL8, batch norm
        for (uint k = 0; k < 64; k++) {
            thread t(&facemesh::batchNormL8, this, bnl8, const18, const19, const74, l8, bnl7, 24, 24, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L9, depthwise conv, kernel=3x3, stride=2, padding=even
        for (uint k = 0; k < 64; k++) {
            thread t(&facemesh::kernelPaddedEvenL9, this, l9, const76, bnl8, 12, 12, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // mp_bnL9, max pool + batch norm
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::maxPoolBatchNormL9, this, mp_bnl9, const20, const21, const77, bnl8, l9, 12, 12, k, 64);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L10, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::kernelPaddedEvenL10, this, l10, const78, mp_bnl9, 12, 12, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL10, batch norm
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::batchNormL10, this, bnl10, const22, const23, const79, l10, mp_bnl9, 12, 12, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L11, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::kernelPaddedEvenL11, this, l11, const80, bnl10, 12, 12, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL11, batch norm
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::batchNormL11, this, bnl11, const24, const25, const81, l11, bnl10, 12, 12, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L12, depthwise conv, kernel=3x3, stride=2, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::kernelPaddedEvenL12, this, l12, const82, bnl11, 6, 6, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // mp_bnL12, max pool + batch norm
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::maxPoolBatchNormL12, this, mp_bnl12, const26, const27, const83, bnl11, l12, 6, 6, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L13, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::kernelPaddedEvenL13, this, l13, const84, mp_bnl12, 6, 6, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL13, batch norm
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::batchNormL13, this, bnl13, const28, const29, const85, l13, mp_bnl12, 6, 6, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L14, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::kernelPaddedEvenL14, this, l14, const86, bnl13, 6, 6, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL14, batch norm
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::batchNormL14, this, bnl14, const30, const31, const87, l14, bnl13, 6, 6, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        //// From here the network splits into two outputs, mesh points and face flag
        
        //// Face flag output

        // L21, depthwise conv, kernel=3x3, stride=2, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::kernelPaddedEvenL21, this, l21, const100, bnl14, 3, 3, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // mp_bnL21, max pool + batch norm
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::maxPoolBatchNormL21, this, mp_bnl21, const34, const35, const117, bnl14, l21, 3, 3, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L22, kernel=1x1, stride=1, padding=vaid
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::kernelPaddedRightL22, this, l22, const39, const40, const108, mp_bnl21, 3, 3, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L23, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::kernelPaddedEvenL23, this, l23, const101, l22, 3, 3, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL23, batch norm
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::batchNormL23, this, bnl23, const46, const47, const105, l23, l22, 3, 3, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L24, kernel=3x3, stride=1, padding=valid
        for (uint k = 0; k < 1; k++) {
            thread t(&facemesh::kernelPaddedRightL24, this, l24, const103, const102, bnl23, 3, 3, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        cout << "isFace: " << l24[0] << endl;

        //// Mesh points output

        // L15, depthwise conv, kernel=3x3, stride=2, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::kernelPaddedEvenL15, this, l15, const88, bnl14, 3, 3, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // mp_bnL15, max pool + batch norm
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::maxPoolBatchNormL15, this, mp_bnl15, const32, const33, const89, bnl14, l15, 3, 3, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L16, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::kernelPaddedEvenL16, this, l16, const90, mp_bnl15, 3, 3, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL16, batch norm
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::batchNormL16, this, bnl16, const41, const43, const91, l16, mp_bnl15, 3, 3, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L17, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::kernelPaddedEvenL17, this, l17, const92, bnl16, 3, 3, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL17, batch norm
        for (uint k = 0; k < 128; k++) {
            thread t(&facemesh::batchNormL17, this, bnl17, const48, const49, const93, l17, bnl16, 3, 3, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L18, kernel=1x1, stride=1, padding=vaid
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::kernelPaddedRightL18, this, l18, const52, const53, const94, bnl17, 3, 3, k, 128);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L19, depthwise conv, kernel=3x3, stride=1, padding=even
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::kernelPaddedEvenL19, this, l19, const95, l18, 3, 3, k);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // bnL19, batch norm
        for (uint k = 0; k < 32; k++) {
            thread t(&facemesh::batchNormL19, this, bnl19, const7, const12, const96, l19, l18, 3, 3, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        // L20, kernel=3x3, stride=1, padding=valid
        for (uint k = 0; k < 1404; k++) {
            thread t(&facemesh::kernelPaddedRightL20, this, l20, const97, const98, bnl19, 3, 3, k, 32);
            threads.push_back(move(t));
        }
        for (auto& th : threads) th.join();
        threads.clear();

        cout << l20[5] << endl;
    }

    void drawPoints(Mat imgIn)
    {
        for (int i = 0; i < 468; i++)
        {
            float x = l20[i * 3];
            float y = l20[i * 3 + 1];
            float z = l20[i * 3 + 2];
            circle(imgIn, Point(x, y), 1, Scalar(255, 255, 255), 0.1, 8, 0);
        }
    }
};

int main()
{
    Mat img;
    img = imread("D:\\Storage\\Unity\\facemesh-python\\data\\face1.jpg");

    // opencv read stuff in BGR
    cvtColor(img, img, COLOR_BGR2RGB);
    //resize(img, img, Size(192, 192), 0.0, 0.0, INTER_AREA);
    img.convertTo(img, CV_32FC3);
    // normalize values
    img = img / 255.0;

    // use a 3d array cause fuck opencv mats
    float*** imgArray = (float***)facemesh::createArray(192, 192, 3, sizeof(float));
    for (int k = 0; k < 3; k++) {
        for (int i = 0; i < 192; i++) {
            for (int j = 0; j < 192; j++) {
                imgArray[i][j][k] = img.at<Vec3f>(i, j)[k];
            }
        }
    }

    //for (int k = 0; k < 3; k++) {
    //	for (int i = 0; i < 192; i++) {
    //		for (int j = 0; j < 192; j++) {
    //			if (k == 0) imgArray[i][j][k] = (i / 191.0f) * (j / 191.0f);
    //			else if (k == 1) imgArray[i][j][k] = ((191.0f - i) / 191.0f) * (j / 191.0f);
    //			else imgArray[i][j][k] = (i / 191.0f) * ((191.0f - j) / 191.0f);
    //		}
    //	}
    //}

    string PATH = "D:\\Storage\\Unity\\facemesh-python\\data\\facemeshUNITY.bytes";
    facemesh landmark = facemesh(PATH);
    landmark.forwardProp(imgArray);
    landmark.drawPoints(img);

    cvtColor(img, img, COLOR_RGB2BGR);
    imshow("Display window", img);
    waitKey(0); // Wait for a keystroke in the window

    facemesh::freeArray(192, 192, 3, imgArray);
    return 0;
}