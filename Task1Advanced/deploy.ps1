# =============================================================================
# Script: deploy.ps1
# Description: Universal deploy script for all environments
# =============================================================================
# Usage: .\deploy.ps1 -Environment dev
#        .\deploy.ps1 -Environment stage
#        .\deploy.ps1 -Environment prod
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev', 'stage', 'prod')]
    [string]$Environment
)

$projectRoot = $PSScriptRoot
$envDir = Join-Path -Path $projectRoot -ChildPath "envs\$Environment"
$tfvarsFile = Join-Path -Path $envDir -ChildPath "$Environment.tfvars"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Terraform Deployment Script" -ForegroundColor Cyan
Write-Host "  Environment: $Environment" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

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
$Env:TF_CLI_CONFIG_FILE = (Join-Path $projectRoot "terraform.rc").Replace('\', '\\')

Write-Host "Cloud ID: $Env:YC_CLOUD_ID" -ForegroundColor Green
Write-Host "Folder ID: $Env:YC_FOLDER_ID" -ForegroundColor Green
Write-Host "Token received successfully" -ForegroundColor Green

Write-Host "`n=== Changing to environment directory: $envDir ===" -ForegroundColor Cyan
Set-Location $envDir

Write-Host "`n=== Initializing Terraform ===" -ForegroundColor Cyan
terraform init -backend-config="path=$envDir/terraform.tfstate"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Terraform init failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Running Terraform plan ===" -ForegroundColor Cyan
terraform plan -var-file $tfvarsFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "Terraform plan failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Apply configuration ===" -ForegroundColor Yellow
$confirmation = Read-Host "Apply configuration for '$Environment'? (y/n)"
if ($confirmation -eq 'y') {
    terraform apply -var-file $tfvarsFile -auto-approve
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n==================================================" -ForegroundColor Green
        Write-Host "  Deployment completed successfully!" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Green
        
        Write-Host "`n=== Output parameters ===" -ForegroundColor Cyan
        terraform output
        
        # Show SSH connection if available
        $sshCommand = terraform output -raw ssh_command 2>$null
        if ($sshCommand) {
            Write-Host "`n=== SSH Connection ===" -ForegroundColor Cyan
            Write-Host "Command: $sshCommand" -ForegroundColor White
        }
    } else {
        Write-Host "Terraform apply failed!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Apply cancelled by user" -ForegroundColor Yellow
}
