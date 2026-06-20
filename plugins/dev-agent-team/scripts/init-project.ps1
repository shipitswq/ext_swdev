param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [string]$TargetDir = (Get-Location).Path
)

$targetPath = Join-Path $TargetDir $ProjectName

# Check if target exists
if (Test-Path $targetPath) {
    Write-Error "Directory already exists: $targetPath"
    exit 1
}

# Create project directory
New-Item -ItemType Directory -Path $targetPath -Force | Out-Null

# Copy template files
$templateDir = Join-Path (Split-Path $PSScriptRoot -Parent) "templates" "project"
Get-ChildItem -Path $templateDir -File | ForEach-Object {
    $dest = Join-Path $targetPath $_.Name
    Copy-Item $_.FullName $dest
}

# Create work directories
New-Item -ItemType Directory -Path (Join-Path $targetPath "work" "tasks") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $targetPath "work" "reviews") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $targetPath "docs" "adr") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $targetPath "src") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $targetPath "tests") -Force | Out-Null

# Update project.json with project name
$projectJsonPath = Join-Path $targetPath "project.json"
$config = Get-Content $projectJsonPath -Raw | ConvertFrom-Json
$config.name = $ProjectName
$config.created_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
$config.updated_at = $config.created_at
$config | ConvertTo-Json | Set-Content $projectJsonPath -Encoding utf8

# Update README.md placeholder
$readmePath = Join-Path $targetPath "README.md"
$readme = Get-Content $readmePath -Raw
$readme = $readme.Replace("{project-name}", $ProjectName)
$readme = $readme.Replace("{description}", "TODO: Add project description")
$readme = $readme.Replace("{tech stack}", "TODO: Define tech stack")
$readme = $readme.Replace("{install command}", "TODO: Add install command")
$readme = $readme.Replace("{dev command}", "TODO: Add dev command")
Set-Content $readmePath $readme -Encoding utf8

# Initialize git repo
Set-Location $targetPath
git init

Write-Host "Project '$ProjectName' initialized at: $targetPath"
Write-Host "Current phase: pm (Product Manager)"
Write-Host "Start by loading the pm.skill.md and writing work/prd.md"
Write-Host ""
Write-Host "Tip: Use scripts/next-phase.ps1 to advance phases."
