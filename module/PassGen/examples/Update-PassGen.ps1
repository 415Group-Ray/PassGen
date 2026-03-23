[CmdletBinding()]
param(
    [Parameter()]
    [string]$ModuleName = 'PassGen'
)

$installed = Get-Module -ListAvailable -Name $ModuleName | Sort-Object Version -Descending | Select-Object -First 1

if ($installed) {
    Write-Verbose "Removing loaded module '$ModuleName' before update."
    Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
}

if (Get-Command -Name Update-PSResource -ErrorAction SilentlyContinue) {
    Update-PSResource -Name $ModuleName -Scope CurrentUser
    return
}

if (Get-Command -Name Update-Module -ErrorAction SilentlyContinue) {
    Update-Module -Name $ModuleName -Scope CurrentUser
    return
}

throw 'Neither Update-PSResource nor Update-Module is available in this session.'
