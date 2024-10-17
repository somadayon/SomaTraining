const express = require('express');
const router = express.Router();
const path = require('path');
const connection = require(path.join(__dirname, '..', 'functions', 'db'));

router.post('/', function (req, res, next) {
  res.redirect('/');
});

module.exports = router;
