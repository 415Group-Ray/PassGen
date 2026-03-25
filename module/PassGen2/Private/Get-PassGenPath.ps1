function Get-PassGenPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Cache', 'Log')]
        [string]$Kind
    )

    $tempCandidates = @(
        $env:TEMP
        $env:TMP
        $(if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) { Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Temp' })
        $(if (-not [string]::IsNullOrWhiteSpace($HOME)) { Join-Path -Path $HOME -ChildPath 'AppData\Local\Temp' })
        $(if ($script:ProjectRoot) { Join-Path -Path $script:ProjectRoot -ChildPath '.passgen-temp' })
        ([System.IO.Path]::GetTempPath())
    ) | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_)
    }

    $basePath = $null
    foreach ($tempRoot in $tempCandidates) {
        try {
            $candidatePath = Join-Path -Path $tempRoot -ChildPath 'PassGen' -ErrorAction Stop

            if (-not (Test-Path -LiteralPath $candidatePath -ErrorAction Stop)) {
                $null = New-Item -ItemType Directory -Path $candidatePath -Force -ErrorAction Stop
            }

            $probeFile = Join-Path -Path $candidatePath -ChildPath ([System.IO.Path]::GetRandomFileName()) -ErrorAction Stop
            $null = New-Item -ItemType File -Path $probeFile -Force -ErrorAction Stop
            Remove-Item -LiteralPath $probeFile -Force -ErrorAction Stop

            $basePath = $candidatePath
            break
        } catch {
            continue
        }
    }

    if (-not $basePath) {
        throw 'Unable to locate a writable temporary directory for PassGen.'
    }

    switch ($Kind) {
        'Cache' { return $basePath }
        'Log' { return (Join-Path -Path $basePath -ChildPath 'PassGen.log') }
    }
}
