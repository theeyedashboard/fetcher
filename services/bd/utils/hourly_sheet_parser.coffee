moment = require('moment')
DatesFixer = require('./dates_fixer')

class HourlySheetParser

  parse: (records, folder, filename) ->
    results = {}
    try
      return { status: 0, data: results }
    catch error
      return { status: -1, error: error }

module.exports = HourlySheetParser
