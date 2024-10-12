const express = require('express');
const router = express.Router();
const path = require('path');
const connection = require(path.join(__dirname, '..', 'functions', 'db'));
const { encrypted, decrypted, getToken } = require(path.join(__dirname, '..', 'functions', 'trans'));

const usernameLimit = 30; //ユーザー名文字数上限
const passwordLimit = 20; //パスワード文字数上限

function renderSignup(res, errorMessage = []) {
  res.render('signup', {
    title: 'Sign up',
    errorMessage: errorMessage
  });
}

//文字列が小文字か確認
const isLowerCase = str => /^[0-9a-z]+$/.test(str);

router.get('/', function (req, res, next) {
  renderSignup(res);
});

router.post('/', async function (req, res, next) {
  const { username, password, repassword } = req.body;

  // ユーザー名文字数確認
  if (username.length > usernameLimit) {
    return renderSignup(res, [`ユーザー名は${usernameLimit}文字までです`]);
  }

  // ユーザー名文字型確認
  if (!isLowerCase(username)) {
    return renderSignup(res, [`ユーザー名は小文字のみにしてください`]);
  }
  
  // パスワード文字数確認
  if (password.length > passwordLimit) {
    return renderSignup(res, [`パスワードは${passwordLimit}文字までです`]);
  }

  // パスワード文字型確認
  if (!isLowerCase(password)) {
    return renderSignup(res, [`パスワードは小文字のみにしてください`]);
  }
  
  // パスワード一致確認
  if (password !== repassword) {
    return renderSignup(res, ['パスワードが一致しません']);
  }

  // ユーザー名の重複確認
  connection.query(
    "SELECT * FROM users WHERE username = ?",
    [username],
    (error, results) => {
      if (error) {
        console.error(error);
        return renderSignup(res, ['データの取得に失敗しました']);
      }

      if (results.length > 0) { // ユーザーが既に存在する場合
        console.log(results);
        return renderSignup(res, ['このユーザー名は既に使われています']);
      }

      try {
        // 新規ユーザーの登録
        const encryptedPassword = encrypted(password);
        connection.query(
          'INSERT INTO users (username, password) VALUES (?, ?)',
          [username, encryptedPassword]
        );
    
        // トークン取得、登録
        const token = getToken();
        const nowDate = new Date();
        const time = (nowDate.getHours() * 60) + nowDate.getMinutes()
        req.session.token = token;
        connection.query(
          'INSERT INTO tokens (username, token, time) VALUES (?, ?, ?)',
          [username, token, time]
        );
        console.log(username);
    
        // ホームページにリダイレクト
        res.redirect('/');
      } catch (error) {
        console.error(error);
        renderSignup(res, ['データの処理に失敗しました']);
      }
    }
  );
});

module.exports = router;
