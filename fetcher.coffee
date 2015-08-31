url = require('url')

class Fetcher

  constructor: (@app, @service, @source) ->
    @listen()

  path: =>
    "/#{@service}/#{@source}"

  listen: =>
    @app.get @path(), (req, res) =>
      @res = res
      @params = url.parse(req.url, true).query
      @fetch()

  fetch: =>
    @return_value(@path() + " please overide fetch method - params: #{JSON.stringify @params}")

  return_value: (value) =>
    @res.send value if @res

module.exports = Fetcher
