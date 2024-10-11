#include <stdio.h>
#include <stdlib.h>
#include <GL/glut.h>

#define MAX_VERTICES 1000000
#define MAX_NORMALS  1000000
#define MAX_FACES    1000000

float vertices[MAX_VERTICES][3]; // 頂点
float normals[MAX_NORMALS][3];   // 法線
int faces[MAX_FACES][4];         // 各面は最大4つの頂点を含むと仮定
int face_normals[MAX_FACES];     // 各面に対応する法線のインデックス

int v_count = 0;
int n_count = 0;
int f_count = 0;

// .obj ファイルを読み込む関数
void LoadObj(const char* filepath) {
    FILE *fp = fopen(filepath, "r");
    if (fp == NULL) {
        printf("Failed to open file: %s\n", filepath);
        return;
    }

    char line[128];

    while (fgets(line, sizeof(line), fp)) {
        if (line[0] == 'v' && line[1] == ' ') {
            // 頂点データを読み込む
            sscanf(line, "v %f %f %f", &vertices[v_count][0], &vertices[v_count][1], &vertices[v_count][2]);
            v_count++;
        // } else if (line[0] == 'v' && line[1] == 'n') {
        //     // 法線データを読み込む
        //     sscanf(line, "vn %f %f %f", &normals[n_count][0], &normals[n_count][1], &normals[n_count][2]);
        //     n_count++;
        } else if (line[0] == 'f') {
            // 面データを読み込む（頂点と法線のインデックス）
            int v[3];
            int matched = sscanf(line, "f %d %d %d", &v[0], &v[1], &v[2]);
            faces[f_count][0] = v[0] - 1;
            faces[f_count][1] = v[1] - 1;
            faces[f_count][2] = v[2] - 1;
            f_count++;
        }
    }

    fclose(fp);
}

// データを表示する関数
void PrintObjData() {
    // 頂点データを表示
    printf("Vertices:\n");
    for (int i = 0; i < v_count; i++) {
        printf("v %f %f %f\n", vertices[i][0], vertices[i][1], vertices[i][2]);
    }

    // // 法線データを表示
    // printf("\nNormals:\n");
    // for (int i = 0; i < n_count; i++) {
    //     printf("vn %f %f %f\n", normals[i][0], normals[i][1], normals[i][2]);
    // }

    // 面データを表示
    printf("\nFaces:\n");
    for (int i = 0; i < f_count; i++) {
        printf("f ");
        for (int j = 0; j < 3; j++) {  // 各面は3頂点を持つ
            printf("%d", faces[i][j] + 1);
        }
        printf("\n");
    }
}

// モデルの描画
void drawOBJ() {
    // 各面を描画
    glBegin(GL_TRIANGLES);

    for (int i = 0; i < f_count; i++) {
        // // 法線を設定
        // glNormal3f(normals[face_normals[i]][0], normals[face_normals[i]][1], normals[face_normals[i]][2]);
        
        // 各頂点を描画
        for (int j = 0; j < 3; j++) {  // 各面は3頂点を持つ
            glVertex3f(vertices[faces[i][j]][0], vertices[faces[i][j]][1], vertices[faces[i][j]][2]);
        }
    }

    glEnd();
}

// 画面の初期化
void init() {
    glClearColor(0.0, 0.0, 0.0, 1.0);  // 背景色を黒に設定
    glEnable(GL_DEPTH_TEST);            // 深度テストを有効にする
}

// 描画関数
void display() {
    // 画面をクリア
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    gluLookAt(10.0, 10.0, 10.0,  // カメラの位置（より遠くに設定）
              0.0, 0.0, 0.0,  // カメラが見る位置
              0.0, 1.0, 0.0); // 上方向

    glScalef(10.0, 10.0, 10.0);  // モデルのスケールを大きくする



    drawOBJ();

    // バッファを入れ替える
    glFlush();
}

// ウィンドウのリサイズ処理
void reshape(int w, int h) {
    glViewport(0, 0, w, h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(45.0, (double)w / (double)h, 1.0, 100.0);  // 視野を設定
    glMatrixMode(GL_MODELVIEW);
}

int main(int argc, char** argv) {
    // GLUTを初期化
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(500, 500);
    glutCreateWindow("bunny.obj");

    // OBJファイルの読み込みとデータ表示
    LoadObj("bunny.obj");
    PrintObjData();  // 読み込んだデータを表示

    // 初期化とコールバック関数の設定
    init();
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);

    // GLUTメインループ
    glutMainLoop();
    return 0;
}
