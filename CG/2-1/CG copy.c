#include <GL/glut.h>

// 画面の初期化
void init() {
    glClearColor(0.0, 0.0, 0.0, 1.0);  // 背景色を黒に設定
    glEnable(GL_DEPTH_TEST);            // 深度テストを有効にする
}

// 立方体の描画
void drawCube() {
    // 立方体の各面を描画
    glBegin(GL_QUADS);

    // 前面（青）
    glColor3f(0.0, 0.0, 1.0);  // 青
    glVertex3f(-0.5, -0.5,  0.5);
    glVertex3f( 0.5, -0.5,  0.5);
    glVertex3f( 0.5,  0.5,  0.5);
    glVertex3f(-0.5,  0.5,  0.5);

    // 背面（赤）
    glColor3f(1.0, 0.0, 0.0);  // 赤
    glVertex3f(-0.5, -0.5, -0.5);
    glVertex3f( 0.5, -0.5, -0.5);
    glVertex3f( 0.5,  0.5, -0.5);
    glVertex3f(-0.5,  0.5, -0.5);

    // 左面（緑）
    glColor3f(0.0, 1.0, 0.0);  // 緑
    glVertex3f(-0.5, -0.5, -0.5);
    glVertex3f(-0.5, -0.5,  0.5);
    glVertex3f(-0.5,  0.5,  0.5);
    glVertex3f(-0.5,  0.5, -0.5);

    // 右面（紫）
    glColor3f(1.0, 0.0, 1.0);  // 紫
    glVertex3f( 0.5, -0.5, -0.5);
    glVertex3f( 0.5, -0.5,  0.5);
    glVertex3f( 0.5,  0.5,  0.5);
    glVertex3f( 0.5,  0.5, -0.5);

    // 上面（黄）
    glColor3f(1.0, 1.0, 0.0);  // 黄
    glVertex3f(-0.5,  0.5, -0.5);
    glVertex3f( 0.5,  0.5, -0.5);
    glVertex3f( 0.5,  0.5,  0.5);
    glVertex3f(-0.5,  0.5,  0.5);

    // 下面（シアン）
    glColor3f(0.0, 1.0, 1.0);  // シアン
    glVertex3f(-0.5, -0.5, -0.5);
    glVertex3f( 0.5, -0.5, -0.5);
    glVertex3f( 0.5, -0.5,  0.5);
    glVertex3f(-0.5, -0.5,  0.5);

    glEnd();
}

// 描画関数
void display() {
    // 画面をクリア
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //  カメラの設定
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(2.0, 2.0, 2.0,  // カメラの位置（右斜め上）
              0.0, 0.0, 0.0,  // カメラが見る位置
              0.0, 1.0, 0.0); // 上方向

    // 立方体の回転を設定
    glRotatef(30, 1.0, 1.0, 0.0);

    // 立方体を描画
    drawCube();

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
    glutCreateWindow("3D Cube: Right Above Camera Angle");

    // 初期化とコールバック関数の設定
    init();
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);

    // GLUTメインループ
    glutMainLoop();
    return 0;
}
