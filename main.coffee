express         = require('express')
fs 							= require 'fs'
app             = express()

app.get '/', (req, res) =>
  console.log 'Nothing to display'

server = app.listen 80, =>
  console.log 'Fetcher running on port 80'

TwitterFollowers = require('./services/twitter/followers')
twitter = new TwitterFollowers(app, 'twitter', 'followers')
