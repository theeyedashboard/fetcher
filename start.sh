#!/bin/bash
# Patch excelParser to avoid error with WARNING messages

PARSE_FILE="/node_modules/excel-parser/excelParser.js"
echo "-----------> Patching ${PARSE_FILE}..."
WARNING_MSG="WARNING *** OLE2 inconsistency: SSCS size is 0 but SSAT size is non-zero"
OLD_LINE="_.compact(stdout.split"
NEW_LINE="_.compact(stdout.replace('${WARNING_MSG}', '').split"
echo "-- ${OLD_LINE}"
echo "++ ${NEW_LINE}"
sed -i "s/${OLD_LINE}/${NEW_LINE}/g" $PARSE_FILE

# start fetcher
nodemon main.coffee
