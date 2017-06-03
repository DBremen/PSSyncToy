function Generate-ScriptMarkdownHelp{
    <#    
    .SYNOPSIS
        The function that generated the Markdown help in this repository.
        Generates markdown help for each function containing comment based help in the module (Description not empty) within a folder recursively and a summary table for the main README.md
    .DESCRIPTION
        platyPS is used to generate the function level help + the README.md is generated "manually".
	.PARAMETER Path
		Path to the module to create the documentation for
    .PARAMETER RepoUrl
        Url for the Git repository homepage
	.EXAMPLE
       Generate-ScriptMarkdownHelp -Path C:\Scripts\ps1\SyncToy\SyncToy.psm1 -RepoUrl https://github.com/DBremen/SyncToy
#>
    [CmdletBinding()]
    Param($Path,$RepoUrl)
    $summaryTable = @'
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
'@
    Import-Module platyps
    $htCheck = @{}
    Import-Module $Path
    $Module = [IO.Path]::GetFileNameWithoutExtension($Path)
    $functions = Get-Command -Module $Module
    foreach ($function in $functions){
        try{
            $help =Get-Help $function.Name | Where-Object {$_.Name -eq $function.Name} -ErrorAction Stop
        }catch{
            continue
        }
        if ($help.description -ne $null){
            $htCheck[$function.Name] += 1
            $link = $help.relatedLinks 
            if ($link){
                $link = $link.navigationLink.uri | Where-Object {$_ -like '*powershellone*'}
            }
            $mdFile = $function.Name + '.md'
            $summaryTable += "`n| $($function.Name) | $($help.Synopsis) | $("[Link]($($repoUrl)/blob/master/docs/$mdFile)") |"
        }
    }
    $docFolder = "$(Split-Path (Get-Module $Module)[0].Path)\docs"
    $summaryTable | Set-Content "$(Split-Path $docFolder -Parent)/README.md" -Force
    $documenation = New-MarkdownHelp -Module $Module -OutputFolder $docFolder -Force
    foreach ($file in (dir $docFolder)){
        $text = (Get-Content -Path $file.FullName | Select-Object -Skip 6) | Set-Content $file.FullName -Force
    }
    #sanity check if help file were generated for each script
    [PSCustomObject]$htCheck
}
 Generate-ScriptMarkdownHelp -Path C:\Scripts\ps1\SyncToy\SyncToy.psm1 -RepoUrl https://github.com/DBremen/SyncToy