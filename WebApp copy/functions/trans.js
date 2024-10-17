const crypto = require('crypto-js');
const path = require('path');
const secretPassword = require(path.join(__dirname, '..', 'functions', 'secret'));

function encrypted(text) {
  return crypto.AES.encrypt(text, secretPassword).toString();
}

function decrypted(text) {
  const bytes = crypto.AES.decrypt(text, secretPassword);
  return bytes.toString(crypto.enc.Utf8);
}

function getToken() {
  date = new Date();
  return encrypted(date.getTime().toString());
}

module.exports = {
  encrypted,
  decrypted,
  getToken
};