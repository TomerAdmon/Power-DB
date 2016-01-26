# Power-DB
manage MSSQL using powershell 


###DropDatabase.ps1
powershell -File ./DtopDatabase.ps1 -User "User" -Passwork "Password" -DBName "DBNameToDelete" -ServerName "DBServer"

###RestoreDatabaseToRemoteDB.ps1
powershell -File ./DtopDatabase.ps1 -User "User" -Passwork "Password" -DBName "DBNameToDelete" -DatabaseFolder "c:\DBs" -ServerName "DBServer"

you can create a config file that contains you db's to restore. see format inside the ps1.

