# Radarrupdate
Updates the path of Radarr Movies with the first letter of the movie


This helps with the addition of "list support"
i perfer my movies in the following format
X:\Plex\DVDs\Z\Zootopia [2016]
X:\Plex\DVDs\S\Scream [1996]
X:\Plex\DVDs\G\Gremlins [1984]

instead of
X:\Plex\DVDs\Radarr\Zootopia [2016]
X:\Plex\DVDs\Radarr\Scream [1996]
X:\Plex\DVDs\Radarr\Gremlins [1984]

To make this work with your machine (windows)
ensure you have version 5 of powershell.
this can be checked by oping power and typing " $PSVersionTable "
PS Version should be 5.0 or higher.

if not you can download it from this link

https://www.microsoft.com/en-us/download/details.aspx?id=50395

once installed Reboot

once compliant install PSSQLite modle
one time run of " Install-Module pssqlite -Scope CurrentUser -Force"

Variables you will want to change (maybe)
$db_data_source = where you RadarrDB
$replacepart =radarr  (the temp folder)
$logfile = (where you want to keep you log file)

then set a task to run it everymorning. 
