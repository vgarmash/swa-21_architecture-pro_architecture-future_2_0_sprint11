# =============================================================================
# Script: destroy.ps1
# Description: Universal destroy script for all environments
# =============================================================================
# Usage: .\destroy.ps1 -Environment dev
#        .\destroy.ps1 -Environment stage
#        .\destroy.ps1 -Environment prod
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev', 'stage', 'prod')]
    [string]$Environment
)

$projectRoot = $PSScriptRoot
$envDir = Join-Path -Path $projectRoot -ChildPath "envs\$Environment"
$tfvarsFile = Join-Path -Path $envDir -ChildPath "$Environment.tfvars"

Write-Host "==================================================" -ForegroundColor Red
Write-Host "  Terraform Destroy Script" -ForegroundColor Red
Write-Host "  Environment: $Environment" -ForegroundColor Red
Write-Host "==================================================" -ForegroundColor Red
Write-Host "WARNING: All resources will be permanently deleted!" -ForegroundColor Red
Write-Host ""

# Confirmation based on environment
if ($Environment -eq 'prod') {
    $confirmation = Read-Host "Type 'DESTROY PRODUCTION' to confirm"
    if ($confirmation -ne 'DESTROY PRODUCTION') {
        Write-Host "Cancelled by user" -ForegroundColor Yellow
        exit 0
    }
} else {
    $confirmation = Read-Host "Type 'destroy' to confirm"
    if ($confirmation -ne 'destroy') {
        Write-Host "Cancelled by user" -ForegroundColor Yellow
        exit 0
    }
}

# Check if tfvars file exists
if (-not (Test-Path $tfvarsFile)) {
    Write-Host "Error: Configuration file not found: $tfvarsFile" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Setting up Yandex Cloud environment variables ===" -ForegroundColor Cyan

# Get token using service account impersonation
$ServiceAccountId = "ajeu39krvvpe031mt22c"
Write-Host "Getting token for service account: $ServiceAccountId" -ForegroundColor Gray
$tokenOutput = yc iam create-token --impersonate-service-account-id $ServiceAccountId
$Env:YC_TOKEN = $tokenOutput.Trim()

# Get cloud-id and folder-id from config
$Env:YC_CLOUD_ID = yc config get cloud-id
$Env:YC_FOLDER_ID = yc config get folder-id

# Set Terraform CLI config file for Yandex provider (use absolute path)
$Env:TF_CLI_CONFIG_FILE = (Join-Path -Path $projectRoot -ChildPath "terraform.rc").Replace('\', '\\')

Write-Host "Cloud ID: $Env:YC_CLOUD_ID" -ForegroundColor Green
Write-Host "Folder ID: $Env:YC_FOLDER_ID" -ForegroundColor Green

Write-Host "`n=== Changing to environment directory: $envDir ===" -ForegroundColor Cyan
Set-Location $envDir

Write-Host "`n=== Destroying Terraform resources ===" -ForegroundColor Red
terraform destroy -var-file $tfvarsFile -auto-approve

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==================================================" -ForegroundColor Green
    Write-Host "  Destruction completed successfully!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
} else {
    Write-Host "Terraform destroy failed!" -ForegroundColor Red
    exit 1
}
