param(
    [string]$ProjectDir = (Get-Location).Path
)

$projectJsonPath = Join-Path $ProjectDir "project.json"

if (-not (Test-Path $projectJsonPath)) {
    Write-Error "project.json not found in $ProjectDir"
    exit 1
}

$config = Get-Content $projectJsonPath -Raw | ConvertFrom-Json

$phaseOrder = @(
    "pm",
    "architect",
    "task-manager",
    "developer",
    "reviewer",
    "integration-manager",
    "tester",
    "done"
)

$currentIndex = [array]::IndexOf($phaseOrder, $config.phase)
if ($currentIndex -eq -1) {
    Write-Error "Unknown phase: $($config.phase)"
    exit 1
}

if ($currentIndex -ge $phaseOrder.Length - 1) {
    Write-Host "All phases complete! Project is done."
    exit 0
}

$nextPhase = $phaseOrder[$currentIndex + 1]

# Confirm
$confirm = Read-Host "Advance from '$($config.phase)' to '$nextPhase'? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cancelled."
    exit 0
}

# Update project.json
$config.phase = $nextPhase
$config.updated_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
$config | ConvertTo-Json | Set-Content $projectJsonPath -Encoding utf8

Write-Host "Phase advanced to: $nextPhase"
Write-Host ""
Write-Host "Next step: Load skills/$nextPhase.skill.md"
Write-Host "Input artifacts:"
switch ($nextPhase) {
    "architect" { Write-Host "  - Read: work/prd.md, work/user-stories.md" }
    "task-manager" { Write-Host "  - Read: work/architecture.md, work/module-interface-spec.md" }
    "developer" { Write-Host "  - Read: work/tasks/task-*.md, work/module-interface-spec.md"; Write-Host "  - Prior step: auto project-review + auto-fix critical/high issues" }
    "reviewer" { Write-Host "  - Read: work/tasks/task-*.md, dev-task-* branches" }
    "integration-manager" { Write-Host "  - Read: work/tasks/ (done tasks), work/reviews/" }
    "tester" { Write-Host "  - Read: main branch code, work/prd.md" }
}
