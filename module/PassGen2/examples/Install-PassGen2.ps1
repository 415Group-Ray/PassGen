[CmdletBinding()]
param(
    [Parameter()]
    [string]$SourcePath = (Join-Path -Path $PSScriptRoot -ChildPath '..')
)

$moduleRoot = (Resolve-Path -Path $SourcePath).Path
$targetRoot = Join-Path -Path $HOME -ChildPath 'Documents\PowerShell\Modules\PassGen2'

Write-Verbose "Installing PassGen2 from '$moduleRoot' to '$targetRoot'."

if (Test-Path -LiteralPath $targetRoot) {
    Remove-Item -LiteralPath $targetRoot -Recurse -Force
}

Copy-Item -Path $moduleRoot -Destination $targetRoot -Recurse -Force
Import-Module (Join-Path -Path $targetRoot -ChildPath 'PassGen2.psd1') -Force

Get-Command -Module PassGen2
