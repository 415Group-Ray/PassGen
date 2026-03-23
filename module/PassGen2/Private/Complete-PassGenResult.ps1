function Complete-PassGenResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [Parameter()]
        [object[]]$DisplaySegment,

        [Parameter()]
        [switch]$SkipClipboard,

        [Parameter()]
        [switch]$PassThru
    )

    $clipboardSucceeded = $false

    if (-not $SkipClipboard) {
        $clipboardSucceeded = Set-PassGenClipboard -Content $Value
        if (-not $clipboardSucceeded) {
            Write-Warning 'Failed to set the clipboard after multiple attempts.'
        } else {
            Write-Verbose 'Password copied to the clipboard.'
        }
    }

    Write-PassGenLog -Value $Value

    if ($DisplaySegment) {
        Write-PassGenDisplay -Segment $DisplaySegment -ClipboardSucceeded:$clipboardSucceeded
    }

    if ($PassThru) {
        return $Value
    }
}
