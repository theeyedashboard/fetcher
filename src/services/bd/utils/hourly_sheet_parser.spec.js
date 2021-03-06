import expect from 'expect'
import moment from 'moment'
require('coffee-script/register')
const ExcelParser = require('./excel_parser')
const HourlySheetParser = require ('./hourly_sheet_parser')

const worksheet = '12';
const filename = "VentesHoraire_BV_2016_septembre_LECOZY.xls";
const folder = "Le Cozy/Test - Horaire - Vestiaire";

let file_path = __dirname + "/test_data/" + filename;
let results = {}
let hours   = {}

describe ('HourlySheetParser', () => {

  before(function (done) {
    let hourlySheetParser = new HourlySheetParser();

    ExcelParser.parse_records_in_file(file_path, worksheet, function(records)
    {
      results = hourlySheetParser.parse(records, worksheet, folder, filename);
      // console.log('results', results);
      results['data']['date'] = results['data']['date'].replace('+00:00','.000Z');
      hours = results['data']['hours'];
      done();
    })
  })

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

  it('should return date', () => {
    expect(
      results['data']['date']
    ).toEqual('2016-09-12T00:00:00.000Z')
  })

  describe('total', () => {
    it('should return 123 for hour 9', () => {
      expect(
        hours['9']['total']
      ).toEqual(123)
    })
    it('should return 1543 for total', () => {
      expect(
        hours['total']['total']
      ).toEqual(1543)
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
    it('should return 3426 for total', () => {
      expect(
        hours['total']['revenues']
      ).toEqual(3426)
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
    it('should return 7 for total', () => {
      expect(
        hours['total']['annulations']
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
    it('should return 11 for total', () => {
      expect(
        hours['total']['offerts']
      ).toEqual(11)
    })
  })

  describe('articles', () => {
    it('should return expected [] for hour 0', () => {
      let expected_articles = []
      expect(
        hours['0']['articles']
      ).toEqual(expected_articles)
    });

    it('should return expected [...] for hour 9', () => {
      let expected_articles = [
        {
          title: "1 VETEMENT",
          unit_price: 2,
          amount: 45,
          total: 90 // not in the sheet, calcutated
        },
        {
          title: "2 VETEMENTS",
          unit_price: 4,
          amount: 5,
          total: 20
        },
        {
          title: "1 PETIT SAC",
          unit_price: 2,
          amount: 60,
          total: 120
        },
        {
          title: "1 GROS SAC",
          unit_price: 4,
          amount: 10,
          total: 40
        },
        {
          title: "1 CASQUE",
          unit_price: 2,
          amount: 3,
          total: 6
        }
        // {
        //   title: "CIGARETTE",
        //   unit_price: 10,
        //   amount: 0
        // },
        // {
        //   title: "CAFE",
        //   unit_price: 2,
        //   amount: 0
        // },
      ]
      expect(
        hours['9']['articles']
      ).toEqual(expected_articles)
    })

    it('should return expected [...] for total', () => {
      let expected_articles = [
        {
          title: "1 VETEMENT",
          unit_price: 2,
          amount: 521,
          total: 1042 // not in the sheet, calcutated
        },
        {
          title: "2 VETEMENTS",
          unit_price: 4,
          amount: 47,
          total: 188
        },
        {
          title: "1 PETIT SAC",
          unit_price: 2,
          amount: 815,
          total: 1630
        },
        {
          title: "1 GROS SAC",
          unit_price: 4,
          amount: 107,
          total: 428
        },
        {
          title: "1 CASQUE",
          unit_price: 2,
          amount: 49,
          total: 98
        },
        {
          title: "CIGARETTE",
          unit_price: 10,
          amount: 4,
          total: 40
        },
        {
          title: "CAFE",
          unit_price: 2,
          amount: 0,
          total: 0
        },
      ]
      expect(
        hours['total']['articles']
      ).toEqual(expected_articles)
    })


  }) // desc articles


})
