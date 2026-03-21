---
name: plans
description: Create, execute, update, and complete implementation plans and trackers following Linkvan API conventions
---

## When to Use This Skill

- User requests a plan for any significant change (upgrades, refactoring, new features)
- Breaking down large tasks into executable stages
- Creating a documented roadmap for complex changes
- **User asks about plan progress or status** (check and report)
- **Plan is finished or user indicates completion** (update README.md, plan.md, tracker.md)
- **Plan items are being executed** (update tracker progress during execution)

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

### Plan Template

[plan-template.md](templates/plan-template.md)

### Tracker Template

[tracker-template.md](templates/tracker-template.md)

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
2. Copy templates from skill:
   ```bash
   cp .opencode/skills/plans/templates/plan-template.md docs/plans/<plan-name>/plan.md
   cp .opencode/skills/plans/templates/tracker-template.md docs/plans/<plan-name>/tracker.md
   ```
3. Customize for specific change
4. Add plan to README.md Active Plans table
5. Set status to "Not Started" in tracker

## Documentation Pattern

### plan.md should include:
- **Status** (PENDING | IN PROGRESS | COMPLETE)
- **Created** date
- **Goal** - Clear objective
- **Priority Levels** (CRITICAL, HIGH, MEDIUM, LOW)
- **Detailed Items** with file/directory location, priority, estimated time, implementation details
- **Implementation Guidelines** - Patterns to follow
- **Quality Checks** - Steps to verify completion

### tracker.md should include:
- Link to plan.md
- **Created** and **Last Updated** dates
- **Summary Table** - Total/In Progress/Completed counts by priority
- **Item Tables** - Detailed status for each item
- **Blockers & Dependencies** - Cross-item dependencies
- **Progress Tracking** - Visual progress bars
- **Status Legend** - Icon meanings (⬜ Not Started, 🔄 In Progress, ✅ Completed, ⏸️ On Hold, 🚫 Blocked)
- **Change Log** - History of updates

## Status Guidelines

- **PENDING** - Plan documented but no work begun
- **IN PROGRESS** - Currently being worked on
- **COMPLETE** - All plan items successfully implemented
- **On Hold** - Work paused indefinitely

## Executing Plans

When running a plan:
1. Update tracker status as you go
2. Mark items complete when verified
3. Add notes to tracker after each stage
4. Update last updated date

---

## Updating Progress

**When updating progress, always update the tracker first**, then update other files as needed:

### tracker.md Updates (During Execution)
- Update item status: `⬜ Not Started` → `🔄 In Progress` → `✅ Completed`
- Update Summary table counts (Total, Not Started, In Progress, Completed)
- Update Progress Tracking bar
- Add change log entries with date and notes
- Update blockers section if issues arise

### Partial Completion (Plan Still In Progress)
After completing a stage or significant milestone:
1. Update relevant item statuses in tracker.md
2. Update Summary table
3. Update Progress Tracking bar
4. Add change log entry

---

## Completing Plans

When a plan is finished (all items complete or appropriately skipped/N/A), update all three files:

### 1. docs/plans/README.md
Update the Active Plans table row for this plan:
- **Status**: Change to `Complete`
- **Progress**: Change to `XX/XX (100%)`

### 2. docs/plans/<plan-name>/plan.md
- **Status**: Change from `IN PROGRESS` or `PENDING` to `COMPLETE`
- **Completion Criteria**: Check off all completed items
- Update any "Future" or "To Do" items to reflect actual completion

### 3. docs/plans/<plan-name>/tracker.md
- **Summary table**: Ensure all counts are correct (Not Started = 0, Completed = Total)
- **Progress Tracking**: Update to 100% - full bar
- **Last Updated**: Update to today's date with note like "ALL ITEMS COMPLETE"
- **Blockers section**: Mark all blockers as resolved/complete
- **Change log**: Add final completion entry

### Example Final Updates

**README.md:**
```markdown
| [Plan Name](plan-name/plan.md) | Complete | 13/13 (100%) | YYYY-MM-DD |
```

**plan.md:**
```markdown
## Status: COMPLETE
```

**tracker.md:**
```markdown
## Last Updated: YYYY-MM-DD (ALL ITEMS COMPLETE)

| Priority | Total | Not Started | In Progress | Completed | N/A |
|----------|-------|-------------|-------------|-----------|-----|
| CRITICAL | 3    | 0           | 0           | 3         | 0   |
| HIGH     | 4    | 0           | 0           | 4         | 0   |
| MEDIUM   | 3    | 0           | 0           | 3         | 0   |
| LOW      | 3    | 0           | 0           | 3         | 0   |
| **TOTAL**| **13**| **0**      | **0**       | **13**    | **0** |

Overall:             ████████████████████████████  13/13 items (100%)
```

---

## Checklist: Plan Completion

When user asks "Is the plan finished?" or indicates plan is complete:

- [ ] Verify all items in tracker.md are complete (not 0 Not Started)
- [ ] Update README.md - mark plan as Complete
- [ ] Update plan.md - change status to COMPLETE, check off criteria
- [ ] Update tracker.md - ensure 100% progress, all complete, blockers resolved
- [ ] Report summary of what was done
