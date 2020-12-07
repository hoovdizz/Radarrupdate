#Need powershell Major version 5
#One time run of " Install-Module pssqlite -Scope CurrentUser -Force"
#Will install this modle  https://github.com/RamblingCookieMonster/PSSQLite
#Updated to support multi sort support and a switch to turn on/off service restart
#1-22-2018 Fixed Null Genres ; Made service restart not part of test mode
#1-24-2018 Fixed Date being written to file while in test mode
#1-25-2018 Fixed years that were 0
#1-25-2018 Added Manual Drop Down Array
#9-20-2019 Added Numerical grouping "0-9"

$testmodeon = "n"

#Things to change what you want.
#Version 2 DB
#$db_data_source = "C:\ProgramData\Radarr\nzbdrone.db"

$db_data_source = "C:\ProgramData\Radarr\radarr.db"
$replacepart = "radarr"
$logfile = "C:\ProgramData\Radarr\Updatemovies.txt"

# This is for selction 4, Can not be automated!!! this can be renamed or more added
[array]$DropDownArray = "Movies","Anime Movies","Kids Movies","Horror"

#y = yes to restart n= no to restat
$restartservice = "n"

#Selection of Assortment
$selection = "0"

#y = group 0-9 n = each number has their own folder This is for Selection 0 only
$numbergrouping = "y"

#selection 0 aka Alpha Numeric
#\Plex\DVDs\P\Primer [2004]

#selection 1 aka year
#\Plex\DVDs\2004\Primer [2004]

#selection 2 aka Decade
#\Plex\DVDs\2000s\Primer [2004]

#selection 3 aka genres
#\Plex\DVDs\Science Fiction\Primer [2004

#selection 4 aka Manual selection

Import-Module PSSQLite


#query to pull in movies that have the temp folder in the path
$db_query = "SELECT ID,Path,SortTitle, Monitored,Year,Genres FROM `Movies` WHERE `Path` LIKE '%$replacepart%' ESCAPE '\' ORDER BY `_rowid_` ASC LIMIT 0, 50000;"

$pullrequest = Invoke-SqliteQuery -Query $db_query -DataSource $db_data_source 
if (-not ([string]::IsNullOrEmpty($pullrequest)))
{


if ($testmodeon -eq "n")
{
$time = get-date 
Add-Content $logfile $time
$newpath = $NULL
}

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
$1900 = "1900"
if ([string]::IsNullOrEmpty($pullrequest)){$year = $1900}
IF ($year-le $1900) {$year = $1900}

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

if ($numbergrouping -eq "n")
{$newpath = $item.Path -Replace $replacepart , $moviename}
elseif ($numbergrouping -eq "y") {


IF(($moviename -eq "0") -OR ($moviename -eq "1" ) –OR ($moviename -eq "2" ) –OR ($moviename -eq "3") –OR ($moviename -eq "4" ) –OR ($moviename -eq "5") –OR ($moviename -eq "6") –OR ($moviename -eq "7") –OR ($moviename -eq "8") –OR ($moviename -eq "9"))
{
$moviename= "0-9"
}
$newpath = $item.Path -Replace $replacepart , $moviename
}
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

elseif ($selection -eq "4")
{
function Return-DropDown {
$script:Choice = $DropDown.SelectedItem.ToString()
$Form.Close()
}

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


$Form = New-Object System.Windows.Forms.Form

$Form.width = 600
$Form.height = 150
$Form.Text = 'change path'

$DropDown = new-object System.Windows.Forms.ComboBox
$DropDown.Location = new-object System.Drawing.Size(100,30)
$DropDown.Size = new-object System.Drawing.Size(130,30)

ForEach ($Item in $DropDownArray) {
[void] $DropDown.Items.Add($Item)
}

$Form.Controls.Add($DropDown)

$DropDownLabel = new-object System.Windows.Forms.Label
$DropDownLabel.Location = new-object System.Drawing.Size(10,5) 
$DropDownLabel.size = new-object System.Drawing.Size(550,25) 
$DropDownLabel.Text = $oldpath
$Form.Controls.Add($DropDownLabel)

$Button = new-object System.Windows.Forms.Button
$Button.Location = new-object System.Drawing.Size(100,50)
$Button.Size = new-object System.Drawing.Size(100,20)
$Button.Text = "Select Path"
$Button.Add_Click({Return-DropDown})
$form.Controls.Add($Button)

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()

$script:update = $choice
if (-not ([string]::IsNullOrEmpty($choice)))
{
$newpath = $oldpath -Replace $replacepart , $update }
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
$ErrorAlert = "UPDATE `Movies` SET Path = WAS NOT SET, the path was NULL"
$space = "----"


#send to log file
if ($testmodeon -eq "n"){
Add-Content $logfile $oldInfo
Add-Content $logfile $db_update
Add-Content $logfile $space
}

#Make DB changes
if ($testmodeon -eq "n"){
if (-not ([string]::IsNullOrEmpty($newpath)))
{Invoke-SqliteQuery -DataSource $db_data_source -Query $db_update}
}


#Close For each loop
}

if ($testmodeon -eq "n")
{
if ($restartservice -eq "Y"){restart-Service Radarr}
}

}
