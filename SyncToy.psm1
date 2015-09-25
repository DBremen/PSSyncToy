$script:syncToyEnginePath = Resolve-Path 'c:\Program Files*\SyncToy 2.1\SyncToyEngine.dll'
Add-Type -Path $syncToyEnginePath

function Get-SyncConfig ($engineConfigPath = "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin"){
    $engineConfigs = New-Object System.Collections.ArrayList
    $bf = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter 
    $sr = New-Object IO.StreamReader($engineConfigPath)
    do{
        $seConfig = [SyncToy.SyncEngineConfig]$bf.Deserialize($sr.BaseStream)
        [void]$engineConfigs.Add($seConfig)
    }
    while($sr.BaseStream.Position -lt $sr.BaseStream.Length)
    $sr.Close()
    $sr.Dispose()
    $engineConfigs
}


function Set-SyncConfig {
<#
.Synopsis
   Set SyncToy Configuration for a folderPair
.DESCRIPTION
   Function to setup the SyncToy Configuration for a folderPair
.EXAMPLE
   Set-SyncConfig -FolderPairName test -LeftDir c:\left -RightDir c:\right -SyncMode [SyncToy.SyncMode]::Synchronize
#>
    [CmdletBinding()]
    param(
        #The full-path where the SyncToy engine configuration should be saved to detaults to default SyncToy configuration path
        $engineConfigPath = "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin",

        #The name of the Folder pair
        [Parameter(Mandatory=$true)]
        $folderPairName,

        #The sync operation to apply to the folder pair
        [Parameter(Mandatory=$true)]
        [SyncToy.SyncMode]$syncMode,

        #The fullpath to the left Directory
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (-not (Test-Path -PathType Container -LiteralPath $_ )) {
                throw "rightDir '$_' does not exist. Please provide the path to an existing Folder."
            }
            $true
        })]
        $leftDir,

        #The fullpath to the right Directory
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (-not (Test-Path -PathType Container -LiteralPath $_)) {
                throw "leftDir '$_' does not exist. Please provide the path to an existing Folder."
            }
            $true
        })]
        $rightDir,

        #An optional Pattern to determine the files to include for the sync operation
        $includedFilesPattern = '*',

        #An optional Pattern to determine the files to be excluded for the sync operation
        $exludedFilesPattern,

        #Determine files that should be excluded from the sync operation as determined by their attributes as a combination of Hidden, System or ReadOnly
        [ValidateScript({
            if (-not ($_ -in ([IO.FileAttributes]::Hidden, [IO.FileAttributes]::System, [IO.FileAttributes]::ReadOnly))) {
                throw "excludedFilesPattern '$_' does not meet requirements. Please provide a combination of [IO.FileAttributes]::Hidden, [IO.FileAttributes]::System, [IO.FileAttributes]::ReadOnly."
            }
            $true
        })]
        $excludedFileAttributes,

        #Switch to indicate whether SyncToy compares the file content in order to determine whether a file has changed
        [switch]$searchFileContent,

        #List of full paths that represent subfolders to be excluded from the syn operation
        [string[]]$excludedSubFolders,

        #Switch to determine whether overwritten files are not moved to the recyled Bin (default is to move to Recycle Bin)
        [switch]$deleteOverwrittenFilesPermanently,

        #Disable recursion for the sync operation
        [switch]$noRecursion

    )
    $seConfig = New-Object SyncToy.SyncEngineConfig
    #set props
    $seConfig.Name = $folderPairName
    $seConfig.SyncMode = $syncMode
    $seConfig.LeftDir = $leftDir
    $seConfig.RightDir = $rightDir
    $seConfig.SearchPattern = $includedFilesPattern
    if ($exludedFilesPattern) { $seConfig.ExcludedPattern = $exludedFilesPattern }
    if ($excludedFileAttributes) { $seConfig.ExcludedFileAttributes = $excludedFileAttributes }
    $seConfig.ComputeHash = $searchFileContent.IsPresent
    if ($excludedSubFolders){ 
        $dirs = New-Object SyncToy.ExceptionalDirList
        #convert the folder paths to shortpaths
        $fso = New-Object -ComObject Scripting.FileSystemObject
        $shortPaths = $excludedSubFolders | foreach { $fso.getfolder($_).ShortPath }
        $dirs.LeftDirectories.AddRange(@($shortPaths))
        $dirs.RightDirectories.AddRange(@($shortPaths))
        $seConfig.ExceptionalDirs = $dirs 
    }
    $seConfig.BackupOlderFile = !($deleteOverwrittenFilesPermanently.IsPresent)
    $recursion = [SyncToy.RecurseMode]::All
    if ($noRecursion.IsPresent) { $recursion = [SyncToy.RecurseMode]::None }
    $seConfig.Recursion = $recursion
    #save 
    $fs = New-Object IO.FileStream($engineConfigPath,[IO.FileMode]::Create)
    $bf = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter
    try{
        $existingConfig = Get-SyncConfig $engineConfigPath
    }catch{
    }
    if ($existingConfig){ 
        $seConfig = @($existingConfig) + $seConfig
    }
    foreach($config in $seConfig){
        $bf.Serialize($fs, $config)
    }
    $fs.Close()
    $fs.Dispose()
}

