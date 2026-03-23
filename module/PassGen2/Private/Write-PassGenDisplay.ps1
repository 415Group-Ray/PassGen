function Write-PassGenDisplay {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Segment,

        [Parameter()]
        [switch]$ClipboardSucceeded
    )

    if ($ClipboardSucceeded) {
        Write-Host 'Password added to clipboard: ' -ForegroundColor Cyan -NoNewline
    } else {
        Write-Host 'Generated password: ' -ForegroundColor Cyan -NoNewline
    }

    foreach ($item in $Segment) {
        if ($null -eq $item) {
            continue
        }

        Write-Host $item.Text -ForegroundColor $item.Color -NoNewline
    }

    Write-Host ''
}
