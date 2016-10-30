import expect from 'expect'
import moment from 'moment'

require('coffee-script/register')
const HourlySheetParser = require ('./hourly_sheet_parser')
const hourly_data_sheet = require('./test_data/hourly_sheet.json')
// const expected_index_results = require('./test_data/index.json')

describe ('HourlySheetParser', () => {
  const hourlySheetParser = new HourlySheetParser()
  let results = hourlySheetParser.parse(hourly_data_sheet, "Le Cozy/Test - Horaire - Vestiaire", "VentesHoraire_BV_2016_septembre_LE COZY.xls")

  it('should return status 0', () => {
    expect(
      results['status']
    ).toEqual(0)    
  })


})
