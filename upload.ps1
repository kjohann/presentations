param(
    [Parameter(Mandatory=$true)]
    [string]$deck,
    [string]$fileShareName ='slideslocation'
)
$ErrorActionPreference = "Stop"
Remove-Module './psModules/shared.psm1' -ErrorAction SilentlyContinue
Import-Module './psModules/shared.psm1'

$path = Get-DeckPath -deck $deck
EnsureDeckkFolder -path $path

try {
    $resourceGroupName = "$($deck)RG"
    $storageAccountName = az storage account list --resource-group $resourceGroupName --query "[*].name" -o tsv
    ExitIfCliError

    $storageKey = Get-StorageKey -resourceGroupName $resourceGroupName -storageAccountName $storageAccountName
    
    "Uploading  $path to $fileShareName"
    
    az storage file upload-batch --account-name $storageAccountName --account-key $storageKey --source $path --destination $fileShareName
    ExitIfCliError
}
catch {
    Write-Error "Something failed :("
    Write-Error $_.Exception.Message
    Resolve-Error
    exit 1
}



