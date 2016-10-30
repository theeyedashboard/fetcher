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

  it('should return folder', () => {
    expect(
      results['data']['folder']
    ).toEqual('Le Cozy/Test - Horaire - Vestiaire')
  })

  let hours = results['data']['hours']

  describe('total', () => {
    it('should return 123 for hour 9', () => {
      expect(
        hours['9']['total']
      ).toEqual(123)
    })
  })

  describe('revenues', () => {
    it('should return 276 for hour 9', () => {
      expect(
        hours['9']['revenues']
      ).toEqual(276)
    })
    it('should return 0 for hour 6', () => {
      expect(
        hours['6']['revenues']
      ).toEqual(0)
    })
  })

  describe('revenues', () => {
    it('should return 276 for hour 9', () => {
      expect(
        hours['9']['revenues']
      ).toEqual(276)
    })
    it('should return 0 for hour 20', () => {
      expect(
        hours['20']['revenues']
      ).toEqual(0)
    })
  })


  describe('annulations', () => {
    it('should return 0 for hour 9', () => {
      expect(
        hours['9']['annulations']
      ).toEqual(0)
    })
    it('should return 7 for hour 18', () => {
      expect(
        hours['18']['annulations']
      ).toEqual(7)
    })
  })

  describe('offerts', () => {
    it('should return 4 for hour 8', () => {
      expect(
        hours['8']['offerts']
      ).toEqual(4)
    })
    it('should return 0 for hour 10', () => {
      expect(
        hours['10']['offerts']
      ).toEqual(0)
    })
  })

  describe('articles', () => {
    it('should return expected {} for hour 9', () => {
      let expected_articles = [
        {
          title: "1 VETEMENT",
          unit_price: 2,
        },
        {
          title: "2 VETEMENTS",
          unit_price: 4
        },
        {
          title: "1 PETIT SAC",
          unit_price: 2
        },
        {
          title: "1 GROS SAC",
          unit_price: 4
        },
        {
          title: "1 CASQUE",
          unit_price: 2
        },
        {
          title: "CIGARETTE",
          unit_price: 10
        },
        {
          title: "CAFE",
          unit_price: 2
        },
      ]
      expect(
        hours['10']['articles']
      ).toEqual(expected_articles)
    })
    it('should return 0 for hour 10', () => {
      expect(
        hours['10']['offerts']
      ).toEqual(0)
    })
  })


})
