#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_VERTICES 100000
#define MAX_FACES    100000

float vertices[MAX_VERTICES][3]; // 頂点
int faces[MAX_FACES][3];         // 面 (3角形を想定)

int v_count = 0;
int f_count = 0;

// PLYファイルを読み込み、頂点と面を取得する関数
void LoadPly(const char* filepath) {
    FILE *fp = fopen(filepath, "r");
    if (fp == NULL) {
        printf("Failed to open file: %s\n", filepath);
        return;
    }

    char line[256];
    int reading_vertices = 0;
    int reading_faces = 0;

    while (fgets(line, sizeof(line), fp)) {
        // ヘッダーの解析
        if (strncmp(line, "end_header", 10) == 0) {
            reading_vertices = 1; // ヘッダー終了後、頂点データを読み込む
            continue;
        }

        // 頂点の読み込み
        float x, y, z, confidence, intensity;
        int num_vertices, v1, v2, v3;
        if (sscanf(line, "%f %f %f %f %f", &x, &y, &z, &confidence, &intensity) == 5) {
            vertices[v_count][0] = x;
            vertices[v_count][1] = y;
            vertices[v_count][2] = z;
            v_count++;
        } else
        if (sscanf(line, "%d %d %d %d", &num_vertices, &v1, &v2, &v3) == 4) {
            // 面の読み込み
            reading_vertices = 0;
            reading_faces = 1; // 頂点の後は面データを読み込む
        
            // 三角形の面のみ対応
            if (num_vertices == 3) {
                faces[f_count][0] = v1;
                faces[f_count][1] = v2;
                faces[f_count][2] = v3;
                f_count++;
            }
        }

    }

    fclose(fp);
}

// OBJファイルに書き出す関数
void WriteObj(const char* filepath) {
    FILE *fp = fopen(filepath, "w");
    if (fp == NULL) {
        printf("Failed to create file: %s\n", filepath);
        return;
    }

    // 頂点データの書き込み
    for (int i = 0; i < v_count; i++) {
        fprintf(fp, "v %f %f %f\n", vertices[i][0], vertices[i][1], vertices[i][2]);
    }

    // 面データの書き込み
    for (int i = 0; i < f_count; i++) {
        fprintf(fp, "f %d %d %d\n", faces[i][0] + 1, faces[i][1] + 1, faces[i][2] + 1);
    }

    fclose(fp);
}

int main() {
    // PLYファイルを読み込む
    LoadPly("bunny.ply");

    // 読み込んだデータをOBJファイルに書き出す
    WriteObj("bunny.obj");

    printf("Conversion completed. OBJ file generated.\n");

    return 0;
}
