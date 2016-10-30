import expect from 'expect'
import moment from 'moment'

require('coffee-script/register')
const DatesFixer = require('./dates_fixer')

describe('DatesFixer', () =>
{
  describe('fix_weird_hour', () =>
  {
    it('should return 15:08:36 if time is 15:08:36', () =>
    {
      expect(
        DatesFixer.fix_weird_hour('15:08:36')
      ).toEqual('15:08:36')
    })

    it('should return 10:10:34 if time is 1899-12-30 10:10:34', () =>
    {
      expect(
        DatesFixer.fix_weird_hour('1899-12-30 10:10:34')
      ).toEqual('10:10:34')
    })

  }) // describe fix weird hour

  describe('fix_weird_date', () =>
  {
    it('should return 12/09/2016 if date is 12/09/2016', () =>
    {
      expect(
        DatesFixer.fix_weird_date('12/09/2016')
      ).toEqual('12/09/2016')
    })
    it('should return 04/02/16 if date is 4-Feb-16', () =>
    {
      expect(
        DatesFixer.fix_weird_date('4-Feb-16')
      ).toEqual('04/02/2016')
    })

  })
})
