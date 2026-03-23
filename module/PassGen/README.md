# PassGen Module

`PassGen` is a module-based rewrite of the original `PassGen.ps1` script. It preserves the existing password-generation ideas while packaging them in a form that is versioned, importable, testable, and ready for public distribution through GitHub and the PowerShell Gallery.

## Why a module

The original project is script-based and intended to be dot-sourced from a PowerShell profile. The module layout improves on that by providing:

- explicit exports
- semantic versioning
- manifest metadata for gallery distribution
- file-per-function organization
- compatibility aliases for existing short commands
- testability and cleaner documentation

The original script remains untouched. This module lives in a separate path so both approaches can coexist.

## Commands

| New command | Alias | Purpose |
| --- | --- | --- |
| `New-RandomPassword` | `pg` | Generate a random password from configurable character sets |
| `New-PassphrasePassword` | `pgw` | Generate a word-based passphrase |
| `New-MemorablePassword` | `pge` | Generate a memorable password with words, a number, and a symbol |
| `Get-MontyPythonPassword` | `pgmp` | Return a random Monty Python quote password |

## Installation

### Local development install

Import directly from the module manifest:

```powershell
$manifest = Join-Path $PWD 'module\PassGen\PassGen.psd1'
Import-Module $manifest -Force
Get-Command -Module PassGen
```

For a user-scoped local install:

```powershell
$target = Join-Path $HOME 'Documents\PowerShell\Modules\PassGen'
Copy-Item -Path .\module\PassGen -Destination $target -Recurse -Force
Import-Module PassGen -Force
```

### Future PowerShell Gallery install

When the module is published, the intended install paths are:

```powershell
Install-Module PassGen -Scope CurrentUser
```

or:

```powershell
Install-PSResource PassGen -Scope CurrentUser
```

## Usage examples

```powershell
New-RandomPassword
New-RandomPassword -Length 20 -CharacterSet LUNS -ExcludeCharacter '@','O','0'
New-PassphrasePassword
New-PassphrasePassword -WordCount 4 -Separator '_'
New-MemorablePassword -TotalLength 16
Get-MontyPythonPassword
```

All public commands return the generated string. By default they also attempt to copy the value to the clipboard and write it to a rotating log under `%TEMP%\PassGen\PassGen.log`. Use `-SkipClipboard` when clipboard integration is not wanted.
All public commands show colorized console output by default. Use `-PassThru` when you also want the generated value returned to the pipeline. Logging remains enabled and the log is rotated when it exceeds 1 MB, matching the original script behavior.

## Migration

Old usage:

```powershell
. .\PassGen.ps1
pg
pgw
pge
pgmp
```

New usage:

```powershell
Import-Module .\module\PassGen\PassGen.psd1 -Force
New-RandomPassword
New-PassphrasePassword
New-MemorablePassword
Get-MontyPythonPassword
```

Compatibility aliases are exported, so existing short commands still work after importing the module.

## Old-to-new command mapping

| Old function | New command |
| --- | --- |
| `pg` | `New-RandomPassword` |
| `pgw` | `New-PassphrasePassword` |
| `pge` | `New-MemorablePassword` |
| `pgmp` | `Get-MontyPythonPassword` |

See [MIGRATION.md](./MIGRATION.md) for migration-specific notes.
