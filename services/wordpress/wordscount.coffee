Fetcher = require('../../fetcher')
request = require('request')
cheerio = require('cheerio')

# Return wordcount for a wordpress blog
# Params:
# - site: Wordpress blog url
class WordpressWordscount extends Fetcher

  fetch: =>
    site = @params['site']
    request "#{site}/sitemap.xml", (error, response, body) =>
      @return_value body

module.exports = WordpressWordscount
