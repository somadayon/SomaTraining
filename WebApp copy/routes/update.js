const express = require('express');
const router = express.Router();
const path = require('path');
const connection = require(path.join(__dirname, '..', 'functions', 'db'));
const { encrypted, decrypted, getToken } = require(path.join(__dirname, '..', 'functions', 'trans'));

let username;
let todos;
let isAuth = false;

// データ送信用
function renderIndex(res, errorMessage = [], Message = [], update_task) {
  res.render('index', {
    title: 'WebApp',
    username: username,
    todos: todos,
    isAuth: isAuth,
    errorMessage: errorMessage,
    Message: Message,
    update: update_task,
    form: '修正',
    behave: '送信'
  });
}

// タスク取得用
function getTask() {
  return new Promise((resolve, reject) => {
    connection.query(
      `SELECT * 
      FROM tasks 
      WHERE ena = TRUE
      ORDER BY CASE WHEN username = ? THEN 0 ELSE 1 END, 
                     date ASC, 
                     username ASC, 
                     start_time ASC`,
      [username],
      (error, results) => {
        if (error) {
          console.error(error);
          return reject('データの取得に失敗しました'); // エラーメッセージを返す
        }
        todos = results;
        resolve(); // 成功
      }
    );
  });
}

router.post('/', async function (req, res, next) {
  const taskId = req.body.id;
  const nowDate = new Date(); // 現在日時の取得、日付比較用

  // トークンの認証, usernameの取得
  try {
    const token = req.session.token;
    if (!token) {
      renderIndex(res, ['トークンが存在しません']);
      return;
    }
    connection.query(
      `SELECT username, time FROM tokens WHERE token = ?`,
      [token],
      (error, results) => {
        if (results.length > 0) {
          username = results[0].username;
          const tokenTime = results[0].time;
          const time = (nowDate.getHours() * 60) + nowDate.getMinutes()
          console.log(time)
          if(time - tokenTime < 10) isAuth = true;
        }
      }
    );
    
  } catch (error) {
    console.error('トークンの認証に失敗しました:', error);
    isAuth = false;
  }
  

  try {
    // タスクを取得してからデータ送信
    await getTask();
    // タスクの更新クエリ
    connection.query(
      `SELECT * FROM tasks WHERE id = ?`,
      [taskId],
      async (error, results) => {
        const task = results[0];  // 取得したタスク情報  
        req.session.taskid = task.id;
        console.log(task);

        if (error) {
          console.error(error);
          return renderIndex(res, ['データの取得に失敗しました']);
        }
        if( req.session.userid === task.user_id ){
          // 一覧を再取得
          await getTask(res);
          renderIndex(res, [], ['修正内容を入力してください'], task); // 正常な場合の表示
        } else {
          res.redirect('/');
        }
      }
    );
  } catch (errorMessage) {
    renderIndex(res, [errorMessage]);
  }
});

module.exports = router;
