function Get-PassGenWordList {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Refresh
    )

    if (-not $script:PassGenWordList -or $Refresh.IsPresent) {
        $path = Save-PassGenRemoteFile -Uri 'https://github.com/415Group-Ray/Packages/raw/main/WordList.txt' -FileName 'WordList.txt' -Force:$Refresh.IsPresent
        $script:PassGenWordList = Get-Content -LiteralPath $path
    }

    return $script:PassGenWordList
}
