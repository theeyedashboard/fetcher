moment = require('moment')

class DatesFixer

  # Fetch correct date from date cell
  # (Sometimes, excel cell is date format. Sometimes it's string.)
  # If it's time format, convert to string DD/MM/YYYY
  # string : 12/09/2016
  # date   : 4-Feb-16
  @fix_weird_date: (date_str) =>
    if date_str.length >= 10
      return date_str
    else
      moment.locale('en')
      new_date = moment(date_str, 'DD-MMM-YY')
      return new_date.format('DD/MM/YYYY')

  # Fetch correct Hour from time cell
  # (Sometimes, excel cell is date format. Sometimes it's string.)
  # If it's date, fetch hour string (second part)
  # string : 15:08:36
  # date   : 1899-12-30 10:10:34
  @fix_weird_hour: (time_str) =>
    if time_str.length > 9
      return time_str.split(' ')[1]
    else
      return time_str

module.exports = DatesFixer
