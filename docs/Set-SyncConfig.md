# Set-SyncConfig

## SYNOPSIS
Set SyncToy Configuration for a folderPair

## SYNTAX

```
Set-SyncConfig [[-EngineConfigPath] <Object>] [-FolderPairName] <Object> [-SyncMode] <SyncMode>
 [-LeftDir] <Object> [-RightDir] <Object> [[-IncludedFilesPattern] <Object>] [[-ExludedFilesPattern] <Object>]
 [[-ExcludedFileAttributes] <Object>] [-SearchFileContent] [[-ExcludedSubFolders] <String[]>]
 [-deleteOverwrittenFilesPermanently] [-NoRecursion]
```

## DESCRIPTION
Function to setup the SyncToy Configuration for a folderPair

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-SyncConfig -FolderPairName test -LeftDir c:\left -RightDir c:\right -SyncMode [SyncToy.SyncMode]::Synchronize
```

## PARAMETERS

### -EngineConfigPath
The full-path where the SyncToy engine configuration should be saved to detaults to default SyncToy configuration path. 
Defaults to "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin".

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: "$env:LOCALAPPDATA\Microsoft\SyncToy\2.0\SyncToyDirPairs.bin"
Accept pipeline input: False
Accept wildcard characters: False
```

### -FolderPairName
{{Fill FolderPairName Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SyncMode
The sync operation to apply to the folder pair.
One of the enumeration values from \[SyncToy.SyncMode\].

```yaml
Type: SyncMode
Parameter Sets: (All)
Aliases: 
Accepted values: Synchronize, Echo, Contribute, Invalid

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LeftDir
The fullpath to the left Directory.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RightDir
The fullpath to the right Directory.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludedFilesPattern
{{Fill IncludedFilesPattern Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExludedFilesPattern
{{Fill ExludedFilesPattern Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludedFileAttributes
{{Fill ExcludedFileAttributes Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchFileContent
Switch to indicate whether SyncToy compares the file content in order to determine whether a file has changed

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludedSubFolders
{{Fill ExcludedSubFolders Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -deleteOverwrittenFilesPermanently
Switch to determine whether overwritten files are not moved to the recyled Bin (default is to move to Recycle Bin)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoRecursion
Disable recursion for the sync operation

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

