# Invoke-Sync

## SYNOPSIS
Run or preview a synchronization setup through the GUI or Set-SyncConfig

## SYNTAX

```
Invoke-Sync [[-engineConfigPath] <Object>] [-FolderPairName] <Object> [-PreviewOnly]
```

## DESCRIPTION
Utilizes SyncToyRunner.exe to Run or preview a synchronization setup through the GUI or Set-SyncConfig

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-SyncConfig
```

## PARAMETERS

### -engineConfigPath
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
Name of the folder pair to run or preview

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

### -PreviewOnly
Switch to indicate whether to only preview or run the sync operation for the chose folder pair.

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

