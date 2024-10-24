const express = require('express');
const router = express.Router();
const path = require('path');
const connection = require(path.join(__dirname, '..', 'functions', 'db'));

router.post('/', function (req, res, next) {
  // トークン認証とusernameの取得
  const token = req.session.token;
  if (!token) {
    isAuth = false;
    return renderIndex(res, []);  // 認証されていない場合、空のページをレンダリング
  }
  const taskId = req.body.id; // id をリクエストボディから取得

  // taskId が取得できなかった場合、リダイレクト
  if (!taskId) {
    return res.redirect('/'); // 取得できなかった場合にリダイレクト
  }
  
  connection.query(
    `SELECT id 
    FROM tasks 
    WHERE id = ?`,
    [taskId],
    (error, results) => {
      const task = results[0];  // 取得したタスク情報  
      console.log(task);

      if (error) {
        console.error(error);
      }
      
      if( req.session.username === task.username ){
        // タスクの非表示クエリ
        connection.query(
          `UPDATE tasks 
          SET ena = FALSE 
          WHERE id = ?`,
          [taskId],
          (error) => {
            if (error) {
              console.error(error);
            }
            res.redirect('/'); // 更新後にリダイレクト
          }
        );
      }
    }
  )
});

module.exports = router;
