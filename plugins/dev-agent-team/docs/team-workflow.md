# Team Workflow: Agent-Driven Software Development

## Overview
This document describes the multi-agent team workflow. Each phase is executed by a specialized agent role, producing artifacts that the next phase consumes.

## Team Roles

| Role | Skill File | Responsibility | Key Outputs |
|------|-----------|---------------|-------------|
| PM | `skills/pm.skill.md` | Requirements, PRD, user stories | `work/prd.md`, `work/user-stories.md` |
| Architect | `skills/architect.skill.md` | System design, interfaces, ADRs | `work/architecture.md`, `work/module-interface-spec.md`, `docs/adr/*.md` |
| Task Manager | `skills/task-manager.skill.md` | Task breakdown, dependency analysis | `work/tasks/task-*.md`, `work/task-topology.md` |
| Developer | `skills/developer.skill.md` | Code implementation per task | Source code on `dev-task-*` branches |
| Reviewer | `skills/reviewer.skill.md` | Code review per task | `work/reviews/review-task-*.md` |
| Integration Manager | `skills/integration-manager.skill.md` | Merge branches, resolve conflicts | Integrate `main`, `work/integration-report.md` |
| Tester | `skills/tester.skill.md` | Integration/E2E tests | `tests/`, `work/test-report.md` |

## Workflow Diagram

```
User Request
  └→ [PM] → work/prd.md + work/user-stories.md
       └→ [Architect] → work/architecture.md + work/module-interface-spec.md + docs/adr/*.md
            └→ [Task Manager] → work/tasks/task-*.md
                 │
                 │  Parallel Execution:
                 ├─→ [Developer A] → task-001 → [Reviewer] → ✅/❌
                 ├─→ [Developer B] → task-002 → [Reviewer] → ✅/❌
                 └─→ [Developer C] → task-003 → [Reviewer] → ✅/❌
                 │                      (iterates on ❌)
                 └→ [Integration Manager] → main (merged)
                      └→ [Tester] → work/test-report.md → Done
```

## Phase Transition

1. Each phase is tracked in `project.json` (`phase` field)
2. The agent loads the corresponding skill file for current phase
3. After completing the phase's outputs, advance to next phase
4. Use `scripts/next-phase.ps1` to update the phase (with confirmation)

## Parallel Execution Rules

- **Independent tasks**: Tasks with no `depends_on` can execute in parallel
- **Pipeline tasks**: Task-002 depends on task-001 → sequential execution
- **Branch isolation**: Each task runs on `dev-task-{id}` branch
- **Review gate**: Completed tasks must pass review before integration

## Artifact Conventions

| Scope | Convention |
|-------|-----------|
| Phase outputs | `work/` directory (gitignored) |
| ADRs | `docs/adr/adr-NNN-title.md` |
| Task cards | `work/tasks/task-NNN.md` |
| Review reports | `work/reviews/review-task-NNN.md` |
| Branches | `dev-task-{id}` for tasks, `main` for integration |

## Getting Started

1. Run `scripts/init-project.ps1 -ProjectName <name>` to scaffold a new project
2. Load the appropriate skill file for the current phase
3. Complete the phase outputs
4. Advance phase and repeat

## Quality Gates

| Phase | Gate |
|-------|------|
| PM | All user stories have acceptance criteria |
| Architect | Each module has explicit interface contract |
| Task Manager | No task exceeds 3 files or crosses module boundaries |
| Developer | All code passes lint + tests; no out-of-scope changes |
| Reviewer | Report has concrete findings, not just "looks good" |
| Integration Manager | main branch builds and passes all tests |
| Tester | Core module coverage > 80%; all P0 E2E tests pass |
## MVP Checkpoint

After the Developer phase completes all tasks (MVP ready), the agent **automatically** performs a project review:

### Auto-Review Flow

1. **Project Review** — The agent runs a full project review using `schemas/project-review.md`, covering code quality, UX/UI, functionality, and security. Output goes to `work/project-review.md`.

2. **Auto-Fix Critical/High** — All Critical and High severity issues found in the review are **automatically fixed** without user confirmation. Each fix is verified by running build + tests. If a fix fails, it is rolled back and logged as `fix-failed` with the reason.

3. **User Choice on Remaining** — After Critical/High issues are resolved, the agent presents the remaining Medium/Low issues to the user and offers three options:
   - **Continue** — Advance through review → integration → testing. Remaining issues are deferred to later iterations.
   - **Select & Fix** — User specifies issue numbers to fix before continuing.
   - **Demo/Interact** — Run the project first, then return to the choice.

### Rationale
This replaces the old "Demo or Continue" prompt. The auto-review ensures no Critical or High issues ship, while giving the user full control over the remaining backlog.


## Filesystem Layout

```
project/
├── src/              # Source code
├── tests/            # Tests
├── docs/             # Documentation
│   └── adr/          # Architecture Decision Records
├── work/             # Generated artifacts (gitignored)
│   ├── tasks/        # Task cards
│   ├── reviews/      # Review reports
│   ├── prd.md        # Product Requirement Document
│   ├── architecture.md
│   ├── module-interface-spec.md
│   ├── task-topology.md
│   ├── integration-report.md
│   └── test-report.md
├── project.json      # Phase and state tracker
├── AGENTS.md         # Agent orchestration instructions
└── README.md
```
