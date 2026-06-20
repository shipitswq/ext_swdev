# Dev Agent Team

Multi-agent software development team orchestration for Codex. Start any new project and run it through a structured pipeline of specialized agent roles.

## Quick Install

```bash
codex plugin marketplace add shipitswq/ext_swdev --ref main
codex plugin add dev-agent-team@ext_swdev
```

## Team Roles

The workflow passes through up to seven agent roles, each producing artifacts consumed by the next:

| Phase | Role | Responsibility | Key Output |
|---|---|---|---|
| pm | Product Manager | Clarify requirements, write PRD and user stories | `work/prd.md`, `work/user-stories.md` |
| architect | Architect | System design, module interfaces, ADRs | `work/architecture.md`, `work/module-interface-spec.md` |
| task-manager | Task Manager | Decompose work into parallel tasks, analyze dependencies | `work/tasks/task-*.md` |
| developer | Developer | Implement tasks on isolated branches | Source code on `dev-task-*` branches |
| reviewer | Reviewer | Code review per task | `work/reviews/review-task-*.md` |
| integration-manager | Integration Manager | Merge branches, resolve conflicts | Integrated `main` branch |
| tester | Tester | Integration and E2E tests | `work/test-report.md` |

## Workflow

```
User Request
  -> [PM] -> PRD
       -> [Architect] -> Design + Interface Spec
            -> [Task Manager] -> Task Cards
                 |
                 |- [Developer A] -> Task 1 -> [Reviewer] -> Done
                 |- [Developer B] -> Task 2 -> [Reviewer] -> Done  (parallel)
                 |- [Developer C] -> Task 3 -> [Reviewer] -> Done
                 |
                 -> [Integration Manager] -> Merge -> Test -> Done
```

Tasks with no dependencies execute in parallel. Each task runs on its own branch and requires a passing review before it can be merged.

## Usage

Start a new project:

**Windows (PowerShell):**

```powershell
& path\to\plugin\scripts\init-project.ps1 -ProjectName my-app -TargetDir D:\projects
```

**Linux (bash) / macOS:**

```bash
./path/to/plugin/scripts/init-project.sh --name my-app --dir ~/projects
```

This creates a project skeleton with AGENTS.md, README.md, project.json, and work directories, then initializes a git repo with the first phase set to **pm**.

Advance phases:

```bash
./path/to/plugin/scripts/next-phase.sh
```

Each phase loads its corresponding skill file and reads the previous phase output to continue the work.

## Project Structure

```
my-app/
??? src/                          # Source code
??? tests/                        # Tests
??? docs/adr/                     # Architecture Decision Records
??? work/                         # Generated artifacts (gitignored)
?   ??? tasks/                    # Task cards
?   ??? reviews/                  # Review reports
?   ??? prd.md                    # Product Requirement Document
?   ??? architecture.md           # System design
?   ??? module-interface-spec.md  # Module contracts
?   ??? integration-report.md     # Integration results
?   ??? test-report.md            # Test results
??? project.json                  # Phase and state tracker
??? AGENTS.md                     # Orchestration instructions
??? README.md
```

## Platform Support

| Platform | Init Script | Phase Script |
|---|---|---|
| Windows | `scripts/init-project.ps1` | `scripts/next-phase.ps1` |
| Linux / macOS | `scripts/init-project.sh` | `scripts/next-phase.sh` |

PowerShell scripts also run on Linux via `pwsh` (PowerShell Core).

## Repository Layout

```
ext_swdev/
??? plugins/dev-agent-team/       # Plugin source
?   ??? .codex-plugin/plugin.json # Plugin manifest
?   ??? skills/                   # 7 role skill files
?   ??? schemas/                  # 7 artifact templates
?   ??? scripts/                  # Init and phase scripts (both shells)
?   ??? templates/project/        # New project scaffold
?   ??? docs/team-workflow.md     # Full workflow documentation
??? .agents/plugins/marketplace.json  # Codex marketplace manifest
??? AGENTS.md                     # Repository agent instructions
??? .gitignore
```

## Development

To modify the plugin, edit files in `plugins/dev-agent-team/`, then:

```bash
git add -A
git commit -m "feat: description"
git push
```

Users pick up the update with:

```bash
codex plugin marketplace upgrade ext_swdev
codex plugin add dev-agent-team@ext_swdev
```

## License

MIT
