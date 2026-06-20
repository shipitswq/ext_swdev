#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(pwd)"
[ -n "${1:-}" ] && PROJECT_DIR="$1"

PROJECT_JSON="$PROJECT_DIR/project.json"
if [ ! -f "$PROJECT_JSON" ]; then
  echo "Error: project.json not found"; exit 1
fi

PHASES=("pm" "architect" "task-manager" "developer" "reviewer" "integration-manager" "tester" "done")

if command -v python3 >/dev/null 2>&1; then
  CURRENT_PHASE=$(python3 -c "import json; print(json.load(open('$PROJECT_JSON'))['phase'])")
else
  CURRENT_PHASE=$(grep -o '"phase"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_JSON" | head -1 | cut -d'"' -f4)
fi

CURRENT_INDEX=-1
for i in "${!PHASES[@]}"; do
  if [ "${PHASES[$i]}" = "$CURRENT_PHASE" ]; then
    CURRENT_INDEX=$i; break
  fi
done

if [ "$CURRENT_INDEX" -eq -1 ]; then
  echo "Error: Unknown phase"; exit 1
fi

if [ "$CURRENT_INDEX" -ge $(( ${#PHASES[@]} - 1 )) ]; then
  echo "All phases complete!"; exit 0
fi

NEXT_PHASE="${PHASES[$((CURRENT_INDEX + 1))]}"
echo "Advance from '$CURRENT_PHASE' to '$NEXT_PHASE'? (y/N)"

read -r CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo "Cancelled."; exit 0
fi

UPDATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if command -v python3 >/dev/null 2>&1; then
  python3 <<-EOF
import json
with open("$PROJECT_JSON", "r") as f:
    config = json.load(f)
config["phase"] = "$NEXT_PHASE"
config["updated_at"] = "$UPDATED_AT"
with open("$PROJECT_JSON", "w") as f:
    json.dump(config, f, indent=2)
EOF
fi

echo "Phase advanced to: $NEXT_PHASE"
echo ""
echo "Input artifacts:"
case "$NEXT_PHASE" in
  architect) echo "  - Read: work/prd.md, work/user-stories.md" ;;
  task-manager) echo "  - Read: work/architecture.md, work/module-interface-spec.md" ;;
  developer) echo "  - Read: work/tasks/task-*.md, work/module-interface-spec.md" ;;
  reviewer) echo "  - Read: work/tasks/task-*.md, dev-task-* branches" ;;
  integration-manager) echo "  - Read: work/tasks/ (done tasks), work/reviews/" ;;
  tester) echo "  - Read: main branch code, work/prd.md" ;;
esac
