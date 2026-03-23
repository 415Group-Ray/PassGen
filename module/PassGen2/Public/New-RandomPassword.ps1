function New-RandomPassword {
    <#
    .SYNOPSIS
    Generates a random password string.

    .DESCRIPTION
    Creates a random password using configurable character sets and optional exclusions.
    By default, the generated value is copied to the clipboard and written to the PassGen log.

    .PARAMETER Length
    Specifies the total length of the password.

    .PARAMETER CharacterSet
    Specifies which character sets are allowed. Uppercase tokens indicate a required category.
    Valid tokens are U, L, N, and S.

    .PARAMETER ExcludeCharacter
    Characters to exclude from the generated password.

    .PARAMETER SkipClipboard
    Prevents the generated password from being copied to the clipboard.

    .PARAMETER PassThru
    Returns the generated password to the pipeline.

    .EXAMPLE
    New-RandomPassword

    .EXAMPLE
    New-RandomPassword -Length 20 -CharacterSet LUNS -ExcludeCharacter '@','O','0'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateRange(1, 256)]
        [int]$Length = 12,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string[]]$CharacterSet = @('ULNS'),

        [Parameter()]
        [char[]]$ExcludeCharacter,

        [Parameter()]
        [switch]$SkipClipboard,

        [Parameter()]
        [switch]$PassThru
    )

    $tokenSets = @{
        U = [char[]]'ABCDEFGHJKLMNPQRSTUVWXYZ'
        L = [char[]]'abcdefghijkmnopqrstuvwxyz'
        N = [char[]]'23456789'
        S = [char[]]'!@#$%^&*()-+=.:;<>?_'
    }

    $requiredCharacters = New-Object System.Collections.Generic.List[char]
    $availableCharacters = New-Object System.Collections.Generic.List[char]

    $characterTokens = New-Object System.Collections.Generic.List[string]
    foreach ($value in $CharacterSet) {
        foreach ($token in [char[]]$value) {
            $tokenText = [string]$token
            if ($tokenText -notmatch '^[ULNSulns]$') {
                throw "CharacterSet contains unsupported token '$tokenText'. Valid tokens are U, L, N, and S."
            }

            if ($characterTokens -notcontains $tokenText) {
                $null = $characterTokens.Add($tokenText)
            }
        }
    }

    foreach ($token in $characterTokens) {
        $filteredCharacters = @(
            $tokenSets[$token.ToUpperInvariant()] | Where-Object { $ExcludeCharacter -cnotcontains $_ }
        )

        if (-not $filteredCharacters) {
            throw "Character set '$token' does not contain any usable characters after exclusions."
        }

        foreach ($character in $filteredCharacters) {
            $null = $availableCharacters.Add($character)
        }

        if ($token -cmatch '^[A-Z]$') {
            $null = $requiredCharacters.Add(($filteredCharacters | Get-Random))
        }
    }

    if ($requiredCharacters.Count -gt $Length) {
        throw "Length '$Length' is too short for the number of required character sets."
    }

    $characters = New-Object System.Collections.Generic.List[char]
    foreach ($character in $requiredCharacters) {
        $null = $characters.Add($character)
    }

    while ($characters.Count -lt $Length) {
        $null = $characters.Add(($availableCharacters | Get-Random))
    }

    $password = -join (Shuffle-PassGenArray -InputObject $characters.ToArray())
    Complete-PassGenResult -Value $password -DisplaySegment @(
        [pscustomobject]@{ Text = $password; Color = 'Red' }
    ) -SkipClipboard:$SkipClipboard.IsPresent -PassThru:$PassThru.IsPresent
}

Set-Alias -Name pg -Value New-RandomPassword
