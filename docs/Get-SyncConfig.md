# Get-SyncConfig

## SYNOPSIS
Retrieve an existing sync configuration (FolderPair) either setup via Set-SyncConfig or GUI

## SYNTAX

```
Get-SyncConfig [[-engineConfigPath] <Object>]
```

## DESCRIPTION
Reads the and deserializes the Synctoy configuration file

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

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

