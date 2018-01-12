#Need powershell Major version 5
#One time run of " Install-Module pssqlite -Scope CurrentUser -Force"
#Will install this modle  https://github.com/RamblingCookieMonster/PSSQLite
#Updated to support multi sort support and a switch to turn on/off service restart

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

#------Before Change Check Uncomment for Diagnosis
#$item.ID
$item.Path

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
$genre = $genre.trim('[]')
$genre = $genre -replace '"', ''
if ($genre -like '*,*') {$genre = $genre.Substring(0, $genre.IndexOf(',')) }


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
if ($year -ge 1900 -and $year-le 1909) { $decade ="1900s"}
 if ($year -ge 1910 -and $year-le 1919) { $decade ="1910s"}
 if ($year -ge 1920 -and $year-le 1929) { $decade ="1920s"}
 if ($year -ge 1930 -and $year-le 1939) { $decade ="1930s"}
 if ($year -ge 1940 -and $year-le 1949) { $decade ="1940s"}
 if ($year -ge 1950 -and $year-le 1959) { $decade ="1950s"}
 if ($year -ge 1960 -and $year-le 1969) { $decade ="1960s"}
 if ($year -ge 1970 -and $year-le 1979) { $decade ="1970s"}
 if ($year -ge 1980 -and $year-le 1989) { $decade ="1980s"}
 if ($year -ge 1990 -and $year-le 1999) { $decade ="1990s"}
 if ($year -ge 2000 -and $year-le 2009) { $decade ="2000s"}
 if ($year -ge 2010 -and $year-le 2019) { $decade ="2010s"}
 if ($year -ge 2020 -and $year-le 2029) { $decade ="2020s"}
 if ($year -ge 2030 -and $year-le 2039) { $decade ="2030s"}
 if ($year -ge 2040 -and $year-le 2049) { $decade ="2040s"}
 if ($year -ge 2050 -and $year-le 2059) { $decade ="2050s"}
 if ($year -ge 2060 -and $year-le 2069) { $decade ="2060s"}
 if ($year -ge 2070 -and $year-le 2079) { $decade ="2070s"}
 if ($year -ge 2080 -and $year-le 2089) { $decade ="2080s"}
 if ($year -ge 2090 -and $year-le 2099) { $decade ="2090s"}
$newpath = $item.Path -Replace $replacepart , $decade
}

elseif ($selection -eq "3")
{
##Change temp folder to genre
$newpath = $item.Path -Replace $replacepart , $genre

}

#Strip the apostrophes from movie folder ex "Molly's Game [2017]" --> "Mollys Game [2017]"
$newpath = $newpath -replace "'", ""


#-------After Change Check Uncomment for Diagnosis
#$newid
$newpath
#$newmon


##query annd facke query for log file
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

if ($restartservice -eq "Y"){restart-Service Radarr}

}
