const express = require('express');
const router = express.Router();
const path = require('path');
const connection = require(path.join(__dirname, '..', 'functions', 'db'));
const { encrypted, decrypted, getToken } = require(path.join(__dirname, '..', 'functions', 'trans'));

const commentLimit = 50; // コメント文字数制限

let todos = [];
let isAuth = false;
let username;

// データ送信用
function renderIndex(res, errorMessage = [], Message = []) {
  res.render('index', {
    title: 'WebApp',
    username: username,
    todos: todos,
    isAuth: isAuth,
    errorMessage: errorMessage,
    Message: Message,
    update: [],
    form: '投稿',
    behave: '追加'
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


router.get('/', async function (req, res, next) {
  const nowDate = new Date(); // 現在日時の取得、日付比較用

  // トークンの認証, usernameの取得
  try {
    const token = req.session.token;
    if (!token) {
      isAuth = false;
      return renderIndex(res, []);
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
    renderIndex(res);
  } catch (errorMessage) {
    renderIndex(res, [errorMessage]);
  }
});


router.post('/', async function (req, res, next) {
  const nowDate = new Date(); // 現在日時の取得、日付比較用

  // トークンの認証, usernameの取得
  try {
    const token = req.session.token;
    if (!token) {
      isAuth = false;
      return renderIndex(res, []);
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


  const { time0, time1, comment, date: getDate } = req.body; // ejsからのデータ取得
  
  // Date オブジェクトの修正
  const [year, month, day] = getDate.split('-');
  const date = new Date(year, month - 1, day); // 月は 0 ベースなので -1 する、日付比較用
  const formattedDate = `${year}-${month}-${day}`;
  
  // time オブジェクトの修正
  const [hour0, min0, sec0] = time0.split(':');
  const formattedTime0 = `${hour0}:${min0}`;
  const [hour1, min1, sec1] = time1.split(':');
  const formattedTime1 = `${hour1}:${min1}`;

  try {
    // タスクを取得
    await getTask();

    // エラーメッセージの作成
    getTask((errorMessage) => { if (errorMessage) return renderIndex(res, errorMessage);});

    let errorMessages = [];
    if (nowDate > date) {
      errorMessages.push('年月日が無効です');
    }
    if (time0 > time1) {
      errorMessages.push('出社時刻または退社時刻が無効です');
    }
    if (comment.length > commentLimit) {
      errorMessages.push(`コメントは${commentLimit}文字までです`);
    }
    
    // エラーメッセージの表示
    if (errorMessages.length > 0) {
      return renderIndex(res, errorMessages);
    }

    let Messages = [];

    // 修正用, タスクの非表示クエリ
    await new Promise((resolve, reject) => {
      connection.query(
        `UPDATE tasks SET ena = FALSE WHERE id = ?`,
        [req.session.taskid],
        (error) => {
          if (error) {
            console.error(error);
            return reject('タスクの更新に失敗しました');
          }
          Messages = ['タスクを更新しました'];
          resolve();
        }
      );
    });

    // タスクの重複チェック
    await new Promise((resolve, reject) => {
      connection.query(
        'SELECT id FROM tasks WHERE username = ? AND date = ? AND ena = TRUE',
        [username, formattedDate],
        (error, results) => {
          if (error) {
            console.error(error);
            return reject('データの挿入に失敗しました');
          }
          if (results.length > 0) {
            connection.query(
              `UPDATE tasks SET ena = FALSE WHERE id = ?`,
              [results[0].id],
              (error) => {
                if (error) {
                  console.error(error);
                  return reject('データの挿入に失敗しました');
                }
                Messages = ['タスクを更新しました'];
                resolve();
              }
            );
          } else {
            resolve();
          }
        }
      );
    });

    // タスクの挿入
    await new Promise((resolve, reject) => {
      connection.query(
        'INSERT INTO tasks (username, date, start_time, end_time, comment) VALUES (?, ?, ?, ?, ?)',
        [username, formattedDate, formattedTime0, formattedTime1, comment],
        (error) => {
          if (error) {
            console.error(error);
            return reject('データの挿入に失敗しました');
          }
          resolve();
        }
      );
    });

    // タスクを更新
    await getTask();

    // 正常な場合の表示
    renderIndex(res, [], Messages);     

  } catch (errorMessage) {
    renderIndex(res, [errorMessage]);
  }
});

router.use('/signup', require('./signup'));
router.use('/login', require('./login'));
router.use('/logout', require('./logout'));
router.use('/update', require('./update'));
router.use('/hide', require('./hide'));
router.use('/cancel', require('./cancel'));

module.exports = router;