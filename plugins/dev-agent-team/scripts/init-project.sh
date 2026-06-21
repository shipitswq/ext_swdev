#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME=""
TARGET_DIR="$(pwd)"
TECH_STACK=""

usage() {
  echo "Usage: $0 -n|--name <name> [-d|--dir <target-dir>] [-t|--tech-stack <stack>]"
  echo ""
  echo "Tech stacks: node-ts, node-js, python, rust, go"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--name) PROJECT_NAME="$2"; shift 2 ;;
    -d|--dir) TARGET_DIR="$2"; shift 2 ;;
    -t|--tech-stack) TECH_STACK="$2"; shift 2 ;;
    *) usage ;;
  esac
done

if [ -z "$PROJECT_NAME" ]; then
  echo "Error: --name is required"; usage
fi

TARGET_PATH="$TARGET_DIR/$PROJECT_NAME"
if [ -d "$TARGET_PATH" ]; then
  echo "Error: Directory already exists: $TARGET_PATH"; exit 1
fi

mkdir -p "$TARGET_PATH"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates/project"
for file in "$TEMPLATE_DIR"/*; do
  [ -f "$file" ] && cp "$file" "$TARGET_PATH/"
done

mkdir -p "$TARGET_PATH/work/tasks"
mkdir -p "$TARGET_PATH/work/reviews"
mkdir -p "$TARGET_PATH/docs/adr"
mkdir -p "$TARGET_PATH/src"
mkdir -p "$TARGET_PATH/tests"

PROJECT_JSON="$TARGET_PATH/project.json"
CREATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if command -v python3 >/dev/null 2>&1; then
  python3 <<-EOF
import json
with open("$PROJECT_JSON", "r") as f:
    config = json.load(f)
config["name"] = "$PROJECT_NAME"
config["created_at"] = "$CREATED_AT"
config["updated_at"] = "$CREATED_AT"
with open("$PROJECT_JSON", "w") as f:
    json.dump(config, f, indent=2)
EOF
fi

README="$TARGET_PATH/README.md"
sed -i "s/{project-name}/$PROJECT_NAME/g" "$README"
sed -i "s/{description}/TODO: Add project description/g" "$README"

# Scaffold build config if tech stack provided
if [ -n "$TECH_STACK" ]; then
  SCAFFOLD_SCRIPT="$SCRIPT_DIR/scaffold-build-config.sh"
  if [ -f "$SCAFFOLD_SCRIPT" ]; then
    echo "Scaffolding build configuration for: $TECH_STACK"
    bash "$SCAFFOLD_SCRIPT" -d "$TARGET_PATH" -t "$TECH_STACK" -n "$PROJECT_NAME" -f
    echo ""
  else
    echo "Warning: scaffold-build-config.sh not found at $SCAFFOLD_SCRIPT"
    echo "Run the following later:"
    echo "  pwsh scripts/scaffold-build-config.ps1 -ProjectDir $TARGET_PATH -TechStack $TECH_STACK -Force"
    echo ""
  fi
fi

cd "$TARGET_PATH"
git init

echo "Project '$PROJECT_NAME' initialized at: $TARGET_PATH"
echo "Current phase: pm (Product Manager)"
echo "Tip: Use scripts/next-phase.sh to advance phases."
