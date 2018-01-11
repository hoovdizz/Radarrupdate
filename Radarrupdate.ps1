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

#query to pull in movies that have the temp folder in the path
$db_query = "SELECT ID,Path,SortTitle, Monitored FROM `Movies` WHERE `Path` LIKE '%$replacepart%' ESCAPE '\' ORDER BY `_rowid_` ASC LIMIT 0, 50000;"

$pullrequest = Invoke-SqliteQuery -Query $db_query -DataSource $db_data_source 

#Foreach loop to change each movie found with the temp folder in its path
Foreach ($item in $pullrequest)

#Open For each loop
{

#------Before Change Check Uncomment for Diagnosis
#$item.ID
#$item.Path
#$item.Monitored

$oldpath = $item.Path 
$oldmon = $item.Monitored

#pull first letter and make upercase
$moviename = $item.SortTitle
$moviename =$moviename.SubString(0,1)
$moviename = $moviename.toupper()

#Change temp folder to Alpha
$newpath = $item.Path -Replace $replacepart , $moviename

#Strip the apostrophes from movie folder ex "Molly's Game [2017]" --> "Mollys Game [2017]"
$newpath = $newpath -replace "'", ""

$newmon="1"
$newid=$item.ID

#-------After Change Check Uncomment for Diagnosis
#$newid
#$newpath
#$newmon

#query annd facke query for log file
$db_update = "UPDATE `Movies` SET Path = '$newpath', Monitored = '$newmon' WHERE ID =  '$newid'"
$oldInfo = "ORIGNL `Movies` WAS Path = '$oldpath', Monitored = '$oldmon' WHERE ID =  '$newid'"
$space = "----"

#send to log file
Add-Content $logfile $oldInfo
Add-Content $logfile $db_update
Add-Content $logfile $space

#Make DB changes
Invoke-SqliteQuery -DataSource $db_data_source -Query $db_update

#Close For each loop
}

