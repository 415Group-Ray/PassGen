### Password Generator ###
### Ray Smalley        ###
### Created 01.29.18   ###
### Updated 12.08.25   ###


# Disable progress bar for faster downloads
$global:ProgressPreference = 'SilentlyContinue'

# Set TLS to 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create an instance of the Random class
$Random = New-Object System.Random

# Define the log file path
$LogFilePath = "$env:TEMP\PassGen.log"

# Log file retention function
function CheckLogSize {
    # Check the size of the log file and overwrite it if it's larger than 1 MB
    if ((Get-Item $LogFilePath -ErrorAction SilentlyContinue).Length -gt 1MB) {
        Clear-Content $LogFilePath
    }
}

# Download function
function Download {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$URL,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Name,
        [Parameter()][string]$Filename = $(if ($URL -match "\....$") {(Split-Path $URL -Leaf)}),
        [Parameter()][string]$OutputPath = $env:TEMP,
        [Parameter()][switch]$Force,
        [Parameter()][switch]$Quiet,
        # Re-download if the existing file is older than this many days (integer)
        # 0 or negative = disabled
        [Parameter()][int]$ForceIfOlderThanDays = 0
    )

    if (!$Filename) {
        Write-Warning "Filename parameter needed. Download failed."
        return
    }

    $Output       = Join-Path -Path $OutputPath -ChildPath $Filename
    $OutputName   = $Name -replace ' ', ''
    $FriendlyName = ($Name -replace ' ', '') -csplit '(?=[A-Z])' -ne '' -join ' '

    if ($URL -match "php") {
        try {
            $URL = (New-Object System.Net.WebClient).DownloadString($URL) |
                   Select-String -Pattern "href=`"(.*/$Filename)`"" |
                   ForEach-Object { $_.Matches.Groups[1].Value }
        } catch {
            Write-Warning "Failed to parse URL from PHP content."
            return
        }
    }

    # Decide whether we need to download
    $needsDownload = $false

    if (!(Test-Path $Output) -or $Force) {
        # No file yet, or explicit -Force
        $needsDownload = $true
    }
    elseif ($ForceIfOlderThanDays -gt 0) {
        # File exists; check its age in days
        try {
            $file = Get-Item -LiteralPath $Output
            $fileAgeDays = ((Get-Date) - $file.LastWriteTime).TotalDays

            if ($fileAgeDays -gt $ForceIfOlderThanDays) {
                $needsDownload = $true
                if (!$Quiet) {
                    Write-Host "$FriendlyName is older than $ForceIfOlderThanDays day(s) (actual age: {0:N2} days). Forcing re-download..." -f $fileAgeDays
                }
            }
        } catch {
            Write-Warning "Failed to read existing file metadata. Proceeding with download."
            $needsDownload = $true
        }
    }

    if ($needsDownload) {
        if (!$Quiet) {
            Write-Host "Downloading $FriendlyName..."
        }

        $RetryCount = 3
        for ($Retry = 0; $Retry -lt $RetryCount; $Retry++) {
            try {
                (New-Object System.Net.WebClient).DownloadFile($URL, $Output)
                Write-Host "$FriendlyName downloaded successfully"
                break
            } catch {
                Write-Warning "$FriendlyName download failed. Retrying ($($Retry + 1)/$RetryCount)..."
                Start-Sleep -Seconds 5
            }
        }

        if (!(Test-Path $Output)) {
            Read-Host "Download of $FriendlyName failed after $RetryCount retries. Press ENTER to exit."
            Exit 1
        }
    } else {
        if (!$Quiet) {
            Write-Host "$FriendlyName already downloaded and recent enough. Skipping..."
        }
    }

    New-Variable -Name "${OutputName}Output" -Value $Output -Scope Global -Force
}

# Helper function to set clipboard with retry logic
function Set-ClipboardWithRetry {
    param (
        [string]$Content,
        [int]$MaxRetries = 5,
        [int]$DelaySeconds = 1
    )

    $RetryCount = 0
    $Success = $false

    while (-not $Success -and $RetryCount -lt $MaxRetries) {
        try {
            Set-Clipboard $Content
            $Success = $true
        } catch {
            $RetryCount++
            Start-Sleep -Seconds $DelaySeconds
        }
    }

    return $Success
}

# Download the word list
Download -Name WordList -URL https://github.com/415Group-Ray/Packages/raw/main/WordList.txt -Quiet -ForceIfOlderThanDays 7
                             
$WordList = Get-Content $WordListOutput

# Get random word function
function GetRandomWord {
    do {
        $Word = Get-Random $WordList
    } while ($Word.Length -le 4 -or $Word.Length -ge 8)
    return $Word
}

# Random String Password
function pg {
    Param(
        [ValidateScript({
            if ($_ -is [int] -and $_ -gt 0) {
                $true
            } else {
                throw "The parameter Size must be a positive integer."
            }
        })][Int]$Size = 12,
        [ValidatePattern('[ULNS]')][Char[]]$CharSets = "ULNS",
        [Char[]]$Exclude
    )

    # Define character sets
    $TokenSets = @{
        U = [Char[]]'ABCDEFGHJKLMNPQRSTUVWXYZ'
        L = [Char[]]'abcdefghijkmnopqrstuvwxyz'
        N = [Char[]]'23456789'
        S = [Char[]]'!@#$%^&*()-+=.:;<>?_'
    }

    $Chars = New-Object Char[] $Size
    $TokensSet = @()

    $CharSets | ForEach {
        $Tokens = $TokenSets."$_" | ForEach {If ($Exclude -cNotContains $_) {$_}}
        If ($Tokens) {
            $TokensSet += $Tokens
            If ($_ -cle [Char]"Z") {$Chars[0] = $Tokens[$Random.Next(0, $Tokens.Count)]; $i = 1} # Character sets defined in upper case are mandatory
        }
    }

    # Fill the array with random characters from $TokensSet
    for (; $i -lt $Size; $i++) {
        $Chars[$i] = $TokensSet[$Random.Next(0, $TokensSet.Count)]
    }

    # Define a function to shuffle an array
    function Shuffle-Array {
        param([array]$arr)

        $n = $arr.Count
        while ($n -gt 1) {
            $n--
            $i = $Random.Next($n + 1)
            $temp = $arr[$i]
            $arr[$i] = $arr[$n]
            $arr[$n] = $temp
        }

        return ,$arr
    }

    # Use the Shuffle-Array function to shuffle $Chars
    $Chars = Shuffle-Array $Chars

    # Join the shuffled characters to form the password
    $Password = $Chars -Join ""

    # Show top on first run
    if (!$RunOnce) {
        Write-Host "Tip: You can specify length and characters (Example: pg 16 LUNS)" -ForegroundColor Magenta
    }
    $global:RunOnce = $true

    # Copy password to clipboard
    $Success = Set-ClipboardWithRetry -Content $Password
    if (-not $Success) {
        Write-Host "Failed to set clipboard after multiple attempts. Please try again." -ForegroundColor Red
    } else {
        # Log passwords
        CheckLogSize
        Add-Content -Value "$(Get-Date -Format 'MM/dd/yyyy - hh:mm:ss tt'): $Password `n" -Path $LogFilePath
    
        # Output
        Write-Host "Password added to clipboard: " -ForegroundColor Cyan -NoNewline
        Write-Host "$Password"`n -ForegroundColor Red
    }
}

# 3 Word Password
function pgw {
    $FirstWord = (Get-Culture).TextInfo.ToTitleCase($(GetRandomWord))
    $SecondWord = (Get-Culture).TextInfo.ToTitleCase($(GetRandomWord))
    $ThirdWord = (Get-Culture).TextInfo.ToTitleCase($(GetRandomWord))
    $Password = "$FirstWord-$SecondWord-$ThirdWord"
    $Success = Set-ClipboardWithRetry -Content $Password
    if (-not $Success) {
        Write-Host "Failed to set clipboard after multiple attempts. Please try again." -ForegroundColor Red
    } else {
        CheckLogSize
        Add-Content -Value "$(Get-Date -Format 'MM/dd/yyyy - hh:mm:ss tt'): $FirstWord-$SecondWord-$ThirdWord" -Path $env:TEMP\PassGen.log
        Write-Host "Password added to clipboard: " -ForegroundColor Cyan -NoNewline
        Write-Host $FirstWord -ForegroundColor Red -NoNewline
        Write-Host - -ForegroundColor White -NoNewline
        Write-Host $SecondWord -ForegroundColor Yellow -NoNewline
        Write-Host - -ForegroundColor White -NoNewline
        Write-Host $ThirdWord`n -ForegroundColor Green
    }
}

