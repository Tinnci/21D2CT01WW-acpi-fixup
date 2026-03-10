#Purpose
The EEPROM package is used to access EEPROM area which can be customized in configuration file. 

#What components are contained in package.
EEPROM.exe: It's a 32bit tool application and it's requested to run in Window console prompt. 
EEPROMx64.exe: It's a 64bit tool application and it's requested to run in Window console prompt. 
EEPROMDLL.dll: It's a 32bit dll.
EEPROMDLLx64.dll: It's a 64bit dll.
readme.txt: It's a simplely introduction for the package.
EEPROM.ini: It's a configuration file that can define customized command name with EEPROM data location and data length by each project case. 

#EEPROM tool function flow
1. Parser the EEPROM.ini config file to get related information, which contain command definition,EEPROM data structure and SMI Commond Port
2. Install EEPROM Driver
3  Send SMI to read data
4. process EEPROM data access via user command.