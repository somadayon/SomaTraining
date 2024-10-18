    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <GL/glut.h>
    #include "rot_qua/rot_qua.h"
    #include "rot_qua/vec3.h"

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

double eye[3] = {0.2, 0.2, 0.2};
double pov[3] = {0.0, 0.0, 0.0};
double up[3]  = {0.0, 1.0, 0.0};
double fovh = 45.0;
double fovv = 45.0;
int bgn[2];
int drag_mode = 0;

// ベクトル計算用 
double viw[3];
double mid[3];
double zom[3];
double right[3];
double out[3];
double axis[3];
double move_right[3], move_up[3];

// .obj ファイルを読み込む関数
void LoadObj(const char* filepath) {
    FILE *fp = fopen(filepath, "r");
    if (fp == NULL) {
        printf("Failed to open file: %s\n", filepath);
        return;
    }

    char line[1000000];

    while (fgets(line, sizeof(line), fp)) {
        if (line[0] == 'v' && line[1] == ' ') {
            // 頂点データを読み込む
            sscanf(line, "v %f %f %f", &vertices[v_count][0], &vertices[v_count][1], &vertices[v_count][2]);
            v_count++;
        } else if (line[0] == 'v' && line[1] == 'n') {
            // 法線データを読み込む
            sscanf(line, "vn %f %f %f", &normals[n_count][0], &normals[n_count][1], &normals[n_count][2]);
            n_count++;
        } else if (line[0] == 'f') {
            // 面データを読み込む（頂点と法線のインデックス）
            int v[3], vn;
            int matched = sscanf(line, "f %d//%d %d//%d %d//%d", &v[0], &vn, &v[1], &vn, &v[2], &vn);
            faces[f_count][0] = v[0] - 1;
            faces[f_count][1] = v[1] - 1;
            faces[f_count][2] = v[2] - 1;
            face_normals[f_count] = vn - 1;  // 法線インデックス
            f_count++;
        }
    }

    fclose(fp);
}

// モデルの描画
void drawOBJ() {
    // 各面を描画
    glBegin(GL_TRIANGLES);

    for (int i = 0; i < f_count; i++) {
        // 法線を設定
        glNormal3f(normals[face_normals[i]][0], normals[face_normals[i]][1], normals[face_normals[i]][2]);
        
        // 各頂点を描画
        for (int j = 0; j < 3; j++) {  // 各面は3頂点を持つ
            glVertex3f(vertices[faces[i][j]][0], vertices[faces[i][j]][1], vertices[faces[i][j]][2]);
        }
    }

    glEnd();
}

// 照明の設定
void setupLighting() {
    GLfloat light_position[] = {1.0, 1.0, 1.0, 0.0};  // 光源の位置
    GLfloat light_diffuse[]  = {0.8, 0.8, 0.8, 1.0};  // 拡散光の強度
    GLfloat light_specular[] = {1.0, 1.0, 1.0, 1.0};  // 鏡面光の強度
    GLfloat light_ambient[]  = {0.2, 0.2, 0.2, 1.0};  // 環境光の強度

    // 光源を設定
    glLightfv(GL_LIGHT0, GL_POSITION, light_position);
    glLightfv(GL_LIGHT0, GL_DIFFUSE,  light_diffuse);
    glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
    glLightfv(GL_LIGHT0, GL_AMBIENT,  light_ambient);

    glEnable(GL_LIGHT0);   // ライト0を有効にする
    glEnable(GL_LIGHTING); // 照明を有効にする
}

// 材質の設定
void setupMaterial() {
    GLfloat mat_specular[] = {1.0, 1.0, 1.0, 1.0};  // 鏡面反射成分
    GLfloat mat_diffuse[]  = {0.6, 0.6, 0.6, 1.0};  // 拡散反射成分
    GLfloat mat_ambient[]  = {0.3, 0.3, 0.3, 1.0};  // 環境光反射成分
    GLfloat mat_shininess[] = {50.0};               // 光沢度

    // 材質を設定
    glMaterialfv(GL_FRONT, GL_SPECULAR,  mat_specular);
    glMaterialfv(GL_FRONT, GL_DIFFUSE,   mat_diffuse);
    glMaterialfv(GL_FRONT, GL_AMBIENT,   mat_ambient);
    glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess);
}

