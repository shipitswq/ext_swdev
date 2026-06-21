param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectDir,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("node-ts","node-js","python","rust","go")]
    [string]$TechStack,
    
    [string]$PackageName = "",
    
    [switch]$Force
)

# Resolve project name from directory if not provided
if ([string]::IsNullOrEmpty($PackageName)) {
    $PackageName = Split-Path $ProjectDir -Leaf
}

Write-Host "Scaffolding build configuration for: $TechStack"
Write-Host "Project: $ProjectDir"
Write-Host ""

function Write-ScaffoldFile {
    param([string]$Path, [string]$Content)
    
    $fullPath = Join-Path $ProjectDir $Path
    if ((Test-Path $fullPath) -and -not $Force) {
        Write-Host "  -- Skipping existing: $Path (use -Force to overwrite)"
        return
    }
    
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    # Write without BOM, with UTF8
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($fullPath, $Content, $utf8NoBom)
    Write-Host "  + Created: $Path"
}

# ──────────────────────────────────────────────
# node-ts: Node.js + TypeScript
# ──────────────────────────────────────────────
if ($TechStack -eq "node-ts") {
    $pkgContent = @"
{
  "name": "$PackageName",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest run",
    "test:watch": "vitest",
    "lint": "eslint 'src/**/*.ts' 'tests/**/*.ts'"
  },
  "devDependencies": {
    "typescript": "^5.8.0",
    "vitest": "^3.0.0",
    "eslint": "^9.20.0",
    "@typescript-eslint/eslint-plugin": "^8.0.0",
    "@typescript-eslint/parser": "^8.0.0",
    "tsx": "^4.19.0",
    "@types/node": "^22.0.0"
  }
}
"@
    Write-ScaffoldFile "package.json" $pkgContent

    $tsconfigContent = @"
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
"@
    Write-ScaffoldFile "tsconfig.json" $tsconfigContent

    $eslintContent = @"
import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';

export default [
  {
    ignores: ['dist/', 'node_modules/'],
  },
  {
    files: ['src/**/*.ts', 'tests/**/*.ts'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        project: './tsconfig.json',
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
    },
    rules: {
      'no-unused-vars': 'off',
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'warn',
    },
  },
];
"@
    Write-ScaffoldFile "eslint.config.js" $eslintContent

    Write-ScaffoldFile ".prettierrc" "{
  `"semi`": true,
  `"singleQuote`": true,
  `"trailingComma`": `"all`",
  `"printWidth`": 100,
  `"tabWidth`": 2
}
"
    Write-ScaffoldFile "src/.gitkeep" ""

    Write-Host ""
    Write-Host "Build configuration scaffolded for Node.js + TypeScript."
    Write-Host "Run 'npm install' to install dependencies."
}

# ──────────────────────────────────────────────
# node-js: Node.js + JavaScript
# ──────────────────────────────────────────────
if ($TechStack -eq "node-js") {
    $pkgContent = @"
{
  "name": "$PackageName",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "node --watch src/index.js",
    "start": "node src/index.js",
    "test": "vitest run",
    "test:watch": "vitest",
    "lint": "eslint 'src/**/*.js' 'tests/**/*.js'"
  },
  "devDependencies": {
    "vitest": "^3.0.0",
    "eslint": "^9.20.0"
  }
}
"@
    Write-ScaffoldFile "package.json" $pkgContent

    Write-ScaffoldFile ".prettierrc" "{
  `"semi`": true,
  `"singleQuote`": true,
  `"trailingComma`": `"all`",
  `"printWidth`": 100,
  `"tabWidth`": 2
}
"
    Write-ScaffoldFile "src/.gitkeep" ""

    Write-Host ""
    Write-Host "Build configuration scaffolded for Node.js + JavaScript."
    Write-Host "Run 'npm install' to install dependencies."
}

# ──────────────────────────────────────────────
# python
# ──────────────────────────────────────────────
if ($TechStack -eq "python") {
    $pyprojectContent = @"
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "$($PackageName -replace '-', '_')"
version = "0.1.0"
description = ""
readme = "README.md"
requires-python = ">=3.11"
dependencies = []

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W"]

[tool.ruff.format]
quote-style = "double"
indent-width = 4
"@
    Write-ScaffoldFile "pyproject.toml" $pyprojectContent

    Write-ScaffoldFile "requirements.txt" "# Core dependencies (managed via pyproject.toml)`r`n# Development`r`npytest>=8.0`r`nruff>=0.5.0`r`n"
    Write-ScaffoldFile ".python-version" "3.11`n"
    Write-ScaffoldFile "src/__init__.py" ""
    Write-ScaffoldFile "tests/__init__.py" ""

    Write-Host ""
    Write-Host "Build configuration scaffolded for Python."
    Write-Host "Use: pip install -e .  (or: uv sync)"
}

