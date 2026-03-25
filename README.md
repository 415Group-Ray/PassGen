# PassGen

`PassGen` is the source repository for the published PowerShell module `PassGen2`, which generates random passwords, multi-word passphrases, memorable mixed passwords, and Monty Python quote passwords.

## Current module

The supported module name is `PassGen2`. It is published to the PowerShell Gallery and can be installed or imported directly by that name.

## Features

- Random passwords with configurable length, character sets, and excluded characters
- Multi-word passphrases with configurable word count and separator
- Memorable passwords built from words, numbers, and symbols
- Monty Python quote passwords
- Compatibility aliases for the original short commands: `pg`, `pgw`, `pge`, and `pgmp`
- Clipboard copy by default, optional pipeline output with `-PassThru`, and rotating log output under `%TEMP%\PassGen\PassGen.log`
- Cached support files that refresh automatically, with bundled fallback data when the remote files are unavailable

## Requirements

- PowerShell 5.1 or later
- Clipboard access if you want automatic copy-to-clipboard behavior
- Internet access is optional: the module can refresh cached support files from GitHub, but bundled data is included as a fallback

## Installation

Install from the PowerShell Gallery:

```powershell
Install-Module PassGen2 -Scope CurrentUser
Import-Module PassGen2
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
```

## Usage

Use either the full command names or the legacy aliases after importing `PassGen2`.

```powershell
New-RandomPassword
New-RandomPassword -Length 20 -CharacterSet LUNS -ExcludeCharacter '@','O','0'

New-PassphrasePassword
New-PassphrasePassword -WordCount 4 -Separator '_'

New-MemorablePassword
New-MemorablePassword -TotalLength 16

Get-MontyPythonPassword
```

Alias examples:

```powershell
pg
pgw
pge
pgmp
```

## Notes

- Commands copy the generated value to the clipboard unless you use `-SkipClipboard`
- Commands return colorized console output by default; use `-PassThru` when you also want the generated value returned to the pipeline
- Cached files are stored under the PassGen temp directory and refreshed every 7 days by default
- The original script-based implementation is still in this repository for reference, but `PassGen2` is the supported install/import experience
