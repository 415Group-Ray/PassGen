function Write-PassGenLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Value
    )

    Clear-PassGenLogIfOversized
    $logPath = Get-PassGenPath -Kind Log
    $timestamp = Get-Date -Format 'MM/dd/yyyy - hh:mm:ss tt'
    Add-Content -LiteralPath $logPath -Value "$timestamp`: $Value"
}
