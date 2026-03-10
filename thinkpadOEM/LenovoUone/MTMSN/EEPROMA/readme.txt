#Purpose
The EEPROM package is used to access EEPROM area which can be customized in configuration file. 

#What components are contained in package.
EEPROM.efi: It's a 32bit tool application.
EEPROMx64.efi: It's a 64bit tool application.
readme.txt: It's a simplely introduction for the package.
EEPROM.ini: It's a configuration file that can define customized command name with EEPROM data location and data length by each project case. 

#EEPROM tool function flow
1. Parser the EEPROM.ini config file to get related information, which contain command definition,EEPROM data structure and SMI Commond Port
2  Send SMI to read data
3. process EEPROM data access via user command.

Usage example：
 Read Product Name：      EEPROM.efi  /rpn
 Write Product Name：     EEPROM.efi  /wpn  "Lenovo ideapad V530S-14IKB"