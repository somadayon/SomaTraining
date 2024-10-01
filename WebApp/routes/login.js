const express = require('express');
const router = express.Router();
const path = require('path');
const connection = require(path.join(__dirname, '..', 'functions', 'db'));
const { encrypted, decrypted, getToken } = require(path.join(__dirname, '..', 'functions', 'trans'));

function renderLogin(res, errorMessage = [], Message = []) {
  res.render('login', {
    title: 'login',
    errorMessage: errorMessage,
    Message: Message
  });
}

router.get('/', function (req, res, next) {
  renderLogin(res); // renderLoginを使用
});

router.post('/', function (req, res, next) {
  const username = req.body.username;
  const password = req.body.password;
  
  connection.query(
    "SELECT * FROM users WHERE username = ?", 
    [username],
    (error, results) => {
      if (error) {
        console.error(error);
        return renderLogin(res, ["データの取得に失敗しました"]); // renderLoginを使用
      }
  
      // ユーザーが見つからない場合
      if (results.length === 0) {
        return renderLogin(res, ["ユーザーが見つかりません"]); // renderLoginを使用
      }
      
      // パスワードが一致しない場合
      if (decrypted(results[0].password) !== password) {
        console.log(decrypted(results[0].password));
        return renderLogin(res, ['ユーザ ー名またはパスワードが違います']); // renderLoginを使用
      }

      // トークン取得、登録
      const token = getToken();
      const nowDate = new Date();
      const time = (nowDate.getHours() * 60) + nowDate.getMinutes()
      req.session.token = token;
      connection.query(
        'UPDATE tokens SET token = ?, time = ? WHERE username = ?',
        [token, time, username],
        (error) => {
          if (error) {
            console.error('トークンの更新に失敗しました:', error);
            return renderLogin(res, ['トークンの更新に失敗しました']);
          }

          console.log(`${username} ログイン成功`);
          res.redirect('/');
        }
      );

    }
  );
});

module.exports = router;