# Easy Password
function pge {
    param(
        [Parameter(Position = 0)]
        [ValidateRange(12, 18)]
        [Nullable[int]]$TotalLength
    )

    $Symbols = @('@','!','#','$','%','^','&','*','-','_','=','+',';',':','<','>','.','?','/','~')
    $MaxAttempts = 50

    $WordBuckets = @{}
    foreach ($word in $WordList) {
        $length = $word.Length
        if ($length -lt 4 -or $length -gt 18) { continue }
        if (-not $WordBuckets.ContainsKey($length)) {
            $WordBuckets[$length] = @()
        }
        $WordBuckets[$length] += $word
    }

    $MinWordLength = 4
    $targetWordLength = $null
    $FirstLengthOptions = $null

    if ($TotalLength) {
        $targetWordLength = $TotalLength - 2
        $FirstLengthOptions = $WordBuckets.Keys | ForEach-Object {[int]$_} | Where-Object {
            $_ -ge $MinWordLength -and $_ -le ($targetWordLength - $MinWordLength) -and $WordBuckets.ContainsKey($targetWordLength - $_)
        }

        if (-not $FirstLengthOptions) {
            Write-Warning "Unable to build a password matching the requested length with available words."
            return
        }
    }

    for ($attempt = 0; $attempt -lt $MaxAttempts; $attempt++) {
        if ($TotalLength) {
            $FirstLength = Get-Random $FirstLengthOptions
            $SecondLength = $targetWordLength - $FirstLength

            $FirstWordRaw = Get-Random $WordBuckets[$FirstLength]
            $SecondWordRaw = Get-Random $WordBuckets[$SecondLength]
        } else {
            $FirstWordRaw = GetRandomWord
            $SecondWordRaw = GetRandomWord
        }

        $FirstWord = (Get-Culture).TextInfo.ToTitleCase($FirstWordRaw)
        $SecondWord = (Get-Culture).TextInfo.ToTitleCase($SecondWordRaw)
        $Symbol = $Symbols | Get-Random
        $Number = Get-Random -Minimum 1 -Maximum 10
        $Jumble = @($Number, $Symbol) | Get-Random -Count 2

        $Password = "$FirstWord$($Jumble[0])$SecondWord$($Jumble[1])"

        if ($TotalLength -and $Password.Length -ne $TotalLength) {
            continue
        }

        $Success = Set-ClipboardWithRetry -Content $Password
        if (-not $Success) {
            Write-Host "Failed to set clipboard after multiple attempts. Please try again." -ForegroundColor Red
        } else {
            CheckLogSize
            Add-Content -Value "$(Get-Date -Format 'MM/dd/yyyy - hh:mm:ss tt'): $Password" -Path $env:TEMP\PassGen.log
            Write-Host "Password added to clipboard: " -ForegroundColor Cyan -NoNewline
            Write-Host $FirstWord -ForegroundColor Red -NoNewline
            Write-Host $Jumble[0] -NoNewline -ForegroundColor White
            Write-Host $SecondWord -ForegroundColor Yellow -NoNewline
            Write-Host $Jumble[1]`n -ForegroundColor Green
        }

        return
    }

    Write-Warning "Unable to build a password matching the requested length after $MaxAttempts attempts."
}

# Monty Python Quote password
Download -Name MontyPythonQuotes -URL https://github.com/415Group-Ray/Packages/raw/main/MontyPythonQuotes.txt -Quiet -ForceIfOlderThanDays 7

function pgmp {
    $Password = Get-Content $MontyPythonQuotesOutput | Get-Random
    $Success = Set-ClipboardWithRetry -Content $Password
    if (-not $Success) {
        Write-Host "Failed to set clipboard after multiple attempts. Please try again." -ForegroundColor Red
    } else {
        CheckLogSize
        Add-Content -Value "$(Get-Date -Format 'MM/dd/yyyy - hh:mm:ss tt'): $Password" -Path $env:TEMP\PassGen.log
        Write-Host "Password added to clipboard: " -ForegroundColor Cyan -NoNewline
        Write-Host $Password`n -ForegroundColor Yellow
    }
}