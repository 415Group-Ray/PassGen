# Migration Notes

## Summary

The repository now contains two parallel implementations:

- the original script: `PassGen.ps1`
- the new module: `module\PassGen\PassGen.psd1`

The original script remains intact. The new module is the path intended for public distribution and future gallery publishing.

## Old usage

```powershell
. .\PassGen.ps1
pg
pgw
pge
pgmp
```

## New usage

```powershell
Import-Module .\module\PassGen\PassGen.psd1 -Force
New-RandomPassword
New-PassphrasePassword
New-MemorablePassword
Get-MontyPythonPassword
```

## Command mapping

| Old name | New command | Notes |
| --- | --- | --- |
| `pg` | `New-RandomPassword` | Alias `pg` is exported for backward compatibility |
| `pgw` | `New-PassphrasePassword` | Alias `pgw` is exported for backward compatibility |
| `pge` | `New-MemorablePassword` | Alias `pge` is exported for backward compatibility |
| `pgmp` | `Get-MontyPythonPassword` | Alias `pgmp` is exported for backward compatibility |

## Behavioral notes

- Module commands return strings instead of writing display-oriented output with `Write-Host`
- Clipboard copy remains enabled by default, with `-SkipClipboard` available for automation scenarios
- Support files are downloaded lazily when first needed instead of during module import
- Logging remains enabled and is written to `%TEMP%\PassGen\PassGen.log`
