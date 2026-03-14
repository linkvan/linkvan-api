# Plans Directory

This directory contains implementation plans for Linkvan API development.

## Structure

Each plan follows this pattern:

```
docs/plans/
├── README.md                          # This file - index of all plans
├── plan-name/                         # Individual plan subdirectory
│   ├── plan.md                        # Detailed plan document
│   └── tracker.md                     # Progress tracker for the plan
└── another-plan-name/                 # Another plan
    ├── plan.md
    └── tracker.md
```

## Plan Documentation Pattern

### plan.md

Each `plan.md` file should include:

- **Status** (In Progress, Complete, On Hold)
- **Created** date
- **Goal** - Clear objective
- **Priority Levels** (CRITICAL, HIGH, MEDIUM, LOW)
- **Detailed Items** - Each task with:
  - File/Directory location
  - Priority level
  - Estimated time
  - Coverage needed / Implementation details
  - Test patterns or implementation guidelines
- **Implementation Guidelines** - Patterns to follow
- **Quality Checks** - Steps to verify completion
- **Progress Tracking Reference** - Links to tracker.md

### tracker.md

Each `tracker.md` file should include:

- Link to plan.md
- **Created** and **Last Updated** dates
- **Summary Table** - Total/In Progress/Completed/Blocked counts by priority
- **Item Tables** - Detailed status for each item in the plan
- **Factory Requirements** - FactoryBot factories needed
- **Shared Examples Requirements** - Reusable test patterns
- **Blockers & Dependencies** - Cross-item dependencies
- **Completion Metrics** - Visual progress bars
- **Status Legend** - Icon meanings
- **Change Log** - History of updates

## Active Plans

| Plan | Status | Progress | Last Updated |
|------|--------|----------|--------------|
| [RuboCop Remediation](./rubocop-remediation/plan.md) | Complete | 64/64 (100%) | 2026-03-14 |
| [Test Coverage Implementation](./test-coverage-implementation/plan.md) | Complete | 24/24 (100%) | 2026-01-26 |

## Plan Templates

When creating a new plan:

1. Create subdirectory: `docs/plans/plan-name/`
2. Copy template structure from existing plans
3. Create `plan.md` with:
   - Clear goal statement
   - Prioritized task list
   - Implementation guidelines
4. Create `tracker.md` with:
   - All tasks from plan.md
   - Status tracking tables
   - Progress metrics
5. Update this README.md to register the plan
6. Assign status: "Not Started", "In Progress", or "Complete"

## Status Guidelines

- **Not Started** - Plan documented but no work begun
- **In Progress** - Currently being worked on
- **Complete** - All plan items successfully implemented
- **On Hold** - Work paused indefinitely

## Quick Reference

### Updating a Plan

1. Work on items from the plan
2. Update tracker.md with progress
3. Update plan.md if scope changes
4. Run quality checks (tests, linting)
5. Mark items complete when verified
6. Update overall status in this README.md

### Creating a New Plan

```bash
# 1. Create plan directory
mkdir -p docs/plans/your-plan-name

# 2. Copy templates (or create from scratch)
cp -r docs/plans/test-coverage-implementation/* docs/plans/your-plan-name/

# 3. Edit plan.md and tracker.md for your specific plan
vim docs/plans/your-plan-name/plan.md
vim docs/plans/your-plan-name/tracker.md

# 4. Register in this README.md
vim docs/plans/README.md
```

## Related Documentation

- [AGENTS.md](../../AGENTS.md) - Development guide for agents
- [README.md](../../README.md) - Project overview
