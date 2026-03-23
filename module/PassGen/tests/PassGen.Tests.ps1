$moduleManifest = Join-Path -Path $PSScriptRoot -ChildPath '..\PassGen.psd1'

Describe 'PassGen module' {
    BeforeAll {
        Import-Module $moduleManifest -Force
    }

    It 'exports the expected public commands' {
        $commands = Get-Command -Module PassGen | Select-Object -ExpandProperty Name

        $commands | Should -Contain 'New-RandomPassword'
        $commands | Should -Contain 'New-PassphrasePassword'
        $commands | Should -Contain 'New-MemorablePassword'
        $commands | Should -Contain 'Get-MontyPythonPassword'
    }

    It 'exports compatibility aliases' {
        (Get-Alias -Name pg).Definition | Should -Be 'New-RandomPassword'
        (Get-Alias -Name pgw).Definition | Should -Be 'New-PassphrasePassword'
        (Get-Alias -Name pge).Definition | Should -Be 'New-MemorablePassword'
        (Get-Alias -Name pgmp).Definition | Should -Be 'Get-MontyPythonPassword'
    }

    It 'generates random passwords at the requested length when PassThru is used' {
        $password = New-RandomPassword -Length 24 -SkipClipboard -PassThru
        $password.Length | Should -Be 24
    }

    It 'accepts compact character set tokens without commas' {
        $password = New-RandomPassword -Length 12 -CharacterSet LUNS -SkipClipboard -PassThru
        $password.Length | Should -Be 12
    }

    It 'does not write the password to the pipeline unless PassThru is used' {
        $password = New-RandomPassword -Length 12 -SkipClipboard
        $password | Should -BeNullOrEmpty
    }
}
