Fetcher         = require('./fetcher')

# app.get '/', (req, res) =>
#   console.log 'Nothing to display'

Fetcher.load_plugins()
Fetcher.start(80)
