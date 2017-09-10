function ExitIfCliError {
    if ($LASTEXITCODE -ne 0) {
        throw $Error[0]
    }
}
function Resolve-Error ($ErrorRecord=$Error[0])
{
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo |Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
   {   "$i" * 80
       $Exception |Format-List * -Force
   }
}

function Get-StorageKey(
    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$storageAccountName
) {
    $key = az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query '[0].value' -o tsv
    ExitIfCliError
    $key
}

function Get-ContainerIp(
    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$containerName
) {
    $ip = az container show --name $containerName --resource-group $resourceGroupName --query 'ipAddress.ip' -o tsv
    ExitIfCliError
    $ip
}

function Get-ContainerPort(
    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$containerName
) {
    $port = az container show --name $containerName --resource-group $resourceGroupName --query 'ipAddress.ports[0].port' -o tsv
    ExitIfCliError
    $port
}

function Get-ContainerUri(
    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$containerName
) {
    $ipAdress = Get-ContainerIp -resourceGroupName $resourceGroupName -containerName $containerName
    $port = Get-ContainerPort -resourceGroupName $resourceGroupName -containerName $containerName
    "http://$($ipAdress):$port"
}

function Get-DeckPath(
    [Parameter(Mandatory = $true)]
    [string]$deck
) {
    Join-Path $PSScriptRoot "../decks/$deck"    
}

function EnsureDeck(
    [Parameter(Mandatory = $true)]
    [string]$path
) {
    if (-not(Test-Path -Path $path)) {
        Write-Warning "Could not find deck at path: $path. Want to create it? (y/n)"
        $ans = Read-Host
        if ($ans -ne 'y') {
            "Aborting..."
            exit 0
        }
        
        mkdir $path
        Copy-Item ".\index-template.html" -Destination (Join-Path $path "index.html")
    }
}
