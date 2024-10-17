#include <GL/glut.h>

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
    gluLookAt(2.0, 2.0, 2.0,  // カメラの位置（右斜め上）
              0.0, 0.0, 0.0,  // カメラが見る位置
              0.0, 1.0, 0.0); // 上方向

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
