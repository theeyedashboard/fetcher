Fetcher = require('../../fetcher')
request = require('request')
excelParser = require('excel-parser')

class BDBilleterieRAZ extends Fetcher

  fetch: =>
    file = 'tmp/bd/2015-sep.xls'
    # file = '../../tmp/bd/2015-sep.xls'
    excelParser.worksheets(
      inFile: file
    , (err, worksheets) ->
      # if(err) console.error(err)
      if err
        console.error 'error:', err
      else
        console.log 'worksheets:', worksheets
    )
    # base_url = @params['base_url']
    @return_value "yo"

module.exports = BDBilleterieRAZ
