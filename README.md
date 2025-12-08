# PassGen

PassGen is a PowerShell script that quickly generates strong passwords and copies them to your clipboard. It includes multiple generation modes, automatic wordlist downloads, and lightweight logging so you can review what was created.

## Features
- **Random string passwords (`pg`)** with configurable length, character sets (upper, lower, numbers, symbols), and exclusions.
- **Three-word passphrases (`pgw`)** pulled from an automatically downloaded word list.
- **Easy-to-remember combos (`pge`)** that blend words with random numbers and symbols.
- **Monty Python quote passwords (`pgmp`)** sourced from a bundled quote list.
- Clipboard copy with retries and a rotating log at `%TEMP%\PassGen.log`.

## Requirements
- PowerShell 5.1 or later (tested on Windows; works in any PowerShell host with clipboard access).
- Internet access for the initial download of `WordList.txt` and `MontyPythonQuotes.txt` from the project package feed.

## Installation
1. Clone the repository:
   ```powershell
   git clone https://github.com/<your-org>/PassGen.git
   cd PassGen
   ```
2. Run the script or dot-source it so the functions are available in your session:
   ```powershell
   # Run directly
   powershell -ExecutionPolicy Bypass -File .\PassGen.ps1

   # Or dot-source to load functions
   . .\PassGen.ps1
   ```

> The script sets TLS 1.2 for downloads and writes a rotating log to `%TEMP%\PassGen.log`. If the log exceeds 1 MB it is truncated automatically.

## Usage
After dot-sourcing, call any of the generation functions:

- **Random string**
  ```powershell
  pg                 # 12 characters using all character sets
  pg 16 UN           # 16 characters using only upper case and numbers
  pg -Size 20 -Exclude '@','O','0'  # remove ambiguous characters
  ```
  Character sets:
  - `U`: Uppercase letters (A–Z, excluding ambiguous characters)
  - `L`: Lowercase letters
  - `N`: Numbers (2–9)
  - `S`: Symbols

- **Three-word passphrase**
  ```powershell
  pgw
  ```
  Generates a `Word-Word-Word` phrase using 4–8 letter words.

- **Easy-to-remember combo**
  ```powershell
  pge
  ```
  Combines two words with a random symbol and number in a varied order.

- **Monty Python quote**
  ```powershell
  pgmp
  ```
  Picks a random quote from the downloaded list.

Each command copies the password to your clipboard. If the clipboard cannot be set after several retries, the script reports the failure.

## Notes
- The script downloads support files into your `%TEMP%` directory and refreshes them every 7 days by default.
- To regenerate word lists immediately, rerun the script with `-Force` in the `Download` calls or delete the cached files in `%TEMP%`.

