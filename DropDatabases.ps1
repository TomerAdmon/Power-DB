
Param (
    [Parameter(Position=0, Mandatory=$true)][string] $User, 
    [Parameter(Position=0, Mandatory=$true)][string] $Password,
    [Parameter(Position=0, Mandatory=$true)][string] $DBName,
    [Parameter(Position=0, Mandatory=$false)][string]$serverName = "DB01"
)

Import-Module “sqlps” -DisableNameChecking

function DropDatabase([string]$databaseName,
                      [string]$ServerName,
                      [string]$User,
                      [string]$Password)
{
    Write-host "Starting to drop database: $databaseName from server $ServerName"
    
    $sqlQuery = "alter database $databaseName set single_user with rollback immediate"
    Write-host "alter database query: $sqlQuery"
    invoke-sqlcmd -ServerInstance $serverName -Query $SqlQuery -Username $User -Password $Password                       
    
    $sqlQuery = "drop database $databaseName ;"
    Write-host "drop database query: $sqlQuery"
    invoke-sqlcmd -ServerInstance $serverName -Query $SqlQuery -Username $User -Password $Password
}

function isDatabaseExsists([string]$databaseName,
                      [string]$ServerName,
                      [string]$User,
                      [string]$Password)
{
    Write-host "Verify database: $databaseName deleted successfully"
    $sqlQuery = "SELECT COUNT (*) AS count FROM master.dbo.sysdatabases WHERE name = '" + $databaseName + "';"
    Write-host "drop database query: $sqlQuery"
    $CountDatabaseInstances = invoke-sqlcmd -ServerInstance $serverName -Query $SqlQuery | select -ExpandProperty count
    if ($CountDatabaseInstances -gt 0)
    {
        return "ERROR"
    }
}

function dropAndVerify([string]$databaseName,
                      [string]$ServerName,
                      [string]$User,
                      [string]$Password)
{
    DropDatabase $databaseName $ServerName $User $Password
    
    $databaseExsists  =isDatabaseExsists $databaseName $ServerName $User $Password
    if ($databaseExsists -contains "ERROR")
    {
        Write-host "##teamcity[message text='Exception text' errorDetails='stack trace' status='ERROR']"    
    }
    
}

Write-host "Staring to run Drop Databases"
dropAndVerify $DBName $ServerName $User $Password
