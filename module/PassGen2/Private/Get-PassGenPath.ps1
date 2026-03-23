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

    $tempRoot = $tempCandidates | Select-Object -First 1

    if (-not $tempRoot) {
        throw 'Unable to locate a writable temporary directory for PassGen.'
    }

    $basePath = Join-Path -Path $tempRoot -ChildPath 'PassGen'

    if (-not (Test-Path -LiteralPath $basePath)) {
        $null = New-Item -ItemType Directory -Path $basePath -Force
    }

    switch ($Kind) {
        'Cache' { return $basePath }
        'Log' { return (Join-Path -Path $basePath -ChildPath 'PassGen.log') }
    }
}
