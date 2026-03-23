function Get-PassGenQuoteList {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Refresh
    )

    if (-not $script:PassGenQuoteList -or $Refresh.IsPresent) {
        $path = Save-PassGenRemoteFile -Uri 'https://github.com/415Group-Ray/Packages/raw/main/MontyPythonQuotes.txt' -FileName 'MontyPythonQuotes.txt' -Force:$Refresh.IsPresent
        $script:PassGenQuoteList = Get-Content -LiteralPath $path
    }

    return $script:PassGenQuoteList
}
