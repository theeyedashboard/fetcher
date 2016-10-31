Fetcher = require('../../fetcher')
DailySheetParser = require('./utils/daily_sheet_parser')
HourlySheetParser = require('./utils/hourly_sheet_parser')
request = require('request')
fs      = require ('fs')
ExcelParser = require('./utils/excel_parser')
moment = require('moment')

class BDBilleterieRAZ extends Fetcher

    file: =>
        @files_path() + '/' + @params['file']

    files_path: =>
        '/root/Dropbox/' + @params['folder']

    folders_path: =>
        '/root/Dropbox'

    fetch: =>
        if !@params['action']
            @return_value 'Missing action parameter'
        else if @params['action'] == 'folders'
            @return_value @fetch_folders()
        else if @params['action'] == 'files'
            @return_value @fetch_files()
        else if @params['action'] == 'worksheets'
            ExcelParser.parse_sheet_list_in_file @file(), (worksheets) =>
                @return_value worksheets
        else if @params['action'] == 'parse'
            ExcelParser.parse_records_in_file @file(), @params['worksheet'], (records) =>
                dailySheetParser = new DailySheetParser()
                @return_value dailySheetParser.parse(records, @params['folder'], @params['file'])
        else if @params['action'] == 'parse_hourly'
            ExcelParser.parse_records_in_file @file(), @params['worksheet'], (records) =>
                hourlySheetParser = new HourlySheetParser()
                @return_value hourlySheetParser.parse(records, @params['worksheet'], @params['folder'], @params['file'])
            # @return_value hourlySheetParser.parse(records, @params['folder'], @params['file'])
            # @parse_worksheet @params['worksheet'], (records) =>
            #     hourlySheetParser = new HourlySheetParser()
            #     @return_value hourlySheetParser.parse(records, @params['folder'], @params['file'])

        # console.log records

    fetch_files: =>
        _files = []
        # list all services directories
        if fs.readdirSync @files_path()
            for file in fs.readdirSync @files_path()
                fixed_file = file # don't rename anymore
                _files.push fixed_file if fixed_file.indexOf(".xls") > -1
        return _files

    fetch_folders: =>
        _folders = []
        # list all services directories
        if fs.readdirSync @folders_path()
            for folder in fs.readdirSync @folders_path()
                if folder.charAt(0) != '.' && folder != 'test'
                    subfolders = fs.readdirSync @folders_path() + '/' + folder
                    is_indexable_folder = true
                    for subfolder in subfolders
                        if subfolder.indexOf('.') == -1 && subfolder != 'test'
                            _folders.push folder + '/' + subfolder
                            is_indexable_folder = false
                    if is_indexable_folder
                        _folders.push folder
        return _folders

module.exports = BDBilleterieRAZ
