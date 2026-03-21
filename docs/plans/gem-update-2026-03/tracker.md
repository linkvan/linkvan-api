# Gem Update Plan - March 2026 Tracker

## Plan Reference

[plan.md](./plan.md)

---

## Created: 2026-03-21
## Last Updated: 2026-03-21

---

## Summary

| Priority | Total | Not Started | In Progress | Completed | Blocked |
|----------|-------|-------------|-------------|-----------|---------|
| CRITICAL | 6    | 6           | 0           | 0         | 0       |
| HIGH     | 6    | 6           | 0           | 0         | 0       |
| MEDIUM   | 6    | 6           | 0           | 0         | 0       |
| LOW      | 1    | 1           | 0           | 0         | 0       |
| **TOTAL**| **19**| **19**      | **0**       | **0**     | **0**   |

---

## Stage 1: Safe Patch/Minor Updates

### Item Tables

#### 1.1 - Update Low-Risk Gems

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.1 | HIGH | ⬜ Not Started | Gemfile.lock | Run `bundle update --patch` |

#### 1.2 - Verify Patch Updates

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.2 | HIGH | ⬜ Not Started | - | Run `bin/rspec` to verify |

#### 1.3 - Stage 1 Manual Test Checkpoint

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.3 | HIGH | ⬜ Not Started | - | Quick smoke test of admin UI |

---

## Stage 2: High-Risk Minor Updates

### Item Tables

#### 2.1 - Update prism

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.1 | MEDIUM | ⬜ Not Started | Gemfile | For IRB/RuboCop compatibility |

#### 2.2 - Update json

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.2 | MEDIUM | ⬜ Not Started | Gemfile | RuboCop dependency |

#### 2.3 - Update net-http

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.3 | MEDIUM | ⬜ Not Started | Gemfile | - |

#### 2.4 - Update responders

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.4 | HIGH | ⬜ Not Started | Gemfile | Update responders before devise |

#### 2.5 - Update devise

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.5 | HIGH | ⬜ Not Started | Gemfile | Update after responders |

#### 2.6 - Update turbo-rails

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.6 | HIGH | ⬜ Not Started | Gemfile | Affects page transitions |

#### 2.7 - Stage 2 Manual Test Checkpoint

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.7 | CRITICAL | ⬜ Not Started | - | Test login flow + page navigation |

---

## Stage 3: Critical Major Version Updates

### Item Tables

#### 3.1 - Update slop

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.1 | CRITICAL | ⬜ Not Started | Gemfile | Used by pry-remote |

#### 3.2 - Update diff-lcs

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.2 | CRITICAL | ⬜ Not Started | Gemfile | rspec dependency |

#### 3.3 - Update shoulda-matchers

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.3 | CRITICAL | ⬜ Not Started | Gemfile | Major version jump |

#### 3.4 - Update public_suffix and addressable together

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.4 | HIGH | ⬜ Not Started | Gemfile | Resolve constraint conflict |

#### 3.5 - Verify Stage 3 Updates

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.5 | HIGH | ⬜ Not Started | - | Run `bin/rspec` |

#### 3.6 - Stage 3 Manual Test Checkpoint

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.6 | CRITICAL | ⬜ Not Started | - | Full admin UI smoke test |

---

## Stage 4: Critical Major Version Updates - Final Verification

### Item Tables

#### 4.1 - Verify all Stage 3 updates work together

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 4.1 | CRITICAL | ⬜ Not Started | - | Run `bin/rspec` |

---

## Stage 5: pagy Update - Future Migration (Research Phase)

### Item Tables

#### 5.1 - Research pagy version history

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 5.1 | MEDIUM | ⬜ Not Started | - | Check changelog, identify breaking changes |

#### 5.2 - Analyze current pagy usage in codebase

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 5.2 | MEDIUM | ⬜ Not Started | app/ | `grep -r "pagy" app/ --include="*.rb"` |

#### 5.3 - Plan incremental update path

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 5.3 | MEDIUM | ⬜ Not Started | - | Document version path and code changes |

#### 5.4 - Execute pagy update (future)

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 5.4 | LOW | ⬜ Not Started | Gemfile | Future session - requires manual test |

---

## Dependencies

- Stage 1 must complete before Stage 2
- Stage 2 must complete before Stage 3
- Stage 3 must complete before Stage 4
- 2.4 (responders) must complete before 2.5 (devise)

### Blockers

- **pagy**: Blocked - requires significant API migration from 9.x to 43.x
- **public_suffix**: Temporarily blocked by addressable constraint - will resolve in Stage 3.4

---

## Progress Tracking

```
Stage 1 (HIGH):      ░░░░░░░░░░░░░░░░░░░░ 0/3 items (0%)
Stage 2 (HIGH/MED):  ░░░░░░░░░░░░░░░░░░░░ 0/7 items (0%)
Stage 3 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░ 0/6 items (0%)
Stage 4 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░ 0/1 items (0%)
Stage 5 (MEDIUM):    ░░░░░░░░░░░░░░░░░░░░ 0/4 items (0%)
Overall:             ░░░░░░░░░░░░░░░░░░░░ 0/19 items (0%)
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
| 2026-03-21 | Initial plan creation | Assistant |
| 2026-03-21 | Added manual test checkpoints to each stage | Assistant |
| 2026-03-21 | Added Stage 5 for pagy migration (research phase) | Assistant |

---

## Manual Test Summary

| Stage | When | What to Test |
|-------|------|--------------|
| 1 | End of stage | Quick smoke test - admin dashboard loads |
| 2 | End of stage | Login flow + page navigation in admin |
| 3 | End of stage | Full admin UI smoke test |

---

## Notes

- **diff-lcs 2.0.0** requires Ruby >= 3.2 - our Ruby 3.4.5 is compatible
- Some gems require updating together (addressable + public_suffix, responders + devise)
- Manual tests are only required at the end of each stage, not after individual gem updates
- Stages 2 and 3 are the most critical for manual testing due to devise and turbo-rails
- **Stage 5** is for future research/execution of pagy update - not part of current session