function Clear-PassGenLogIfOversized {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateRange(1KB, 1GB)]
        [long]$MaximumSizeBytes = 1MB
    )

    $logPath = Get-PassGenPath -Kind Log

    if (-not (Test-Path -LiteralPath $logPath)) {
        return
    }

    $item = Get-Item -LiteralPath $logPath -ErrorAction SilentlyContinue
    if ($null -ne $item -and $item.Length -gt $MaximumSizeBytes) {
        Clear-Content -LiteralPath $logPath
    }
}
