param(
    [Parameter(Mandatory=$true)]    
    [string]$deck,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Remove-Module './psModules/shared.psm1' -ErrorAction SilentlyContinue
Import-Module './psModules/shared.psm1'

$deckPath = Get-DeckPath -deck $deck

if (-not(Test-Path $deckPath)) {
    Write-Warning "Could not find deck at $deckPath. Exiting..."
    exit 1
}

$resourceGroupName = az group list --query "[?contains(name, '$deck')].name" -o tsv

if ($resourceGroupName -eq $null) {
    Write-Warning "Could not find a resource group to clean up. Exiting..."
    exit 1
}

if ($Force) {
    az group delete --name $resourceGroupName -y
} else {
    az group delete --name $resourceGroupName
}