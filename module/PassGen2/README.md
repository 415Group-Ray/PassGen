# PassGen2

`PassGen2` is a published PowerShell module for generating random passwords, passphrases, memorable passwords, and Monty Python quote passwords.

## Commands

| Command | Alias | Purpose |
| --- | --- | --- |
| `New-RandomPassword` | `pg` | Generate a random password from configurable character sets |
| `New-PassphrasePassword` | `pgw` | Generate a word-based passphrase |
| `New-MemorablePassword` | `pge` | Generate a memorable password with words, a number, and a symbol |
| `Get-MontyPythonPassword` | `pgmp` | Return a random Monty Python quote password |

## Features

- PowerShell Gallery distribution as `PassGen2`
- PowerShell 5.1+ compatible
- Clipboard copy by default with `-SkipClipboard` opt-out
- Optional pipeline return with `-PassThru`
- Rotating log file under `%TEMP%\PassGen\PassGen.log`
- Support-file caching with a 7-day refresh window
- Bundled fallback word and quote lists when remote refresh is unavailable

## Installation

Install from the PowerShell Gallery:

```powershell
Install-Module PassGen2 -Scope CurrentUser
Import-Module PassGen2
Get-Command -Module PassGen2
```

Or with PSResourceGet:

```powershell
Install-PSResource PassGen2 -Scope CurrentUser
Import-Module PassGen2
```

For local development from this repository:

```powershell
$manifest = Join-Path $PWD 'module\PassGen2\PassGen2.psd1'
Import-Module $manifest -Force
Get-Command -Module PassGen2
```

## Usage examples

```powershell
New-RandomPassword
New-RandomPassword -Length 20 -CharacterSet LUNS -ExcludeCharacter '@','O','0'

New-PassphrasePassword
New-PassphrasePassword -WordCount 4 -Separator '_'

New-MemorablePassword
New-MemorablePassword -TotalLength 16

Get-MontyPythonPassword
```

Legacy aliases are still exported:

```powershell
pg
pgw
pge
pgmp
```

## Behavior notes

- `New-RandomPassword` accepts `U`, `L`, `N`, and `S` tokens in `-CharacterSet`; uppercase tokens mark required character categories
- `New-PassphrasePassword` uses 3 title-cased words separated by `-` by default
- `New-MemorablePassword` builds a password from two words plus one number and one symbol; `-TotalLength` supports values from 12 to 18
- All public commands attempt to copy the generated value to the clipboard and write to the PassGen log unless `-SkipClipboard` is used
- Use `-PassThru` if you also want the generated value emitted to the pipeline

## Migration

If you used the original script-based commands, the module keeps the same short aliases after import:

```powershell
Import-Module PassGen2
pg
pgw
pge
pgmp
```

Use the full command names for scripts, automation, and discoverability. See [MIGRATION.md](./MIGRATION.md) for additional migration notes.
