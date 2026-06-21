param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [string]$TargetDir = (Get-Location).Path,
    
    [ValidateSet("node-ts","node-js","python","rust","go","")]
    [string]$TechStack = ""
)

$targetPath = [System.IO.Path]::Combine($TargetDir, $ProjectName)

# Check if target exists
if (Test-Path $targetPath) {
    Write-Error "Directory already exists: $targetPath"
    exit 1
}

# Create project directory
New-Item -ItemType Directory -Path $targetPath -Force | Out-Null

# Copy template files
$templateDir = [System.IO.Path]::Combine((Split-Path $PSScriptRoot -Parent), "templates", "project")
Get-ChildItem -Path $templateDir -File | ForEach-Object {
    $dest = [System.IO.Path]::Combine($targetPath, $_.Name)
    Copy-Item $_.FullName $dest
}

# Create work directories
New-Item -ItemType Directory -Path ([System.IO.Path]::Combine($targetPath, "work", "tasks")) -Force | Out-Null
New-Item -ItemType Directory -Path ([System.IO.Path]::Combine($targetPath, "work", "reviews")) -Force | Out-Null
New-Item -ItemType Directory -Path ([System.IO.Path]::Combine($targetPath, "docs", "adr")) -Force | Out-Null
New-Item -ItemType Directory -Path ([System.IO.Path]::Combine($targetPath, "src")) -Force | Out-Null
New-Item -ItemType Directory -Path ([System.IO.Path]::Combine($targetPath, "tests")) -Force | Out-Null

# Update project.json with project name
$projectJsonPath = [System.IO.Path]::Combine($targetPath, "project.json")
$config = Get-Content $projectJsonPath -Raw | ConvertFrom-Json
$config.name = $ProjectName
$config.created_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
$config.updated_at = $config.created_at
$config | ConvertTo-Json -Depth 5 | Set-Content $projectJsonPath -Encoding utf8

# Update README.md with project name
$readmePath = [System.IO.Path]::Combine($targetPath, "README.md")
$readme = Get-Content $readmePath -Raw
$readme = $readme.Replace("{project-name}", $ProjectName)
$readme = $readme.Replace("{description}", "TODO: Add project description")
Set-Content $readmePath $readme -Encoding utf8

# Scaffold build configuration if tech stack provided
if ($TechStack) {
    Write-Host "Scaffolding build configuration for: $TechStack"
    $scaffoldScript = [System.IO.Path]::Combine((Split-Path $PSScriptRoot -Parent), "scripts", "scaffold-build-config.ps1")
    & $scaffoldScript -ProjectDir $targetPath -TechStack $TechStack -PackageName $ProjectName -Force
    Write-Host ""
}

# Initialize git repo
Set-Location $targetPath
git init

Write-Host ""
Write-Host "Project '$ProjectName' initialized at: $targetPath"
Write-Host "Current phase: pm (Product Manager)"
Write-Host "Start by loading the pm.skill.md and writing work/prd.md"
Write-Host ""
Write-Host "Tip: Use scripts/next-phase.ps1 to advance phases."
