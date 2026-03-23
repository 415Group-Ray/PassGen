function Get-PassGenRandomWord {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateRange(1, 32)]
        [int]$MinimumLength = 5,

        [Parameter()]
        [ValidateRange(1, 32)]
        [int]$MaximumLength = 7
    )

    $words = Get-PassGenWordList | Where-Object {
        $_.Length -ge $MinimumLength -and $_.Length -le $MaximumLength
    }

    if (-not $words) {
        throw "No words were available between lengths $MinimumLength and $MaximumLength."
    }

    return ($words | Get-Random)
}
