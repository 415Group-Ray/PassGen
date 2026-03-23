function Get-MontyPythonPassword {
    <#
    .SYNOPSIS
    Returns a random Monty Python quote as a password.

    .DESCRIPTION
    Retrieves a random entry from the cached PassGen Monty Python quote list.
    By default, the result is copied to the clipboard and written to the PassGen log.

    .PARAMETER SkipClipboard
    Prevents the generated quote from being copied to the clipboard.

    .PARAMETER PassThru
    Returns the generated quote to the pipeline.

    .EXAMPLE
    Get-MontyPythonPassword
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$SkipClipboard,

        [Parameter()]
        [switch]$PassThru
    )

    $quote = Get-PassGenQuoteList | Get-Random
    Complete-PassGenResult -Value $quote -DisplaySegment @(
        [pscustomobject]@{ Text = $quote; Color = 'Yellow' }
    ) -SkipClipboard:$SkipClipboard.IsPresent -PassThru:$PassThru.IsPresent
}

Set-Alias -Name pgmp -Value Get-MontyPythonPassword
