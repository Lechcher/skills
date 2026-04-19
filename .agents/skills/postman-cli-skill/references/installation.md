# Postman CLI Installation

Postman CLI is available for Mac, Windows, and Linux.

## Mac (Homebrew)
`brew install postman/tap/postman-cli`

## Linux (curl)
`curl -o- "https://dl-cli.pstmn.io/install/linux64.sh" | sh`

## Windows (PowerShell)
`powershell.exe -NoProfile -InputFormat None -ExecutionPolicy AllSigned -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://dl-cli.pstmn.io/install/win64.ps1'))"`