function Invoke-Sync {
    [CmdletBinding()]
    param(
        $engineConfigPath = "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin",
        [Parameter(Mandatory=$true)]
        $folderPairName,
        [switch]$previewOnly
    )
    $previewOnly = $previewOnly.IsPresent
    #Get engineConfig to read out settings
    $engineConfigs = Get-SyncConfig $engineConfigPath 
    $engineConfig = $engineConfigs | where {$_.Name -eq $folderPairName}
    $index = [Array]::IndexOf(($engineConfigs | select -ExpandProperty Name),$folderPairName)
    $actions = New-Object System.Collections.ArrayList
    #run the wrapper, capture actions and show progress bar
    & "$PSScriptRoot\SyncToyRunner.exe" "$engineConfigPath" $index $previewOnly | 
        Tee-Object -Variable outPut | foreach {
        if ($_.Split(',')[0] -in ([Enum]::GetNames([SyncToy.ActionCode]))){
            $progress = $_ | ConvertFrom-Csv -Header Operation, PercentComplete, Source, Destination
            [void]$actions.Add(($progress | select Operation, Source, Destination))
            $progress.Destination = $progress.Destination.Replace($engineConfig.RightDir,'')
            $progress.Source = $progress.Destination.Replace($engineConfig.LeftDir,'')
            if (!$previewOnly){
                Write-Progress -Id 1 -Activity "Syncing Folders" -CurrentOperation "$($progress.Operation) Src:$($progress.Source) Dest:$($progress.Destination)" -percentComplete $progress.PercentComplete
            }
        }
    }
    Write-Progress -Activity "Syncing Folders" -Status "Ready" -Completed -Id 1
    #parse the results of preview
    $start = ($outPut | sls 'Preview of').LineNumber -1
    $end = ($outPut | sls '^$')[0].LineNumber
    if ($start -gt 1){
        $preview = $output[$start..$end]
        $index = 1
        $htPreview = @{}
        foreach ($line in $preview){
            switch ($index){
            1     {
                    $htPreview.Left, $htPreview.Right  = $engineConfig.LeftDir, $engineConfig.RightDir
                    $htPreview.TimeTaken = $line.Split('')[-1].Replace('.','')
            }
            3     { $htPreview.NumActions = [RegEx]::Match($line ,'\d+').Groups[0] }
            4     { $htPreview.NoActionRequired = [RegEx]::Match($line ,'\d+,').Groups[0].Value }
            }
            $index++  
        }
        $htPreview.Mode = $engineConfig.SyncMode
        if ($previewOnly){
            $htPreview.Actions = $actions.ToArray()
        }
        return New-Object PSObject -Property $htPreview
    }
   
    #results
    $results = ($output | sls -Pattern '\w+,\d+\.\d+,\w*')
    if ($results){
        $results = $output[$results[-1].LineNumber..($output.Length-1)]
        $htResults = @{}
        $htResults.CompletionTime = [dateTime]($results[0].Split(' .')[-4..-1] -join ' ')
        $timePart = $results[-3].Split(' .')[-2].Split(':')
        $ts = New-TimeSpan -Hours $timePart[0] -Minutes $timePart[1] -Seconds $timePart[2] 
        $htResults.TimeTaken = $ts
        $htResults.CopiedSize 
        $htResults.Speed 
        $htResults.Mode = $engineConfig.SyncMode
        $htResults.Left, $htResults.Right  = $engineConfig.LeftDir, $engineConfig.RightDir
        $htResults.Options = ($results | sls '^\s+') -split "`n" | foreach {$_.Trim()}
        $htResults.Actions = $actions.ToArray()
        return New-Object PSObject -Property $htResults
    }
}

Export-ModuleMember -Function Get-SyncConfig, Set-SyncConfig, Invoke-Sync