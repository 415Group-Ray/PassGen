function Set-PassGenClipboard {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Content,

        [Parameter()]
        [ValidateRange(1, 20)]
        [int]$MaxRetries = 5,

        [Parameter()]
        [ValidateRange(1, 10)]
        [int]$DelaySeconds = 1
    )

    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            Set-Clipboard -Value $Content
            return $true
        } catch {
            Write-Verbose "Clipboard attempt $attempt of $MaxRetries failed."
            if ($attempt -lt $MaxRetries) {
                Start-Sleep -Seconds $DelaySeconds
            }
        }
    }

    return $false
}
