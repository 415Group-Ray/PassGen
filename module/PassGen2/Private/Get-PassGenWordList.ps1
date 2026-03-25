function Get-PassGenWordList {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Refresh
    )

    if (-not $script:PassGenWordList -or $Refresh.IsPresent) {
        $path = $null

        try {
            $path = Save-PassGenRemoteFile -Uri 'https://github.com/415Group-Ray/Packages/raw/main/WordList.txt' -FileName 'WordList.txt' -Force:$Refresh.IsPresent
        } catch {
            $fallbackPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Data\WordList.txt'
            if (-not (Test-Path -LiteralPath $fallbackPath)) {
                throw
            }

            Write-Verbose "Using bundled fallback word list because the remote source was unavailable. $($_.Exception.Message)"
            $path = $fallbackPath
        }

        $script:PassGenWordList = Get-Content -LiteralPath $path
    }

    return $script:PassGenWordList
}
