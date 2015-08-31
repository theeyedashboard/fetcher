var express = require('express');
var app = express();

app.get('/', function (req, res) {
  console.log ('Nothing to display');
});

var server = app.listen(80, function () {
  console.log('Fetcher running on port 80');
});
