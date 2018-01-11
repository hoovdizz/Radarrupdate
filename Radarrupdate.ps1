#Need powershell Major version 5
#One time run of " Install-Module pssqlite -Scope CurrentUser -Force"
#Will install this modle  https://github.com/RamblingCookieMonster/PSSQLite






#Things to change what you want.
$db_data_source = "C:\ProgramData\Radarr\nzbdrone.db"
$replacepart = "radarr"
$logfile = "C:\ProgramData\Radarr\Updatemovies.txt"



Import-Module PSSQLite

$time = get-date 

Add-Content $logfile $time

$db_query = "SELECT ID,Path,SortTitle, Monitored FROM `Movies` WHERE `Path` LIKE '%$replacepart%' ESCAPE '\' ORDER BY `_rowid_` ASC LIMIT 0, 50000;"

$pullrequest = Invoke-SqliteQuery -Query $db_query -DataSource $db_data_source 


#log 
Foreach ($item in $pullrequest)
{

#------before check
#$item.ID
#$item.Path
#$item.Monitored

$oldpath = $item.Path 
$oldmon = $item.Monitored

$moviename = $item.SortTitle
$moviename =$moviename.SubString(0,1)
$moviename = $moviename.toupper()
$newpath = $item.Path -Replace $replacepart , $moviename

#strip the apostrophes
$newpath = $newpath -replace "'", ""

$newmon="1"
$newid=$item.ID





#-------After Check
#$newid
#$newpath
#$newmon




$db_update = "UPDATE `Movies` SET Path = '$newpath', Monitored = '$newmon' WHERE ID =  '$newid'"
$oldInfo = "ORIGNL `Movies` WAS Path = '$oldpath', Monitored = '$oldmon' WHERE ID =  '$newid'"
$space = "----"


#send to log file
Add-Content $logfile $oldInfo
Add-Content $logfile $db_update
Add-Content $logfile $space



#Make DB changes


Invoke-SqliteQuery -DataSource $db_data_source -Query $db_update


}
