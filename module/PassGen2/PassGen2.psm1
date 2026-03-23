$script:ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ProjectRoot = Split-Path -Parent $script:ModuleRoot

$privatePath = Join-Path -Path $script:ModuleRoot -ChildPath 'Private'
$publicPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Public'

foreach ($path in @($privatePath, $publicPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        continue
    }

    Get-ChildItem -LiteralPath $path -Filter '*.ps1' -File |
        Sort-Object -Property Name |
        ForEach-Object {
            . $_.FullName
        }
}

$publicFunctions = Get-ChildItem -LiteralPath $publicPath -Filter '*.ps1' -File |
    Sort-Object -Property BaseName |
    ForEach-Object {
        $_.BaseName
    }

Export-ModuleMember -Function $publicFunctions -Alias @('pg', 'pgw', 'pge', 'pgmp')
