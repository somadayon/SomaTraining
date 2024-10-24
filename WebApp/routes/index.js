const express = require('express');
const router = express.Router();
const path = require('path');
const connection = require(path.join(__dirname, '..', 'functions', 'db'));
const { encrypted, decrypted, getToken } = require(path.join(__dirname, '..', 'functions', 'trans'));

const commentLimit = 50; // コメント文字数の制限

let todos = [];  // タスク一覧を格納する配列
let isAuth = false;  // 認証状態のフラグ
let username;  // ユーザー名

// データをクライアントに送信するための関数
function renderIndex(res, errorMessage = [], Message = []) {
  res.render('index', {
    title: 'WebApp',           // ページタイトル
    username: username,        // ユーザー名
    todos: todos,              // タスク一覧
    isAuth: isAuth,            // 認証状態
    errorMessage: errorMessage, // エラーメッセージ
    Message: Message,          // メッセージ
    update: [],                // 更新用データ
    form: '投稿',              // フォームのタイトル
    behave: '追加'             // ボタンのラベル
  });
}

// タスクを取得するための関数
function getTask(callback) {
  connection.query(
    `SELECT * 
    FROM tasks 
    WHERE ena = TRUE
    ORDER BY date ASC, 
             CASE WHEN username = ? THEN 0 ELSE 1 END, 
             username ASC, 
             start_time ASC`,
    [username],
    (error, results) => {
      if (error) {
        console.error(error);
        return callback('データの取得に失敗しました'); // エラーメッセージを返す
      }
      todos = results;  // タスク一覧を更新
      callback(null);   // 正常に完了
    }
  );
}

// 時刻が有効かどうかをチェックする関数
function isValidTime(time) {
  if (time === "99:99") return true;
  else {
    const timePattern = /^([01]\d|2[0-3]):([0-5]\d)$/;  // 正規表現で時刻をチェック
    return timePattern.test(time);
  }
}


// GETリクエストに対する処理
router.get('/', function (req, res, next) {
  const nowDate = new Date(); // 現在日時を取得

  // トークン認証とusernameの取得
  const token = req.session.token;
  if (!token) {
    isAuth = false;
    return renderIndex(res, []);  // 認証されていない場合、空のページをレンダリング
  }

  connection.query(
    `SELECT username, time FROM tokens WHERE token = ?`,
    [token],
    (error, results) => {
      if (results.length > 0) {
        username = results[0].username;
        const tokenTime = results[0].time;
        const time = (nowDate.getHours() * 60) + nowDate.getMinutes();  // 現在時刻を分に変換
        if (time - tokenTime < 10) isAuth = true;  // トークンが有効か確認
      }
      getTask((errorMessage) => {
        if (errorMessage) {
          renderIndex(res, [errorMessage]);  // エラーがあればエラーメッセージを表示
        } else {
          renderIndex(res);  // 正常ならデータを表示
        }
      });
    }
  );
});


// POSTリクエストに対する処理
router.post('/', function (req, res, next) {
  const nowDate = new Date(); // 現在日時を取得

  // トークン認証とusernameの取得
  const token = req.session.token;
  if (!token) {
    isAuth = false;
    return renderIndex(res, []);  // 認証されていない場合、空のページをレンダリング
  }

  connection.query(
    `SELECT username, time FROM tokens WHERE token = ?`,
    [token],
    (error, results) => {
      if (results.length > 0) {
        username = results[0].username;
        const tokenTime = results[0].time;
        const time = (nowDate.getHours() * 60) + nowDate.getMinutes();  // 現在時刻を分に変換
        if (time - tokenTime < 10) isAuth = true;  // トークンが有効か確認
      }

      // POSTデータから時間やコメント、日付を取得
      const { time0, time1, comment, date: getDate } = req.body; 
      const [year, month, day] = getDate.split('-');
      const date = new Date(year, month - 1, day);  // 日付を修正して変換
      const formattedDate = `${year}-${month}-${day}`;
      const [hour0, min0] = time0.split(':');
      const formattedTime0 = `${hour0}:${min0}`;
      const [hour1, min1] = time1.split(':');
      const formattedTime1 = `${hour1}:${min1}`;

      // タスクの取得
      getTask((errorMessage) => {
        if (errorMessage) return renderIndex(res, [errorMessage]);  // エラー処理

        let errorMessages = [];
        // if (nowDate > date) {
        //   errorMessages.push('年月日が無効です');  // 日付が過去の場合
        // }
        if (!isValidTime(time0) || !isValidTime(time1) || time0 > time1) {
          errorMessages.push('出社時刻または退社時刻が無効です');  // 時刻が無効の場合
        }
        if (comment.length > commentLimit) {
          errorMessages.push(`コメントは${commentLimit}文字までです`);  // コメントが長すぎる場合
        }

        // エラーメッセージがあれば表示
        if (errorMessages.length > 0) {
          return renderIndex(res, errorMessages);
        }

        // タスクの非表示クエリ（更新処理）
        connection.query(
          `UPDATE tasks SET ena = FALSE WHERE id = ?`,
          [req.session.taskid],
          (error) => {
            if (error) {
              console.error(error);
              return renderIndex(res, ['タスクの更新に失敗しました']);  // エラー時のメッセージ
            }

            // タスクの重複チェック
            connection.query(
              'SELECT id FROM tasks WHERE username = ? AND date = ? AND ena = TRUE',
              [username, formattedDate],
              (error, results) => {
                if (error) {
                  console.error(error);
                  return renderIndex(res, ['データの挿入に失敗しました']);  // エラー処理
                }
                if (results.length > 0) {
                  connection.query(
                    `UPDATE tasks SET ena = FALSE WHERE id = ?`,
                    [results[0].id],
                    (error) => {
                      if (error) {
                        console.error(error);
                        return renderIndex(res, ['データの挿入に失敗しました']);  // エラー処理
                      }
                    }
                  );
                }

                // タスクの挿入処理
                connection.query(
                  'INSERT INTO tasks (username, date, start_time, end_time, comment) VALUES (?, ?, ?, ?, ?)',
                  [username, formattedDate, formattedTime0, formattedTime1, comment],
                  (error) => {
                    if (error) {
                      console.error(error);
                      return renderIndex(res, ['データの挿入に失敗しました']);  // エラー処理
                    }
                    getTask((errorMessage) => {
                      if (errorMessage) {
                        renderIndex(res, [errorMessage]);  // エラー時
                      } else {
                        renderIndex(res, [], ['タスクを更新しました']);  // 正常時
                      }
                    });

                    // タスクを更新後にリダイレクト
                    res.redirect('/');
                  }
                );
              }
            );
          }
        );
      });
    }
  );
});

// ルートハンドラの登録
router.use('/signup', require('./signup'));
router.use('/login', require('./login'));
router.use('/logout', require('./logout'));
router.use('/update', require('./update'));
router.use('/hide', require('./hide'));
router.use('/cancel', require('./cancel'));

module.exports = router;
