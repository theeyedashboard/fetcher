Fetcher = require('../../fetcher')
request = require('request')
fs      = require ('fs')
excelParser = require('excel-parser')
moment = require('moment')

class BDBilleterieRAZ extends Fetcher

  file: =>
    @files_path() + '/' + @params['file']

  files_path: =>
    '/dropbox/BarDistribution'

  fetch: =>
    if !@params['action']
      @return_value 'Missing action parameter'
    else if @params['action'] == 'files'
      @return_value @fetch_files()
    else if @params['action'] == 'worksheets'
      @worksheets (worksheets) =>
        @return_value worksheets
    else if @params['action'] == 'parse'
      @parse_worksheet @params['worksheet'], (records) =>
        results = {}
        try
          results['raz']            = @parse_raz_number(records)
          results['vestiaire']      = @parse_vestiaire(records)
          dates = @parse_raz_dates(records)
          results['date_start']     = dates['start']
          results['date_end']       = dates['end']
          results['revenues']       = @parse_encaissements(records)
          taxes = @parse_taxes(records)
          results['taxe1']          = taxes['taxe1']
          results['taxe2']          = taxes['taxe2']
          results['total']          = taxes['total']
          results['annulations']    = @parse_annulations(records)
          results['offerts']        = @parse_offerts(records)
          results['articles']       = @parse_articles(records)
          @return_value { status: 0, data: results }
        catch error
          @return_value { status: -1, error: error }

        # console.log records

  fetch_files: =>
    _files = []
    # list all services directories
    for file in fs.readdirSync @files_path()
      _files.push file if file.indexOf(".xls") > -1
    return _files

  worksheets: (callback) =>
    console.log @file()
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
      else if record[5] && record[5].indexOf("Billetterie") > -1
        # replace all leading non-digits with nothing
        number = record[5].replace( /^\D+/g, '')
        return parseInt(number)
    throw "Vestiaire/Billetterie not found"

  parse_raz_dates: (records) =>
    index = 0
    for record in records
      if record[4] && record[4] != '' && record[6] && record[6] != ''
        if index == 0
          date_start = moment(record[4] + ' ' + record[6], 'DD/MMM/YYYY HH:mm:ss')
        if index == 1
          date_end = moment(record[4] + ' ' + record[6], 'DD/MMM/YYYY HH:mm:ss')
        if index >= 2
          return { start: date_start, end: date_end }
        index++
    throw "RAZ dates not found"

  parse_encaissements: (records) =>
    for record in records
      if record[1] && record[1].indexOf("ENCAISSEMENT") > -1
        number = record[6].replace(',','.').replace( /^\D+/g, '')
        return parseFloat(number)
    throw "Encaissements not found"

  parse_taxes: (records) =>
    index = 0
    taxes = {}
    for record in records
      if record[1] && (record[1].indexOf("TVA") > -1 || record[1].indexOf("TOTAL") > -1)
        value = parseFloat(record[1].replace(',','.').replace( /^\D+/g, ''))
        ht    = parseFloat(record[4].replace(',','.').replace( /^\D+/g, ''))
        tva   = parseFloat(record[5].replace(',','.').replace( /^\D+/g, ''))
        ttc   = parseFloat(record[6].replace(',','.').replace( /^\D+/g, ''))
        if index == 0
          taxes['taxe1'] = { val: value, ht: ht, tva: tva, ttc: ttc }
        if index == 1
          taxes['taxe2'] = { val: value, ht: ht, tva: tva, ttc: ttc }
        if index == 2
          taxes['total'] = { val: value, ht: ht, tva: tva, ttc: ttc }
          # tot_val = taxes['taxe1']['val'] + taxes['taxe2']['val']
          # tot_ht  = taxes['taxe1']['ht']  + taxes['taxe2']['ht']
          # tot_tva = taxes['taxe1']['tva'] + taxes['taxe2']['tva']
          # tot_ttc = taxes['taxe1']['ttc'] + taxes['taxe2']['ttc']
          # taxes['total'] = { ht: tot_ht, tva: tot_tva, ttc: tot_ttc }
          return taxes
        index++
    throw "Problem parsing taxes"

  parse_annulations: (records) =>
    for record in records
      if record[1] && record[1].indexOf("ANNULATION") > -1
        amount = parseInt(record[4])
        value  = parseFloat(record[6].replace(',','.').replace( /^\D+/g, ''))
        return { amount: amount, value: value }
    # throw "Annulations not found"
    return { amount: 0, value: 0 }

  parse_offerts: (records) =>
    for record in records
      if record[1] && record[1].indexOf("OFFERT") > -1
        amount = parseInt(record[4])
        value  = parseFloat(record[6].replace(',','.').replace( /^\D+/g, ''))
        return { amount: amount, value: value }
    # throw "Offerts not found"
    return { amount: 0, value: 0 }

module.exports = BDBilleterieRAZ
