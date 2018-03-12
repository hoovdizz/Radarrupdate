# Radarrupdate
Updates the path of Radarr Movies with the first letter of the movie


I prefer my movies in the following format

#selection 0 aka Alpha Numeric
#\Plex\DVDs\P\Primer [2004]

#selection 1 aka year
#\Plex\DVDs\2004\Primer [2004]

#selection 2 aka Decade
#\Plex\DVDs\2000s\Primer [2004]

#selection 3 aka genres
#\Plex\DVDs\Science Fiction\Primer [2004]



Instead of

X:\Plex\DVDs\Radarr\Primer [2004]


To make this work with your machine (windows)
ensure you have version 5 of PowerShell.
this can be checked by opening power and typing " $PSVersionTable "
PS Version should be 5.0 or higher.

if not you can download it from this link

https://www.microsoft.com/en-us/download/details.aspx?id=50395

once installed Reboot

once compliant install PSSQLite module
one time run of " Install-Module pssqlite -Scope CurrentUser -Force"

Variables you will want to change (maybe)


$db_data_source = where you RadarrDB

$replacepart =radarr (the temp folder)

$logfile = (where you want to keep you log file)

then set a task to run it every morning. 


This is Ideally for lists. Set the “list” to save to this temp folder, and
NOT monitor by default. The Script will adjust the path, and set to monitor. 
