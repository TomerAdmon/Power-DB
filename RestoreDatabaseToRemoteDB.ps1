
Param (
    [Parameter(Position=0, Mandatory=$true)][string] $User, 
    [Parameter(Position=0, Mandatory=$true)][string] $Password,
    [Parameter(Position=0, Mandatory=$true)][string] $DBname,
    [Parameter(Position=0, Mandatory=$true)][string] $DatabasesFolder, 
    [Parameter(Position=0, Mandatory=$false)][string]$serverName = "DB01"
)


cd c:\

<# Config style
<config>
	<DB1>aaa.bak</DB1>
	<DB2>bbb.bak</DB2>
</config>
#>

function RestoreDatabase([string]$database,
                         [string]$serverName,
                         [string]$backupFile,
                         [string]$User,
                         [string]$Password)
{
    Try
    {
        Write-host "Starting to restore the database $database to the server $serverName"
        $strPass = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($User, $strPass)
        Restore-SqlDatabase -ServerInstance $serverName -Database $database -BackupFile $backupFile -ReplaceDatabase -Credential $cred
    }
    Catch
    {
        Write-Error "Error! While invoking the Config bat"
        Write-Error ($_.Exception)
    }
}

Try
{
    dir $DatabasesFolder
    $XML = Get-ChildItem $DatabasesFolder config.xml
    write-host "XML: "$XML

    if ($XML -eq $null)
    {
	# Write to TeamCity log
        Write-host "##teamcity[message text='Faild To find XML file' errorDetails='stack trace' status='ERROR']"            
    }

    Write-Host "Reading XML file" $XML.FullName

    [xml]$Config = Get-Content -Path $XML.FullName
    $DB1Location = join-path $DatabasesFolder $Config.config.DB1
    Write-host "DB1: " $DB1Location

    $DB2Location = join-path $DatabasesFolder $Config.config.DB2
    Write-host "DB2: " $DB2Location

}
Catch
{
	# Write to Team City log
    Write-host "##teamcity[message text='Error locating or parsing the config.xml file' errorDetails='($_.Exception)' status='ERROR']"    
}


Import-Module “sqlps” -DisableNameChecking | out-null

##prep databases
Write-host "RestoreDatabase1: " $DB1 ", " $serverName ", " $DB1Location ", " $User ", " $Password
RestoreDatabase $DB1 $serverName $DB1Location $User $Password

Write-host "RestoreDatabase2: " $DB2 ", " $serverName ", " $DB2Location ", " $User ", " $Password
RestoreDatabase $DB2 $serverName $DB2Location $User $Password
