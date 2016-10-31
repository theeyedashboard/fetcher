moment = require('moment')
excelParser = require('excel-parser')

class ExcelParser

  @parse_records_in_file: (filepath, worksheet, callback) =>
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

  @parse_sheet_list_in_file: (filepath, callback) =>
    excelParser.worksheets(
      inFile: filepath
    , (err, worksheets) =>
      if err
        console.error 'error:', err
      else
        callback(worksheets)
    )

module.exports = ExcelParser
