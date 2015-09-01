url = require('url')

class Fetcher

  # init fetcher module
  constructor: (@app, @service, @source) ->
    @listen()

  # return path from service & source
  path: =>
    "/#{@service}/#{@source}"

  # listen on path, get params & call fetch func
  listen: =>
    @app.get @path(), (req, res) =>
      @res = res
      @params = url.parse(req.url, true).query
      @fetch()

  # to overide: called on http connection
  fetch: =>
    @return_value(@path() + " please overide fetch method - params: #{JSON.stringify @params}")

  # return a value synchronously after a connection
  return_value: (value) =>
    @res.send value if @res
    

module.exports = Fetcher
