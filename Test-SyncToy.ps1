#SyncToy commandline usage
#$cmdline = '-d(left="c:\left",right="c:\right",name=posh,operation=Synchronize,check=yes)'
#& 'C:\Program Files\SyncToy 2.1\SyncToy.exe' "$cmdline"



Import-Module $PSScriptRoot\SyncToy.psm1 -Force
#create folders for testing
#leftDir containing some content
$leftDir = "$env:TEMP\Left"
mkdir $leftDir | Out-Null
foreach ($num in 1..30){
    mkdir "$leftDir\test$num" | Out-Null
    foreach ($num2 in 1..10){
        $extension = '.txt'
        if ($num2 % 2){
            $extension = '.ps1'
        }
        "Test $num2" | Set-Content -Path ("$leftDir\test$num\test$num2" + $extension)
    }
}
$rightDir = "$env:TEMP\Right"
mkdir $rightDir | Out-Null

#exclude test10-test29 sub-folders from sync
$excludeFolders = (dir "$leftDir\test[1-2][0-9]" -Directory).FullName 

#setup the sync configuration
Set-SyncConfig -folderPairName 'Test' -leftDir $leftDir -rightDir $rightDir -syncMode Synchronize `
    -includedFilesPattern '*.ps1' -excludedSubFolders $excludeFolders 

#preview the sync
$previewResults = Invoke-Sync -folderPairName 'Test' -previewOnly
$previewResults
$previewResults.Action
#run the snyc
$results = Invoke-Sync -folderPairName 'Test' 
$results

