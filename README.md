# Sqlite2XML
Functions to convert an Sqlite DB to XML and XSD Formats.
Usage:



sqlite2xml(db_file, save_file)
Converts and sqlite database to XML.

 Parameters:
 db_file: path to .db file
 save_file: save file name as .xml
 
 Example:
 sqlite2xml('home/Documents/sqlite/database.db', 'home/Documents/XML/output.xml')
 
 
 
sqlite2xsd(db_file, save_file)
Converts and sqlite database to XSD.

 Parameters:
 db_file: path to .db file
 save_file: save file name as .xsd
 
 Example:
 sqlite2xml('home/Documents/sqlite/database.db', 'home/Documents/XML/output.xsd')
 Types will need to be changed and foreign keys will need to be added for xsd.
