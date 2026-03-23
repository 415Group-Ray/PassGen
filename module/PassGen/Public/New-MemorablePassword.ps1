function New-MemorablePassword {
    <#
    .SYNOPSIS
    Generates an easy-to-remember password.

    .DESCRIPTION
    Builds a memorable password from two words, one symbol, and one number.
    When a total length is specified, the command attempts to fit both words to that size.
    By default, the result is copied to the clipboard and written to the PassGen log.

    .PARAMETER TotalLength
    Specifies the total length of the generated password. Valid values are 12 through 18.

    .PARAMETER SkipClipboard
    Prevents the generated password from being copied to the clipboard.

    .PARAMETER PassThru
    Returns the generated password to the pipeline.

    .EXAMPLE
    New-MemorablePassword

    .EXAMPLE
    New-MemorablePassword -TotalLength 16
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateRange(12, 18)]
        [int]$TotalLength,

        [Parameter()]
        [switch]$SkipClipboard,

        [Parameter()]
        [switch]$PassThru
    )

    $symbols = '@','!','#','$','%','^','&','*','-','_','=','+',';',':','<','>','.','?','/','~'
    $fixedOverhead = 2
    $maxAttempts = 50
    $textInfo = (Get-Culture).TextInfo
    $wordBuckets = @{}

    foreach ($word in Get-PassGenWordList) {
        if ($word.Length -lt 4 -or $word.Length -gt 12) {
            continue
        }

        if (-not $wordBuckets.ContainsKey($word.Length)) {
            $wordBuckets[$word.Length] = New-Object System.Collections.Generic.List[string]
        }

        $null = $wordBuckets[$word.Length].Add($word)
    }

    $availableLengths = @($wordBuckets.Keys)

    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        $firstWordLength = $null
        $secondWordLength = $null

        if ($PSBoundParameters.ContainsKey('TotalLength')) {
            $targetContentLength = $TotalLength - $fixedOverhead
            $validFirstLengths = @(
                $availableLengths | Where-Object { $wordBuckets.ContainsKey($targetContentLength - $_) }
            )

            if (-not $validFirstLengths) {
                throw "No word combinations fit length $TotalLength."
            }

            $firstWordLength = $validFirstLengths | Get-Random
            $secondWordLength = $targetContentLength - $firstWordLength
        } else {
            $firstWordLength = $availableLengths | Get-Random
            $secondWordLength = $availableLengths | Get-Random
        }

        $firstWord = $textInfo.ToTitleCase(($wordBuckets[$firstWordLength] | Get-Random))
        $secondWord = $textInfo.ToTitleCase(($wordBuckets[$secondWordLength] | Get-Random))
        $number = Get-Random -Minimum 1 -Maximum 10
        $symbol = $symbols | Get-Random
        $middle = @($number, $symbol) | Get-Random -Count 2
        $password = "$firstWord$($middle[0])$secondWord$($middle[1])"

        if ($PSBoundParameters.ContainsKey('TotalLength') -and $password.Length -ne $TotalLength) {
            continue
        }

        return (Complete-PassGenResult -Value $password -DisplaySegment @(
            [pscustomobject]@{ Text = $firstWord; Color = 'Red' }
            [pscustomobject]@{ Text = [string]$middle[0]; Color = 'White' }
            [pscustomobject]@{ Text = $secondWord; Color = 'Yellow' }
            [pscustomobject]@{ Text = [string]$middle[1]; Color = 'Green' }
        ) -SkipClipboard:$SkipClipboard.IsPresent -PassThru:$PassThru.IsPresent)
    }

    throw 'Unable to generate a memorable password that satisfied the requested constraints.'
}

Set-Alias -Name pge -Value New-MemorablePassword
