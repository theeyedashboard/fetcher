moment = require('moment')
DatesFixer = require('./dates_fixer')
moment_fr = require('./moment.locale.fr.js')
excelParser = require('excel-parser')

ARTICLES_INDEXES_ROW    = 8
ARTICLES_LABELS_ROW     = 9
ARTICLES_UNIT_PRICE_ROW = 10

class HourlySheetParser

  parse: (filepath, worksheet, folder, filename, callback) =>
    @parse_records_in_file filepath, worksheet, (records) =>
      results = {}
      try
        results['folder'] = folder
        # moment.locale('fr')
        results['date']   = @get_date_from_filename(filename, worksheet)
        # moment.locale('en')
        results['hours']  = @parse_hours(records)
        callback({ status: 0, data: results })
      catch error
        callback({ status: -1, error: error })

  parse_records_in_file: (filepath, worksheet, callback) =>
    excelParser.parse(
      inFile: filepath,
      worksheet: worksheet,
      skipEmpty: false,
    , (err, records) =>
      if err
        console.error 'error:', err
        console.error 'worksheet:', worksheet
      else
        # console.log 'records', records
        callback(records)
    )

  get_date_from_filename: (filename, worksheet) =>
    filename_chunks = filename.split('_')
    year = filename_chunks[2]
    month = filename_chunks[3]
    return moment("#{worksheet} #{month} #{year}", "DD MMMM YYYY").format()

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
