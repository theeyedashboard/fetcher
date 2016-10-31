Fetcher = require('../../fetcher')
request = require('request')

# Return twitter follower from a given user
# Params:
# - user: Twitter username
class PersosWithoutSuffix extends Fetcher

  fetch: =>
    base_url = @params['base_url']
    request base_url, (error, response, body) =>
      results_count = body.split(/\r\n|\r|\n/).length - 1
      @return_value "#{results_count}"

module.exports = PersosWithoutSuffix
