# SearchLucene
Using [Microsoft SyncToy](https://www.microsoft.com/en-us/download/details.aspx?id=15155) through PowerShell.
See [Link to my blog post](https://powershellone.wordpress.com/2015/09/25/using-microsoft-synctoy-through-powershell/) for more details

SyncToy has been around already since good old Windows XP times and even though there are alternative freeware applications it’s still one of my favorite tools for the job.
While SyncToy already comes with a commandline version out of the box, it’s lacking quite some features as compared to the graphical user interface:

* No option to preview the sync operation
* No progress indication
* No option to exclude subfolders
* No option to exclude files by attributes (e.g. hidden, system)
* No option to specify recursion
* No option to specify action for overwritten files

After many unscucessful attempts utilizing the SyncToyEngine.dll .NET assembly that comes with the SyncToy installation, 
I ended up writing a C# executable (SyncToyRunner.exe) that only takes care of the synchronization and preview part, since I wanted to keep as much as possible of the code in PowerShell. 

| Function/File | Synopsis | Documentation |
| --- | --- | --- |
| SyncToyRunner.exe | C# that handles synchronization and preview part (see above) ||
| Generate-ScriptMarkdownHelp | Function that generated the markdown help for the module using platyPS ||
| Use-SyncToyModule | Example usage for the module ||
| Get-SyncConfig | Retrieve an existing sync configuration (FolderPair) either setup via Set-SyncConfig or GUI | [Link](https://github.com/DBremen/SyncToy/blob/master/docs/Get-SyncConfig.md) |
| Invoke-Sync | Run or preview a synchronization setup through the GUI or Set-SyncConfig | [Link](https://github.com/DBremen/SyncToy/blob/master/docs/Invoke-Sync.md) |
| Set-SyncConfig | Set SyncToy Configuration for a folderPair | [Link](https://github.com/DBremen/SyncToy/blob/master/docs/Set-SyncConfig.md) |
