#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <GL/glut.h>
#include "rot_qua/rot_qua.h"
#include "rot_qua/vec3.h"

#define MAX_VERTICES 1000000
#define MAX_NORMALS  1000000
#define MAX_FACES    1000000

double vertices[MAX_VERTICES][3]; // 頂点
double normals[MAX_NORMALS][3];   // 法線
int faces[MAX_FACES][3];          // 各面に対応する頂点のインデックス
int face_normals[MAX_FACES];      // 各面に対応する法線のインデックス

int v_count = 0; // 頂点の数
int n_count = 0; // 法線の数
int f_count = 0; // 面の数

// .obj ファイルを読み込む関数
void LoadObj(const char* filepath) {
    FILE *fp = fopen(filepath, "r");
    if (fp == NULL) {
        printf("Failed to open file: %s\n", filepath);
        return;
    }

    char line[5000];

    while (fgets(line, sizeof(line), fp)) {
        if (line[0] == 'v' && line[1] == ' ') {
            // 頂点データを読み込む
            sscanf(line, "v %lf %lf %lf", &vertices[v_count][0], &vertices[v_count][1], &vertices[v_count][2]);
            v_count++;
        } else if (line[0] == 'f') {
            // 面データを読み込む（頂点のインデックス）
            int v[3];
            sscanf(line, "f %d %d %d", &v[0], &v[1], &v[2]);
            faces[f_count][0] = v[0] - 1;  // インデックスは1から始まるため-1して格納
            faces[f_count][1] = v[1] - 1;
            faces[f_count][2] = v[2] - 1;
            f_count++;
        }
    }

    fclose(fp);
}

// 法線の計算
void Cal_vn(double *a, double *b, double *c, double *out) {
    double mid1[3], mid2[3];
    sub(a, b, mid1);
    sub(a, c, mid2);
    crs(mid2, mid1, out);

    // 正規化
    nrm(out, out);
}

// 法線データの追加
void Add_data() {
    n_count = f_count; // 面の数だけ法線データを作成
    for (int i = 0; i < f_count; i++) {
        Cal_vn(vertices[faces[i][0]], vertices[faces[i][1]], vertices[faces[i][2]], normals[i]);
        face_normals[i] = i;  // 法線のインデックスを設定
    }
}
    
// 法線を加えた .obj ファイルの作成
void Add_vn(const char* filepath) {
    FILE *fp = fopen(filepath, "w");

    // 頂点の記入
    for (int i = 0; i < v_count; i++) {
        fprintf(fp, "v ");
        for (int j = 0; j < 3; j++) {   
            fprintf(fp, "%f ", vertices[i][j]);
        }
        fprintf(fp, "\n");
    }
    
    // 法線の記入
    for (int i = 0; i < n_count; i++) {
        fprintf(fp, "vn ");
        for (int j = 0; j < 3; j++) {   
           fprintf(fp, "%f ", normals[i][j]);
        }
        fprintf(fp, "\n");
    }

    // 面の記入（法線インデックスも含む）
    for (int i = 0; i < f_count; i++) {
        fprintf(fp, "f ");
        for (int j = 0; j < 3; j++) {   
           fprintf(fp, "%d//%d ", faces[i][j] + 1, face_normals[i] + 1);
        }
        fprintf(fp, "\n");
    }
    
    // ファイルを閉じる
    fclose(fp);
}

int main(int argc, char** argv) {
    // OBJファイルの読み込みとデータ表示
    LoadObj("bunny.obj");
    Add_data();
    Add_vn("bunny_add_vn.obj");
}