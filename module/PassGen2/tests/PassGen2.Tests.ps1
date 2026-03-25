$moduleManifest = Join-Path -Path $PSScriptRoot -ChildPath '..\PassGen2.psd1'

Describe 'PassGen2 module' {
    BeforeAll {
        Import-Module $moduleManifest -Force
    }

    It 'exports the expected public commands' {
        $commands = Get-Command -Module PassGen2 | Select-Object -ExpandProperty Name

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

    It 'falls back to the bundled word list when the remote source is unavailable' {
        InModuleScope PassGen2 {
            $script:PassGenWordList = $null

            Mock Save-PassGenRemoteFile {
                throw 'download failed'
            }

            $wordList = Get-PassGenWordList

            $wordList | Should -Contain 'anchor'
            Should -Invoke Save-PassGenRemoteFile -Times 1
        }
    }

    It 'falls back to the bundled quote list when the remote source is unavailable' {
        InModuleScope PassGen2 {
            $script:PassGenQuoteList = $null

            Mock Save-PassGenRemoteFile {
                throw 'download failed'
            }

            $quoteList = Get-PassGenQuoteList

            $quoteList | Should -Contain 'Nobody expects the Spanish Inquisition!'
            Should -Invoke Save-PassGenRemoteFile -Times 1
        }
    }

    It 'skips invalid TEMP paths and uses the next writable location' {
        InModuleScope PassGen2 {
            $originalTemp = $env:TEMP
            $originalTmp = $env:TMP

            try {
                $env:TEMP = 'Z:\does-not-exist'
                $env:TMP = 'Z:\also-missing'

                $cachePath = Get-PassGenPath -Kind Cache

                $cachePath | Should -Not -Match '^Z:'
                (Test-Path -LiteralPath $cachePath) | Should -BeTrue
            } finally {
                $env:TEMP = $originalTemp
                $env:TMP = $originalTmp
            }
        }
    }
}
