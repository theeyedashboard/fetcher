Fetcher = require('../../fetcher')
request = require('request')
excelParser = require('excel-parser')
moment = require('moment')

class BDBilleterieRAZ extends Fetcher

  file: =>
    'tmp/bd/2015-sep.xls'

  fetch: =>
    if !@params['action']
      @return_value 'Missing action parameter'
    else if @params['action'] == 'worksheets'
      @worksheets (worksheets) =>
        @return_value worksheets
    else if @params['action'] == 'parse'
      @parse_worksheet @params['worksheet'], (records) =>
        results = {}
        try
          results['raz']            = @parse_raz_number(records)
          results['vestiaire']      = @parse_vestiaire(records)
          results['date_start']     = @parse_raz_dates(records)['start']
          results['date_end']       = @parse_raz_dates(records)['end']
          results['revenues']       = @parse_encaissements(records)
          results['taxe1']          = { val: '20', ht: 0, tva: 0, ttc: 0}
          results['taxe2']          = { val: '10', ht: 0, tva: 0, ttc: 0}
          results['total']          = { ht: 0, tva: 0, ttc: 0}
          results['annulations']    = { amount: 0, total: 0 }
          results['offerts']        = { amount: 0, total: 0 }
          results['articles']       = @parse_articles(records)
          @return_value { status: 0, data: results }
        catch error
          @return_value { status: -1, error: error }

        # console.log records

  worksheets: (callback) =>
    excelParser.worksheets(
      inFile: @file()
    , (err, worksheets) =>
      if err
        console.error 'error:', err
      else
        callback(worksheets)
    )

  parse_worksheet: (worksheet, callback) =>
    excelParser.parse(
      inFile: @file(),
      worksheet: worksheet,
      skipEmpty: false,
    , (err, records) =>
      if err
        console.error 'error:', err
      else
        callback(records)
    )

  # parse data from records
  # - add article if first line is a number and second line is not empty
  parse_articles: (records) =>
    articles = []
    for record in records
      if record[0] != ""
        if Number.isInteger(parseInt(record[0]))
          if record[1] != ""
            article = {}
            article['title']  = record[1]
            article['amount'] = parseInt(record[4])
            article['total']  = parseFloat(record[6])
            articles.push article
    return articles

  # find the first line which contains "RAZ" in col 2 and extract RAZ number
  parse_raz_number: (records) =>
    for record in records
      if record[1] && record[1].indexOf("RAZ") > -1
        # replace all leading non-digits with nothing
        raz_number = record[1].replace( /^\D+/g, '')
        return parseInt(raz_number)
    throw "RAZ number not found"

  # find the first line which contains "Vestiaire" in col 6 and extract number
  parse_vestiaire: (records) =>
    for record in records
      if record[5] && record[5].indexOf("Vestiaire") > -1
        # replace all leading non-digits with nothing
        number = record[5].replace( /^\D+/g, '')
        return parseInt(number)
    throw "Vestiaire not found"

  parse_raz_dates: (records) =>
    index = 0
    for record in records
      if record[4] && record[4] != '' && record[6] && record[6] != ''
        if index == 0
          date_start = moment(record[4] + ' ' + record[6], 'DD/MM/YYYY HH:mm:ss')
        if index == 1
          date_end = moment(record[4] + ' ' + record[6], 'DD/MM/YYYY HH:mm:ss')
        if index >= 2
          return { start: date_start, end: date_end }
        index++
    throw "RAZ dates not found"

  parse_encaissements: (records) =>
    for record in records
      if record[1] && record[1].indexOf("ENCAISSEMENT") > -1
        number = record[6].replace( /^\D+/g, '')
        return parseFloat(number)
    throw "Encaissements not found"

module.exports = BDBilleterieRAZ
