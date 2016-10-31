moment = require('moment')
DatesFixer = require('./dates_fixer')

ARTICLES_INDEXES_ROW    = 8
ARTICLES_LABELS_ROW     = 9
ARTICLES_UNIT_PRICE_ROW = 10

class HourlySheetParser

  parse: (records, folder, filename) ->
    results = {}
    results['folder'] = folder
    results['hours'] = @parse_hours(records)
    try
      return { status: 0, data: results }
    catch error
      return { status: -1, error: error }

  parse_hours: (records) =>
    hours = {}
    start_counting = false
    hour_index = 0
    for record, index in records
      if record[0] and !start_counting
        start_counting = true
      if start_counting
        if record[0] and record[0].indexOf('TOTAL') == -1
          hours[hour_index.toString()] = @parse_hour(records, index)
          hour_index++
        else if record[0] and record[0].indexOf('TOTAL') != -1
          hours['total'] =  @parse_hour(records, index)
    return hours

  parse_hour: (records, index) =>
    record = records[index]
    return {
      name:         record[0],
      total:        @parse_int(record[1]),
      revenues:     @parse_int(record[2]),
      annulations:  @parse_int(record[3]),
      offerts:      @parse_int(record[4]),
      articles:     @parse_articles_for_index(records, index)
    }

  parse_int: (string) =>
    if string
      return parseInt(
        string.replace( /^\D+/g, '')
      )
    else
      return 0

  parse_articles_for_index: (records, index) =>
    articles = []
    # parse column with an article index
    for column, column_index in records[index]
      article_index = records[ARTICLES_INDEXES_ROW][column_index]
      article_name = records[ARTICLES_LABELS_ROW][column_index]
      unit_price = @parse_int(records[ARTICLES_UNIT_PRICE_ROW][column_index])
      if article_index && article_name && column
        articles.push {
          title: article_name,
          unit_price: unit_price,
          amount: @parse_int(column),
          total: @parse_int(column) * unit_price
        }
    return articles


module.exports = HourlySheetParser
