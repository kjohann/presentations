param(
    [Parameter(Mandatory=$true)]
    [string]$deck,
    [string]$fileShareName ='slideslocation',
    [switch]$openBrowser
)
$ErrorActionPreference = "Stop"
Remove-Module './psModules/shared.psm1' -ErrorAction SilentlyContinue
Import-Module './psModules/shared.psm1'

$path = Get-DeckPath -deck $deck
EnsureDeck -path $path

try {
    $resourceGroupName = "$($deck)RG"
    $storageAccountName = az storage account list --resource-group aci-lyntaleRG --query "[*].name" -o tsv | Where-Object {$_ -like 'slides*'}
    ExitIfCliError
    $storageKey = Get-StorageKey -resourceGroupName $resourceGroupName -storageAccountName $storageAccountName
    
    "Uploading  $path to $fileShareName"
    
    az storage file upload-batch --account-name $storageAccountName --account-key $storageKey --source $path --destination $fileShareName
    ExitIfCliError

    $url = Get-ContainerUri -resourceGroupName $resourceGroupName -containerName 'slides'
    if ($openBrowser) {
        Start-Process -FilePath $url
    } else {
        "Upload complete. Navigate to $url to see slides."
    }
}
catch {
    Write-Error "Something failed :("
    Write-Error $_.Exception.Message
    Resolve-Error
    exit 1
}