# ──────────────────────────────────────────────
# rust
# ──────────────────────────────────────────────
if ($TechStack -eq "rust") {
    $cargoContent = @"
[package]
name = "$($PackageName -replace '-', '_')"
version = "0.1.0"
edition = "2021"

[dependencies]

[dev-dependencies]

[profile.release]
opt-level = 2
"@
    Write-ScaffoldFile "Cargo.toml" $cargoContent

    Write-ScaffoldFile "rustfmt.toml" "edition = `"2021`"`ntab_spaces = 4`nmax_width = 100`n"

    $srcDir = Join-Path $ProjectDir "src"
    $mainRsPath = Join-Path $srcDir "main.rs"
    if (-not (Test-Path $mainRsPath) -or $Force) {
        Write-ScaffoldFile "src/main.rs" "fn main() {`n    println!(`"Hello, world!`");`n}`n"
    } else {
        Write-Host "  -- Skipping existing: src/main.rs (use -Force to overwrite)"
    }

    Write-Host ""
    Write-Host "Build configuration scaffolded for Rust."
    Write-Host "Use: cargo build / cargo test"
}

# ──────────────────────────────────────────────
# go
# ──────────────────────────────────────────────
if ($TechStack -eq "go") {
    $goModContent = "module $PackageName`n`ngo 1.22`n"
    Write-ScaffoldFile "go.mod" $goModContent

    $makefileContent = @"
.PHONY: build test lint clean run

APP_NAME := $(shell basename $(CURDIR))

build:
	go build -o bin/$(APP_NAME) ./cmd/...

test:
	go test ./... -v -cover

lint:
	golangci-lint run ./...

run:
	go run ./cmd/...

clean:
	rm -rf bin/
"@
    Write-ScaffoldFile "Makefile" $makefileContent

    Write-Host ""
    Write-Host "Build configuration scaffolded for Go."
    Write-Host "Use: go mod tidy / go build / go test"
}

# ──────────────────────────────────────────────
# Update project.json techStack field
# ──────────────────────────────────────────────
$projectJsonPath = Join-Path $ProjectDir "project.json"
if (Test-Path $projectJsonPath) {
    $raw = Get-Content $projectJsonPath -Raw -Encoding utf8
    $config = $raw | ConvertFrom-Json

    if (-not $config.techStack) {
        $config | Add-Member -NotePropertyName "techStack" -NotePropertyValue @{} -Force
    }

    switch ($TechStack) {
        "node-ts" {
            $config.techStack.language = "typescript"
            $config.techStack.framework = ""
            $config.techStack.buildTool = "tsc"
            $config.techStack.testRunner = "vitest"
            $config.techStack.lintTool = "eslint"
        }
        "node-js" {
            $config.techStack.language = "javascript"
            $config.techStack.framework = ""
            $config.techStack.buildTool = "node"
            $config.techStack.testRunner = "vitest"
            $config.techStack.lintTool = "eslint"
        }
        "python" {
            $config.techStack.language = "python"
            $config.techStack.framework = ""
            $config.techStack.buildTool = "hatchling"
            $config.techStack.testRunner = "pytest"
            $config.techStack.lintTool = "ruff"
        }
        "rust" {
            $config.techStack.language = "rust"
            $config.techStack.framework = ""
            $config.techStack.buildTool = "cargo"
            $config.techStack.testRunner = "cargo test"
            $config.techStack.lintTool = "clippy"
        }
        "go" {
            $config.techStack.language = "go"
            $config.techStack.framework = ""
            $config.techStack.buildTool = "go build"
            $config.techStack.testRunner = "go test"
            $config.techStack.lintTool = "golangci-lint"
        }
    }
    $config.updated_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    
    # Pretty-print JSON with 2-space indent
    $json = $config | ConvertTo-Json -Depth 5
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($projectJsonPath, $json + "`n", $utf8NoBom)
    Write-Host "  + Updated project.json with tech stack"
}

Write-Host ""
Write-Host "Done. Build configuration is ready for '$TechStack'."
