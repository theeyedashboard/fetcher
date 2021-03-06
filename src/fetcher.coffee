url       = require('url')
fs        = require 'fs'
express   = require('express')
app       = express()

class Fetcher

  @plugins = []

  # init fetcher module
  constructor: (@app, @service, @source) ->
    @listen()
    console.log "Listening at #{@path()}"

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
    @return_value(
      @path() + " please overide fetch method - params: #{JSON.stringify @params}"
    )

  # return a value synchronously after a connection
  return_value: (value) =>
    @res.send value if @res

  # HELPERS ####################################################################

  @load_plugins: =>

    # list all services directories
  	for service in fs.readdirSync __dirname+'/services'

      console.log "browsing #{service}"

      for source in fs.readdirSync __dirname+"/services/#{service}"

        # load only if module, not folder
        if source.indexOf('.coffee') != -1

          source_name = source.replace('.coffee', '')

          NewFetcher = require("./services/#{service}/#{source_name}")
          fetcher = new NewFetcher(app, service, source_name)

          @plugins.push fetcher

  @print_plugins: =>
    output = ''
    for plugin in @plugins
      _url   = "#{plugin.service}/#{plugin.source}"
      output +=  "#{_url} <br />"
    return output

  @start: (port) =>
    server = app.listen port, =>
      console.log "Fetcher running on port #{port}"
    app.get '/', (req, res) =>
      res.send @print_plugins()


module.exports = Fetcher
