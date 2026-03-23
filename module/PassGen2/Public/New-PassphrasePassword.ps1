function New-PassphrasePassword {
    <#
    .SYNOPSIS
    Generates a multi-word passphrase.

    .DESCRIPTION
    Selects random words from the cached PassGen word list and joins them with a separator.
    By default, the result is copied to the clipboard and written to the PassGen log.

    .PARAMETER WordCount
    Specifies how many words to include in the passphrase.

    .PARAMETER Separator
    Specifies the separator placed between words.

    .PARAMETER TitleCase
    Converts each selected word to title case.

    .PARAMETER SkipClipboard
    Prevents the generated passphrase from being copied to the clipboard.

    .PARAMETER PassThru
    Returns the generated passphrase to the pipeline.

    .EXAMPLE
    New-PassphrasePassword

    .EXAMPLE
    New-PassphrasePassword -WordCount 4 -Separator '_'
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateRange(2, 10)]
        [int]$WordCount = 3,

        [Parameter()]
        [ValidateNotNull()]
        [string]$Separator = '-',

        [Parameter()]
        [switch]$TitleCase = $true,

        [Parameter()]
        [switch]$SkipClipboard,

        [Parameter()]
        [switch]$PassThru
    )

    $textInfo = (Get-Culture).TextInfo
    $words = for ($index = 0; $index -lt $WordCount; $index++) {
        $word = Get-PassGenRandomWord
        if ($TitleCase) {
            $textInfo.ToTitleCase($word)
            continue
        }

        $word
    }

    $passphrase = $words -join $Separator
    $displaySegment = @()
    $wordColors = @(
        'Red'
        'Yellow'
        'Green'
        'Cyan'
        'Magenta'
        'Blue'
        'White'
    )

    for ($index = 0; $index -lt $words.Count; $index++) {
        $color = $wordColors[$index % $wordColors.Count]

        $displaySegment += [pscustomobject]@{ Text = $words[$index]; Color = $color }

        if ($index -lt ($words.Count - 1)) {
            $displaySegment += [pscustomobject]@{ Text = $Separator; Color = 'White' }
        }
    }

    Complete-PassGenResult -Value $passphrase -DisplaySegment $displaySegment -SkipClipboard:$SkipClipboard.IsPresent -PassThru:$PassThru.IsPresent
}

Set-Alias -Name pgw -Value New-PassphrasePassword
