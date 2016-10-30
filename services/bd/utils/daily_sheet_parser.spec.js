import expect from 'expect'
import moment from 'moment'

require('coffee-script/register')
const DailySheetParser = require ('./daily_sheet_parser')
const daily_data_sheet = require('./test_data/daily_sheet.json')
const expected_index_results = require('./test_data/index.json')

describe ('DailySheetParser', () => {

  describe('global parse function', () =>
  {
    it('should return expected result json', () =>
    {
      const dailySheetParser = new DailySheetParser()
      let index_results = dailySheetParser.parse(daily_data_sheet, "Allure Equip Mag", "Export_BV_2016_septembre_Allure Hôtesses.xls")

      // fix date for JSON.stringify
      index_results['data']['date_start'] = moment(index_results['data']['date_start']).format().replace('+02:00','.000Z')
      index_results['data']['date_end'] = moment(index_results['data']['date_end']).format().replace('+02:00','.000Z')

      expect(
        JSON.stringify(index_results)
      ).toEqual(JSON.stringify(expected_index_results))

    })
  })

  describe('parse sub functions', () => {

    const dailySheetParser = new DailySheetParser()
    let index_results = dailySheetParser.parse(daily_data_sheet, "Allure Equip Mag", "Export_BV_2016_septembre_Allure Hôtesses.xls")

    // fix date for JSON.stringify
    index_results['data']['date_start'] = moment(index_results['data']['date_start']).format().replace('+02:00','.000Z')
    index_results['data']['date_end'] = moment(index_results['data']['date_end']).format().replace('+02:00','.000Z')

    describe('parse folder', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['folder']
        ).toEqual('Allure Equip Mag')
      })
    })

    describe('parse raz number', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['raz']
        ).toEqual(1)
      })
    })

    describe('parse vestiaire', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['vestiaire']
        ).toEqual(1)
      })
    })

    describe('parse date_start', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['date_start']
        ).toEqual('2016-09-12T08:47:47.000Z')
      })
    })

    describe('parse date_end', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['date_end']
        ).toEqual('2016-09-12T18:13:10.000Z')
      })
    })

    describe('parse sales_amount', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['sales_amount']
        ).toEqual(228)
      })
    })

    describe('parse annulations', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['annulations']
        ).toEqual(
          {
			      "amount": 0,
		        "value": 0
		      }
        )
      })
    })

    describe('parse offerts', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['offerts']
        ).toEqual(
          {
            "amount": 0,
            "value": 0
          }
        )
      })
    })

    describe('parse revenues', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['revenues']
        ).toEqual(
          588
        )
      })
    })

    describe('parse taxes', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['taxes']
        ).toEqual(
          [
            {
              "val": 20,
              "ht": 490,
              "tva": 98,
              "ttc": 588
            }
          ]
        )
      })
    })

    describe('parse total', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['total']
        ).toEqual(
          {
            "val": 'total',
            "ht": 490,
            "tva": 98,
            "ttc": 588
          }
        )
      })
    })

    describe('parse articles', () => {
      it('should return expected value', () => {
        expect(
          index_results['data']['articles']
        ).toEqual(
          [
      			{
      				"title": "1 VETEMENT",
      				"amount": 21,
      				"total": 42
      			},
      			{
      				"title": "CM VETEMENT",
      				"amount": 8,
      				"total": 0
      			},
      			{
      				"title": "ACCESSOIRE",
      				"amount": 5,
      				"total": 15
      			},
      			{
      				"title": "CASQUE",
      				"amount": 12,
      				"total": 36
      			},
      			{
      				"title": "SAC/ VALISE",
      				"amount": 164,
      				"total": 492
      			},
      			{
      				"title": "PARAPLUIE",
      				"amount": 1,
      				"total": 3
      			},
      			{
      				"title": "CM SAC/ ACC.",
      				"amount": 17,
      				"total": 0
      			}
      		]
        )
      })
    })

  }) // describe parse sub
})
