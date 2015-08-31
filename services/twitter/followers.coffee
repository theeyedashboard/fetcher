Fetcher = require('../../fetcher')
request = require('request')
cheerio = require('cheerio')

# Return twitter follower from a given user
# Params:
# - user: Twitter username
class TwitterFollowers extends Fetcher

  fetch: =>
    username = @params['user']
    request "https://twitter.com/#{username}", (error, response, body) =>
      @return_value @get_followers_count(body)

  get_followers_count: (body) =>
    $ = cheerio.load(body)
    $('li.ProfileNav-item--followers > a > span.ProfileNav-value').text()

module.exports = TwitterFollowers
