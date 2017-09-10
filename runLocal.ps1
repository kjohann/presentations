param(
    [Parameter(Mandatory=$true)]
    [string]$deck,
    [switch]$openBrowser
)

$ErrorActionPreference = "Stop"
Remove-Module './psModules/shared.psm1' -ErrorAction SilentlyContinue
Import-Module './psModules/shared.psm1'

$deckPath = Get-DeckPath -deck $deck

if (-not(Test-Path $deckPath)) {
    Write-Warning "Could not find deck at $deckPath. Exiting..."
    exit 1
}

docker run -d -v "$($deckPath):/slides/" -p 8000:8000 "danidemi/docker-reveal.js:latest"

if ($openBrowser) {
    Start-Process -FilePath "http://localhost:8000"
}