// 画面の初期化
void init() {
    glClearColor(0.0, 0.0, 0.0, 1.0);  // 背景色を黒に設定
    glEnable(GL_DEPTH_TEST);            // 深度テストを有効にする
    setupLighting();                    // 照明の設定を有効化
    setupMaterial();                    // 材質の設定を有効化
    glShadeModel(GL_SMOOTH);            // スムースシェーディングを有効にする
}

// 描画関数
void display() {
    // 画面をクリア
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // カメラの設定
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(eye[0], eye[1], eye[2],  // カメラの位置
              pov[0], pov[1], pov[2],  // カメラが見る位置
               up[0],  up[1],  up[2]); // 上方向

    drawOBJ();

    // バッファを入れ替える
    glFlush();
}

// マウスイベント処理
void mouse(int button, int state, int x, int y) {
    if(state == GLUT_DOWN) {
        // ボタン押下時に開始位置を保存
        bgn[0] = x;
        bgn[1] = y;

        if(button == GLUT_LEFT_BUTTON) {
            drag_mode = 1;  // 平行移動
        } else if(button == GLUT_MIDDLE_BUTTON) {
            drag_mode = 2;  // ズーム
        } else if(button == GLUT_RIGHT_BUTTON) {
            drag_mode = 3;  // 回転
        }
    } else if(state == GLUT_UP) {
        drag_mode = 0;  // ドラッグモードをリセット
    }
}

// マウスのドラッグに応じた操作
void motion(int x, int y) {
    if(!drag_mode) return;

    double dx = (x - bgn[0]);
    double dy = (y - bgn[1]);

    if(drag_mode == 1) {
        // 平行移動
        double scl = 0.001;  
        double drg[3] = {dx * scl, dy * scl, 0};

        // 視線ベクトル（eye - pov）を計算し、視線ベクトルを計算
        sub(eye, pov, viw);
        crs(viw, up , move_right);  // 視線ベクトルと上方向ベクトルの外積で右方向ベクトルを計算
        crs(viw, move_right, move_up);
        nrm(move_right, move_right);
        nrm(move_up, move_up);

        // 水平方向の平行移動
        mul(drg[0], move_right,  move_right);  // 右方向に移動
        mul(-drg[1], move_up,  move_up);     // 上方向に移動

        // カメラ位置と注視点を移動
        add(eye, move_right, eye);
        add(eye, move_up, eye);
        add(pov, move_right, pov);
        add(pov, move_up, pov);

    } else if(drag_mode == 2) {
        // ズーム操作
        double scl = dy * 0.01;  // Y方向の変位をズーム量に変換
        sub(pov, eye, viw);
        nrm(viw, mid);  // 正規化
        mul(-scl, mid, zom);  // ズーム量に応じて視線ベクトルをスケーリング

        // カメラ位置を更新
        add(eye, zom, eye);

    } else if(drag_mode == 3) {
        // 回転操作
        double scl = 0.001 * 2 * M_PI;  
        double drg[3] = {dx * scl, dy * scl, 0};

        sub(eye, pov, viw);        // 視線ベクトルviw（eye - pov）を計算
        
        // 視線ベクトルと上方向ベクトルの外積で右方向ベクトルを計算
        crs(viw, up, move_right);    
        crs(viw, move_right, move_up);  // 視線ベクトルと右方向ベクトルの外積で上方向ベクトルを計算
        
        nrm(move_right, move_right);      //正規化
        nrm(move_up, move_up);  //正規化

        // 垂直方向の回転
        if(dx) rot(eye, move_up, pov, dx * scl, eye); // カメラ位置を更新
        if(dy) rot(eye, move_right, pov, dy * scl, eye);   // カメラ位置を更新

        sub(pov, eye, viw);        // 視線ベクトルviw（pov - eye）を計算
        crs(viw, move_right, up);    
    }

    // マウス位置を更新
    bgn[0] = x;
    bgn[1] = y;

    // 画面を再描画
    glutPostRedisplay();
}

// ウィンドウのリサイズ処理
void reshape(int w, int h) {
    glViewport(0, 0, w, h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(45.0, (double)w / (double)h, 0.1, 100.0);  // 視野を設定
    glMatrixMode(GL_MODELVIEW);
}

int main(int argc, char** argv) {
    // GLUTを初期化
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(500, 500);
    glutCreateWindow("bunny.obj");

    // OBJファイルの読み込みとデータ表示
    LoadObj("bunny_add_vn.obj");
    
    // 初期化とコールバック関数の設定
    init();
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);
    glutMouseFunc(mouse);
    glutMotionFunc(motion);

    // GLUTメインループ
    glutMainLoop();
    return 0;
}
