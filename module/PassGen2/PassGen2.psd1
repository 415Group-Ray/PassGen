@{
    RootModule           = 'PassGen2.psm1'
    ModuleVersion        = '1.0.0'
    GUID                 = 'fe6c764e-8bfc-4f0c-8834-16fec4f95e2a'
    Author               = 'Ray Smalley'
    CompanyName          = '415Group-Ray'
    Copyright            = '(c) Ray Smalley. All rights reserved.'
    Description          = 'PassGen2 is a public PowerShell module for generating random passwords, passphrases, and memorable password variants.'
    PowerShellVersion    = '5.1'
    FunctionsToExport    = @(
        'Get-MontyPythonPassword'
        'New-MemorablePassword'
        'New-PassphrasePassword'
        'New-RandomPassword'
    )
    AliasesToExport      = @(
        'pg'
        'pge'
        'pgmp'
        'pgw'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('password', 'security', 'generator', 'passphrase', 'powershell')
            ProjectUri   = 'https://github.com/415Group-Ray/PassGen'
            LicenseUri   = 'https://github.com/415Group-Ray/PassGen/blob/main/module/PassGen2/LICENSE'
            ReleaseNotes = 'Initial v1.0.0 module-based rewrite of the original PassGen script, published as PassGen2.'
        }
    }
}
