const mysql = require('mysql');
const path = require('path');
const secretPassword = require(path.join(__dirname, '..', 'functions', 'secret'));

// MySQL の接続設定
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: secretPassword,
  database: 'WebApp',
  charset: 'utf8mb4'
});

module.exports = connection;
