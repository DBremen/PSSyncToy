$script:syncToyEnginePath = Resolve-Path 'c:\Program Files*\SyncToy 2.1\SyncToyEngine.dll'
if (-not $syncToyEnginePath){
    Write-Warning "The module requires SyncToy to be installed it was not found on your machine"
    #exit
}
Add-Type -Path $syncToyEnginePath
#check if the SynEngine.dll is present in the modules directory otherwise copy it over
if ( -not (Test-Path "$PSScriptRoot\SyncToyEngine.dll")){
    Copy-Item $syncToyEnginePath "$PSScriptRoot"
}

function Get-SyncConfig {
    <#
        .Synopsis
           Retrieve an existing sync configuration (FolderPair) either setup via Set-SyncConfig or GUI
        .DESCRIPTION
           Reads the and deserializes the Synctoy configuration file
        .PARAMETER EngineConfigPath
            The full-path where the SyncToy engine configuration should be saved to detaults to default SyncToy configuration path. 
            Defaults to "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin".
        .EXAMPLE
           Get-SyncConfig
    #>
    [CmdletBinding()]
    param($engineConfigPath = "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin")

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
    .PARAMETER EngineConfigPath
        The full-path where the SyncToy engine configuration should be saved to detaults to default SyncToy configuration path. 
        Defaults to "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin".
    .PARAMETER FolderPair
        The name of the Folder pair that refers to the sync configuration created.
    .PARAMETER SyncMode
        The sync operation to apply to the folder pair. One of the enumeration values from [SyncToy.SyncMode].
    .PARAMETER LeftDir
        The fullpath to the left Directory.
    .PARAMETER RightDir
        The fullpath to the right Directory.
    .PARAMETER IncludeFilePattern
         An optional Pattern to determine the files to include for the sync operation
    .PARAMETER ExcludeFilePattern
        An optional Pattern to determine the files to be excluded for the sync operation
    .PARAMETER ExcludeFileAttributes
        Determine files that should be excluded from the sync operation as determined by their attributes as a combination of Hidden, System or ReadOnly
    .PARAMETER SearchFileContent
        Switch to indicate whether SyncToy compares the file content in order to determine whether a file has changed
    .PARAMETER ExcludeSubfolders
        List of full paths that represent subfolders to be excluded from the syn operation
    .PARAMETER DeleteOverwrittenFilesPermanently
        Switch to determine whether overwritten files are not moved to the recyled Bin (default is to move to Recycle Bin)
    .PARAMETER NoRecursion
        Disable recursion for the sync operation
    .EXAMPLE
       Set-SyncConfig -FolderPairName test -LeftDir c:\left -RightDir c:\right -SyncMode [SyncToy.SyncMode]::Synchronize
#>
    [CmdletBinding()]
    param(
        $EngineConfigPath = "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin",
        [Parameter(Mandatory=$true)]
        $FolderPairName,
        [Parameter(Mandatory=$true)]
        [SyncToy.SyncMode]$SyncMode,
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (-not (Test-Path -PathType Container -LiteralPath $_ )) {
                throw "rightDir '$_' does not exist. Please provide the path to an existing Folder."
            }
            $true
        })]
        $LeftDir,
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (-not (Test-Path -PathType Container -LiteralPath $_)) {
                throw "leftDir '$_' does not exist. Please provide the path to an existing Folder."
            }
            $true
        })]
        $RightDir,
        $IncludedFilesPattern = '*',
        $ExludedFilesPattern,
        [ValidateScript({
            if (-not ($_ -in ([IO.FileAttributes]::Hidden, [IO.FileAttributes]::System, [IO.FileAttributes]::ReadOnly))) {
                throw "excludedFilesPattern '$_' does not meet requirements. Please provide a combination of [IO.FileAttributes]::Hidden, [IO.FileAttributes]::System, [IO.FileAttributes]::ReadOnly."
            }
            $true
        })]
        $ExcludedFileAttributes,
        [switch]$SearchFileContent,
        [string[]]$ExcludedSubFolders,
        [switch]$deleteOverwrittenFilesPermanently,
        [switch]$NoRecursion
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
        $shortPaths = $excludedSubFolders | ForEach-Object { $fso.getfolder($_).ShortPath }
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
     <#
        .Synopsis
           Run or preview a synchronization setup through the GUI or Set-SyncConfig
        .DESCRIPTION
           Utilizes SyncToyRunner.exe to Run or preview a synchronization setup through the GUI or Set-SyncConfig
        .PARAMETER EngineConfigPath
            The full-path where the SyncToy engine configuration should be saved to detaults to default SyncToy configuration path. 
            Defaults to "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin".
        .PARAMETER FolderPairName
            Name of the folder pair to run or preview
        .PARAMETER PreviewOnly
            Switch to indicate whether to only preview or run the sync operation for the chose folder pair.
        .EXAMPLE
           Get-SyncConfig
    #>
    [CmdletBinding()]
    param(
        $engineConfigPath = "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin",
        [Parameter(Mandatory=$true)]
        $FolderPairName,
        [switch]$PreviewOnly
    )
    $previewOnly = $previewOnly.IsPresent
    #Get engineConfig to read out settings
    $engineConfigs = Get-SyncConfig $engineConfigPath 
    $engineConfig = $engineConfigs | Where-Object {$_.Name -eq $folderPairName}
    $index = [Array]::IndexOf(($engineConfigs | Select-Object -ExpandProperty Name),$folderPairName)
    $actions = New-Object System.Collections.ArrayList
    #run the wrapper, capture actions and show progress bar
    & "$PSScriptRoot\SyncToyRunner.exe" "$engineConfigPath" $index $previewOnly | 
        Tee-Object -Variable outPut | ForEach-Object {
        if ($_.Split(',')[0] -in ([Enum]::GetNames([SyncToy.ActionCode]))){
            $progress = $_ | ConvertFrom-Csv -Header Operation, PercentComplete, Source, Destination
            [void]$actions.Add(($progress | Select-Object Operation, Source, Destination))
            $progress.Destination = $progress.Destination.Replace($engineConfig.RightDir,'')
            $progress.Source = $progress.Destination.Replace($engineConfig.LeftDir,'')
            if (!$previewOnly){
                Write-Progress -Id 1 -Activity "Syncing Folders" -CurrentOperation "$($progress.Operation) Src:$($progress.Source) Dest:$($progress.Destination)" -percentComplete $progress.PercentComplete
            }
        }
    }
    Write-Progress -Activity "Syncing Folders" -Status "Ready" -Completed -Id 1
    #parse the results of preview
    $start = ($outPut | Select-String 'Preview of').LineNumber -1
    $end = ($outPut | Select-String '^$')[0].LineNumber
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
    $results = ($output | Select-String -Pattern '\w+,\d+\.\d+,\w*')
    if ($results){
        $results = $output[$results[-1].LineNumber..($output.Length-1)]
        $htResults = @{}
        $htResults.CompletionTime = [dateTime]($results[0].Split(' .')[-4..-1] -join ' ')
        $timePart = $results[-3].Split(' .')[-2].Split(':')
        $ts = New-TimeSpan -Hours $timePart[0] -Minutes $timePart[1] -Seconds $timePart[2] 
        $htResults.TimeTaken = $ts
        $htResults.Mode = $engineConfig.SyncMode
        $htResults.Left, $htResults.Right  = $engineConfig.LeftDir, $engineConfig.RightDir
        $htResults.Options = ($results | Select-String '^\s+') -split "`n" | ForEach-Object {$_.Trim()}
        $htResults.Actions = $actions.ToArray()
        return New-Object PSObject -Property $htResults
    }
}

Export-ModuleMember -Function Get-SyncConfig, Set-SyncConfig, Invoke-Sync