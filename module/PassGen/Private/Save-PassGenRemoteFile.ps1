function Save-PassGenRemoteFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Uri,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName,

        [Parameter()]
        [ValidateRange(0, 3650)]
        [int]$RefreshAfterDays = 7,

        [Parameter()]
        [switch]$Force
    )

    $cachePath = Get-PassGenPath -Kind Cache
    $targetPath = Join-Path -Path $cachePath -ChildPath $FileName

    $needsDownload = $Force.IsPresent -or -not (Test-Path -LiteralPath $targetPath)

    if (-not $needsDownload -and $RefreshAfterDays -gt 0) {
        $age = (Get-Date) - (Get-Item -LiteralPath $targetPath).LastWriteTime
        if ($age.TotalDays -gt $RefreshAfterDays) {
            $needsDownload = $true
        }
    }

    if (-not $needsDownload) {
        return $targetPath
    }

    Write-Verbose "Downloading support file '$FileName' from '$Uri'."

    $previousProtocol = [Net.ServicePointManager]::SecurityProtocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($Uri, $targetPath)
    } catch {
        throw "Failed to download '$FileName' from '$Uri'. $($_.Exception.Message)"
    } finally {
        if ($null -ne $webClient) {
            $webClient.Dispose()
        }

        [Net.ServicePointManager]::SecurityProtocol = $previousProtocol
    }

    return $targetPath
}
