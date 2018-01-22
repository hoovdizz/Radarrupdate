#Need powershell Major version 5
#One time run of " Install-Module pssqlite -Scope CurrentUser -Force"
#Will install this modle  https://github.com/RamblingCookieMonster/PSSQLite
#Updated to support multi sort support and a switch to turn on/off service restart
#1-22-2018 Fixed Null Genres ; Made service restart not part of test mode

$testmodeon = "n"

#Things to change what you want.
$db_data_source = "C:\ProgramData\Radarr\nzbdrone.db"
$replacepart = "radarr"
$logfile = "C:\ProgramData\Radarr\Updatemovies.txt"

#y = yes to restart n= no to restat
$restartservice = "n"

$selection = "0"

#selection 0 aka Alpha Numeric
#\Plex\DVDs\P\Primer [2004]

#selection 1 aka year
#\Plex\DVDs\2004\Primer [2004]

#selection 2 aka Decade
#\Plex\DVDs\2000s\Primer [2004]

#selection 3 aka genres
#\Plex\DVDs\Science Fiction\Primer [2004


Import-Module PSSQLite


#query to pull in movies that have the temp folder in the path
$db_query = "SELECT ID,Path,SortTitle, Monitored,Year,Genres FROM `Movies` WHERE `Path` LIKE '%$replacepart%' ESCAPE '\' ORDER BY `_rowid_` ASC LIMIT 0, 50000;"

$pullrequest = Invoke-SqliteQuery -Query $db_query -DataSource $db_data_source 
if (-not ([string]::IsNullOrEmpty($pullrequest)))
{

$time = get-date 
Add-Content $logfile $time
$newpath = $NULL

#Foreach loop to change each movie found with the temp folder in its path
Foreach ($item in $pullrequest)

#Open For each loop
{

if ($testmodeon -eq "y"){
#------Before Change Check
$item.ID
$item.Path

}

#$item.Monitored
$oldpath = $item.Path 
$oldmon = $item.Monitored

#pull first letter and make upercase
$moviename = $item.SortTitle
$moviename =$moviename.SubString(0,1)
$moviename = $moviename.toupper()

#Pull year out
$year = $item.Year

#pull Genre out
$genre = $item.Genres
if (-not ([string]::IsNullOrEmpty($genre)))
{
$genre = $genre.trim('[]')
$genre = $genre -replace '"', ''
if ($genre -like '*,*') {$genre = $genre.Substring(0, $genre.IndexOf(',')) }
}
else { $genre = "Unkown"}


$genre = $genre -replace "`t|`n|`r",""
$genre = $genre.trim()


#Strip the apostrophes from movie folder ex "Molly's Game [2017]" --> "Mollys Game [2017]"
$newpath = $newpath -replace "'", ""


$newmon="1"
$newid=$item.ID

if ($selection -eq "0")
{
#Change temp folder to Alpha
$newpath = $item.Path -Replace $replacepart , $moviename
}


elseif ($selection -eq "1")
{
##Change temp folder to Year
$newpath = $item.Path -Replace $replacepart , $year
}


elseif ($selection -eq "2")
{
##Change temp folder to Decade
$start= 1900
$end = 1909
$decade = $null

while ($decade -eq $null)
{
if ($year -ge $start -and $year-le $end) { $decade = "$start s"}
$start = $start+10
$end = $end+10
}
$decade = $decade -replace ' ', '' 

$newpath = $item.Path -Replace $replacepart , $decade
}

elseif ($selection -eq "3")
{
##Change temp folder to genre
$newpath = $item.Path -Replace $replacepart , $genre

}

#Strip the apostrophes from movie folder ex "Molly's Game [2017]" --> "Mollys Game [2017]"
$newpath = $newpath -replace "'", ""

if ($testmodeon -eq "y"){
#-------After Change Check
$newid
$newpath
}

##query annd facke query for log file
$db_update = "UPDATE `Movies` SET Path = '$newpath', Monitored = '$newmon' WHERE ID =  '$newid'"
$oldInfo = "ORIGNL `Movies` WAS Path = '$oldpath', Monitored = '$oldmon' WHERE ID =  '$newid'"
$space = "----"


#send to log file
if ($testmodeon -eq "n"){
Add-Content $logfile $oldInfo
Add-Content $logfile $db_update
Add-Content $logfile $space
}

#Make DB changes
if ($testmodeon -eq "n"){Invoke-SqliteQuery -DataSource $db_data_source -Query $db_update}


#Close For each loop
}

if ($testmodeon -eq "n")
{
if ($restartservice -eq "Y"){restart-Service Radarr}
}

}
