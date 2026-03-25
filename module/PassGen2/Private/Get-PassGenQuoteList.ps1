function Get-PassGenQuoteList {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Refresh
    )

    if (-not $script:PassGenQuoteList -or $Refresh.IsPresent) {
        $path = $null

        try {
            $path = Save-PassGenRemoteFile -Uri 'https://github.com/415Group-Ray/Packages/raw/main/MontyPythonQuotes.txt' -FileName 'MontyPythonQuotes.txt' -Force:$Refresh.IsPresent
        } catch {
            $fallbackPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Data\MontyPythonQuotes.txt'
            if (-not (Test-Path -LiteralPath $fallbackPath)) {
                throw
            }

            Write-Verbose "Using bundled fallback quote list because the remote source was unavailable. $($_.Exception.Message)"
            $path = $fallbackPath
        }

        $script:PassGenQuoteList = Get-Content -LiteralPath $path
    }

    return $script:PassGenQuoteList
}
