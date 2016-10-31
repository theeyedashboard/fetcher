moment = require('moment')
DatesFixer = require('./dates_fixer')

class DailySheetParser

  parse: (records, folder, filename) ->
    results = {}
    type = filename.substring(7,9)
    try
      results['folder']         = folder
      results['raz']            = @parse_raz_number(records)
      results['vestiaire']      = @parse_vestiaire(records)
      dates = @parse_raz_dates(records)
      results['date_short']     = dates['short']
      results['date_start']     = dates['start'].format()
      results['date_end']       = dates['end'].format()
      results['sales_amount']   = @parse_sales_amount(records)
      results['annulations']    = @parse_annulations(records)
      results['offerts']        = @parse_offerts(records)
      if type != 'VE'
        results['revenues']       = @parse_encaissements(records)
        taxes = @parse_taxes(records)
        # results['taxe1']          = taxes['taxe1']
        # results['taxe2']          = taxes['taxe2']
        results['taxes']          = taxes['taxes']
        results['total']          = taxes['total']
      else
        results['revenues']       = 0
        # results['taxe1']          = { val: 0, ht: 0, tva: 0, ttc: 0 }
        # results['taxe2']          = { val: 0, ht: 0, tva: 0, ttc: 0 }
        results['total']          = { val: 0, ht: 0, tva: 0, ttc: 0 }
        results['taxes']          = []

      results['articles']       = @parse_articles(records)
      return { status: 0, data: results }
    catch error
      return { status: -1, error: error }

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
            if record[6] != ''
              article['total']  = parseFloat(record[6])
            else
              article['total'] = 0
            articles.push article
    return articles

  # find the first line which contains "RAZ" in col 2 and extract RAZ number
  parse_raz_number: (records) =>
    for record in records
      # commented because some files doesn't contain "RAZ string"
      #   if record[1] && record[1].indexOf("RAZ") > -1
      if record[1] && record[1] != ''
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
      # console.log "record4: #{record[4]}, record6: #{record[6]}"
      if record[4] && record[4] != '' && record[6] && record[6] != ''
        record[4] = DatesFixer.fix_weird_date(record[4])
        record[6] = DatesFixer.fix_weird_hour(record[6])
        # console.log "record4: #{record[4]}, record6: #{record[6]} (fixed)"
        if index == 0
          date_start = moment(record[4] + ' ' + record[6], 'DD/MM/YYYY HH:mm:ss')
        if index == 1
          date_end = moment(record[4] + ' ' + record[6], 'DD/MM/YYYY HH:mm:ss')
          date_short = date_end.format('YYYYMM')
          # console.log 'dates:', { start: date_start.format("DD/MMM/YYYY HH:mm:ss"), end: date_end.format(), short: date_short }
          # console.log 'return DATE', { start: date_start, end: date_end, short: date_short}
        # if index >= 2
          # console.log 'return', { start: date_start, end: date_end, short: date_short}
          return { start: date_start, end: date_end, short: date_short}
        index++
    throw "RAZ dates not found"

  parse_encaissements: (records) =>
    for record in records
      if record[1] && record[1].indexOf("ENCAISSEMENT") > -1
        number = record[6].replace(',','.').replace( /^\D+/g, '')
        return parseFloat(number)
    throw "Encaissements not found"

  parse_sales_amount: (records) =>
    for record in records
      if record[1] && (record[1].indexOf("VENTES") > -1 || record[1].indexOf("TICKETS") > -1)
        number = record[4].replace(',','.').replace( /^\D+/g, '')
        return parseInt(number)
    throw "Sales amount not found"

  parse_taxes: (records) =>
    index = 0
    taxes = {}
    taxes['taxes'] = []
    for record in records
      if record[1] && (record[1].indexOf("TVA") > -1 || record[1].indexOf("TOTAL") > -1) && record[0] == ''
        value = parseFloat(record[1].replace(',','.').replace( /^\D+/g, ''))
        ht    = parseFloat(record[4].replace(',','.').replace( /^\D+/g, ''))
        tva   = parseFloat(record[5].replace(',','.').replace( /^\D+/g, ''))
        ttc   = parseFloat(record[6].replace(',','.').replace( /^\D+/g, ''))
        if record[1].indexOf("TVA") > -1
          taxes['taxes'].push { val: value, ht: ht, tva: tva, ttc: ttc }
        else if record[1].indexOf("TOTAL") > -1
          taxes['total'] = { val: 'total', ht: ht, tva: tva, ttc: ttc }

    if taxes['total'] && taxes['taxes'].length > 0
      return taxes
    else
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

module.exports = DailySheetParser
