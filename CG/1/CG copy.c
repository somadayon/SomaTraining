#include <GL/glut.h>

// 画面の初期化
void init() {
    glClearColor(0.0, 0.0, 0.0, 1.0); // 背景を黒に設定
}

// 描画関数
void display() {
    // 画面をクリア
    glClear(GL_COLOR_BUFFER_BIT);

    //  カメラの設定
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0, 0.0, 5.0,  // カメラの位置
              0.0, 0.0, 0.0,  // カメラが見る位置
              0.0, 1.0, 0.0); // 上方向

    // 黄色の正方形を描画
    glColor3f(1.0, 1.0, 0.0);  // 黄色
    glBegin(GL_QUADS);
        glVertex2f(-0.75, -0.75);  // 左下
        glVertex2f(0.75, -0.75);   // 右下
        glVertex2f(0.75, 0.75);    // 右上
        glVertex2f(-0.75, 0.75);   // 左上
    glEnd();

    // シアンの三角形を描画
    glColor3f(0.0, 1.0, 1.0);  // シアン
    glBegin(GL_TRIANGLES);
        glVertex2f(-0.5, -0.5);  // 左下
        glVertex2f(0.5, -0.5);   // 右下
        glVertex2f(0.0, 0.5);    // 上
    glEnd();

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
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
    glutInitWindowSize(500, 500);
    glutCreateWindow("OpenGL: Cyan triangle and yellow square");

    // 描画とリサイズのコールバックを設定
    init();
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);

    // GLUTメインループ
    glutMainLoop();
    return 0;
}
