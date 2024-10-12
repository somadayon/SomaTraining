#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <GL/glut.h>
#include "rot_qua/rot_qua.h"
#include "rot_qua/vec3.h"

double eye[3] = {2.0, 2.0, 2.0};
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

// 画面の初期化
void init() {
    glClearColor(0.0, 0.0, 0.0, 1.0);  // 背景色を黒に設定
    glEnable(GL_DEPTH_TEST);            // 深度テストを有効にする
}

// 描画関数
void display() {
    // 画面をクリア
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //  カメラの設定
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(eye[0], eye[1], eye[2],  // カメラの位置
              pov[0], pov[1], pov[2],  // カメラが見る位置
              up[0] , up[1] , up[2] ); // 上方向

    glColor3f(1.0, 0.5, 0.0);  // オレンジ色でティーポットを描画
    glutSolidTeapot(0.5);      // ソリッドなティーポットをサイズ1.0で描画

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
        double scl = 0.01;  
        double drg[3] = {dx * scl, dy * scl, 0};

        // 視線ベクトル（eye - pov）を計算し、視線ベクトルを計算
        double move_right[3], move_up[3];
        sub(eye, pov, viw);
        crs(viw, up , right);  // 視線ベクトルと上方向ベクトルの外積で右方向ベクトルを計算
        crs(viw, right, move_up);
        nrm(right, right);
        nrm(move_up, move_up);

        // 水平方向の平行移動
        mul(drg[0], right,  move_right);  // 右方向に移動
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
        // if(len(viw) > len(zom))
        add(eye, zom, eye);

    } else if(drag_mode == 3) {
        // 回転操作
        double scl = 0.001 * 2 * M_PI;  
        double drg[3] = {dx * scl, dy * scl, 0};

        // 視線ベクトルviw（eye - pov）を計算し、右方向ベクトルを計算
        sub(eye, pov, viw);
        crs(viw, up, right);  // 視線ベクトルと上方向ベクトルの外積で右方向ベクトルを計算
        crs(viw, right, move_up);  // 視線ベクトルと上方向ベクトルの外積で右方向ベクトルを計算
        
        nrm(right, right);
        nrm(move_up, move_up);

        // 垂直方向の回転
        if(dx) rot(eye, move_up, pov, dx * scl, eye); // カメラ位置を更新
        if(dy) rot(eye, right, pov, dy * scl, eye); // カメラ位置を更新
        
    }

    // マウス位置を更新
    bgn[0] = x;
    bgn[1] = y;

    // 画面を再描画
    glutPostRedisplay();
}

int main(int argc, char** argv) {
    // GLUTを初期化
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(500, 500);
    glutCreateWindow("Mouse Control");

    // 初期化とコールバック関数の設定
    init();
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);
    glutMouseFunc(mouse);
    glutMotionFunc(motion);

    // GLUTメインループ
    glutMainLoop();
}