param(
    [Parameter(Mandatory=$true)]    
    [string]$deck,
    [string]$resourceGroupLocation='westeurope',
    [string]$fileShareName ='slideslocation',
    [string]$templateFile = 'template.json'
)
$ErrorActionPreference = "Stop"
Remove-Module './psModules/shared.psm1' -ErrorAction SilentlyContinue
Import-Module './psModules/shared.psm1'

try {
    $path = Get-DeckPath -deck $deck    
    EnsureDeck -path $path

    $guid = [System.Guid]::NewGuid().ToString().SubString(0,7)
    $storageAccountName = "slides$guid"
    $resourceGroupName = "$($deck)RG"
    
    "Creating resource group $resourceGroupName in location $resourceGroupLocation"
    az group create --name $resourceGroupName --location $resourceGroupLocation
    ExitIfCliError
    
    "Creating storage account $storageAccountName"
    az storage account create -n $storageAccountName -g $resourceGroupName -l $resourceGroupLocation --sku Standard_LRS
    ExitIfCliError

    $connectionString = az storage account show-connection-string -n $storageAccountName -g $resourceGroupName -o tsv
    ExitIfCliError

    Write-Verbose "Got connection string: $($($connectionString).Substring(0, 20))..."
    
    Write-Verbose "Creating share"
    az storage share create -n $fileShareName --connection-string $connectionString
    ExitIfCliError

    Write-Verbose "Share created!"
    
    Write-Verbose "Getting storage key"
    $storageKey = Get-StorageKey -resourceGroupName $resourceGroupName -storageAccountName $storageAccountName
    
    Write-Verbose "Got key $($($storageKey).Substring(0, 20))...."
    
    "Deploying container group using $templateFile"
    
    az group deployment create --name 'slidesdeployment' --template-file template.json --parameters storageaccountname=$storageAccountName storageaccountkey=$storageKey --resource-group $resourceGroupName    
    ExitIfCliError

    Write-Verbose "Uploading slides..."
    .\upload.ps1 -deck $deck -fileShareName $fileShareName

    $url = Get-ContainerUri -resourceGroupName $resourceGroupName -containerName 'slides'
    "Container can be reached from $url"

    Start-Process -FilePath $url
}
catch {
    Write-Error "Something failed :("
    Write-Error $_.Exception.Message
    Resolve-Error
    exit 1
}