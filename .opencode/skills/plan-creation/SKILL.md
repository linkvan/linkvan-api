---
name: plan-creation
description: Create implementation plans and trackers following Linkvan API conventions
---

## When to Use This Skill

- User requests a plan for any significant change (upgrades, refactoring, new features)
- Breaking down large tasks into executable stages
- Creating a documented roadmap for complex changes

## Plan Structure

### Required Files

Create in this structure:
```
docs/plans/
├── README.md                          # Index of all plans (update this)
└── <plan-name>/
    ├── plan.md                        # Detailed plan document
    └── tracker.md                     # Progress tracker
```

### Plan Template (plan.md)

```markdown
# <Plan Title>

## Status: PENDING | IN PROGRESS | COMPLETE

## Created: <YYYY-MM-DD>

## Goal
Clear, concise objective of what this plan achieves

## Current State
- What exists now
- Version numbers, configs, etc.

## Target State  
- What we're changing to
- Expected outcome

## Analysis Summary
- Key changes required
- Dependencies/gems involved
- Breaking changes if any

## Priority System

- **CRITICAL** - Must complete for success
- **HIGH** - Should complete for full compatibility  
- **MEDIUM** - Recommended for best practices
- **LOW** - Optional improvements

## Manual Test Protocol

**What "Manual Test" Means:** At specific checkpoints, I will **ask you** (the user) to test the application manually in your browser/local environment. I cannot run browser-based tests myself.

**Protocol:**
1. I will pause execution at each manual test checkpoint
2. I will tell you exactly what to test and how
3. You test and report back pass/fail
4. I continue based on your feedback

---

## Implementation Stages

### Stage X: <Name>

**Focus:** One logical grouping of tasks

#### X.1 <Task Name>
- **Priority:** CRITICAL | HIGH | MEDIUM | LOW
- **Type:** Configuration | Code Fix | Verification | Manual
- **Location:** `path/to/file`
- **Command:** `bin/rails ...` (if applicable)
- **Description:** What this task does
- **Manual Test:** (if applicable - what user should test)

---

## Quality Checks

### Stage X Completion Criteria
- [ ] Task completed
- [ ] Tests pass
- [ ] Verified manually (if required)

---

## Rollback Plan

If issues occur:
1. Step to undo
2. Step to undo
3. Step to undo

---

## Estimated Time

| Stage | Tasks | Time |
|-------|-------|------|
| 1 | 3 | 15 min |
| Total | 12 | ~60 min |

---

## Related Documentation

- [Rails Upgrade Guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)
- [AGENTS.md](../../AGENTS.md)
```

### Tracker Template (tracker.md)

```markdown
# <Plan Title> Tracker

## Plan Reference

[plan.md](./plan.md)

---

## Created: <YYYY-MM-DD>
## Last Updated: <YYYY-MM-DD>

---

## Summary

| Priority | Total | Not Started | In Progress | Completed | Blocked |
|----------|-------|-------------|-------------|-----------|---------|
| CRITICAL | 5    | 5           | 0           | 0         | 0       |
| HIGH     | 3    | 3           | 0           | 0         | 0       |
| **TOTAL**| **8**| **8**       | **0**       | **0**     | **0**   |

---

## Stage X: <Name>

### Item Tables

#### X.1 - <Task Name>

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| X.1 | CRITICAL | ⬜ Not Started | app/models/foo.rb | Description |

---

## Dependencies

- Stage 1 must complete before Stage 2
- etc.

### Blockers

None identified at this time.

---

## Progress Tracking

```
Stage 1 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░ 0/3 items (0%)
Overall:             ░░░░░░░░░░░░░░░░░░░░ 0/8 items (0%)
```

---

## Status Legend

| Icon | Status |
|------|--------|
| ⬜ | Not Started |
| 🔄 | In Progress |
| ✅ | Completed |
| ⏸️ | On Hold |
| 🚫 | Blocked |

---

## Change Log

| Date | Change | Author |
|------|--------|--------|
| YYYY-MM-DD | Initial plan creation | Assistant |

---

## Notes

- Any additional context
- Known issues
```

## Key Conventions

1. **Always update docs/plans/README.md** - Add new plan to the Active Plans table

2. **Manual tests** - Add at risky checkpoints:
   - After bundle updates
   - Before enabling new configs
   - Final verification
   
3. **Gradual rollout** - For framework upgrades:
   - Keep `config.load_defaults` at old version initially
   - Test with defaults disabled first
   - Enable defaults gradually
   - Only then update load_defaults

4. **Link to sources** - Reference:
   - Official docs (Rails guides, gem docs)
   - AGENTS.md for project conventions
   - Related plans if applicable

5. **Include rollback** - Always document how to undo changes if issues occur

## Creating a New Plan

1. Create directory: `mkdir -p docs/plans/<plan-name>`
2. Copy template structure from existing plan
3. Customize for specific change
4. Update README.md
5. Set status to "Not Started" in tracker

## Executing Plans

When running a plan:
1. Update tracker status as you go
2. Mark items complete when verified
3. Add notes to tracker after each stage
4. Update last updated date
