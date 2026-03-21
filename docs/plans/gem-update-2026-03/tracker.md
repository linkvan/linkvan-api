# Gem Update Plan - March 2026 Tracker

## Plan Reference

[plan.md](./plan.md)

---

## Created: 2026-03-21
## Last Updated: 2026-03-21 (Updated for direct Gemfile gems only)

---

## Scope Note

This tracker only includes gems that are **explicitly listed in the Gemfile**:
- devise (~> 4.9.3)
- shoulda-matchers (>= 6.2.0)
- pagy (~> 9.4.0)
- turbo-rails
- pry-remote-reloaded
- pry-rails

**Transitive dependencies** (responders, slop, prism, json, net-http, public_suffix, diff-lcs, addressable) are **not tracked** as separate items - they are updated as part of their dependent gems.

---

## Summary

| Priority | Total | Not Started | In Progress | Completed | N/A |
|----------|-------|-------------|-------------|-----------|-----|
| CRITICAL | 3    | 0           | 0           | 2         | 1   |
| HIGH     | 3    | 1           | 0           | 1         | 1   |
| MEDIUM   | 3    | 3           | 0           | 0         | 0   |
| LOW      | 1    | 1           | 0           | 0         | 0   |
| **TOTAL**| **10**| **6**      | **0**       | **2**     | **2** |

---

## Stage 1: Safe Patch/Minor Updates

### Item Tables

#### 1.1 - Update Low-Risk Gems

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.1 | HIGH | ✅ Completed | Gemfile.lock | Run `bundle update --patch` - 26 gems updated |

#### 1.2 - Verify Patch Updates

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.2 | HIGH | ✅ Completed | - | Run `bin/rspec` - 1914 tests passed |

#### 1.3 - Stage 1 Manual Test Checkpoint

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.3 | HIGH | ✅ Completed | - | Quick smoke test of admin UI - passed |

---

## Stage 2: High-Risk Minor Updates

### Item Tables

#### 2.1 - Update turbo-rails

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.1 | HIGH | ⏭️ Skipped | Gemfile | Already at 2.0.23 (from Stage 1) |

#### 2.2 - Update pry-remote-reloaded (includes slop)

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.2 | HIGH | ✅ Completed | Gemfile | pry-remote-reloaded updated, slop (transitive) updated together |

#### 2.3 - Stage 2 Manual Test Checkpoint

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.3 | CRITICAL | ✅ Completed | - | Test login flow + page navigation - passed |

---

## Stage 3: Critical Major Version Updates

### Item Tables

#### 3.1 - Update shoulda-matchers

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.1 | CRITICAL | ✅ Completed | Gemfile | Already at 7.0.1 (latest) |

#### 3.2 - Verify Stage 3 Updates

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.2 | HIGH | ✅ Completed | - | Run `bin/rspec` - 1914 tests passed |

#### 3.3 - Stage 3 Manual Test Checkpoint

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.3 | CRITICAL | ✅ Completed | - | Full admin UI smoke test - passed |

---

## Stage 4: pagy Update - Future Migration (Research Phase)

### Item Tables

#### 4.1 - Research pagy version history

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 4.1 | MEDIUM | ⬜ Not Started | - | Check changelog, identify breaking changes |

#### 4.2 - Analyze current pagy usage in codebase

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 4.2 | MEDIUM | ⬜ Not Started | app/ | `grep -r "pagy" app/ --include="*.rb"` |

#### 4.3 - Plan incremental update path

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 4.3 | MEDIUM | ⬜ Not Started | - | Document version path and code changes |

#### 4.4 - Execute pagy update (future)

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 4.4 | LOW | ⬜ Not Started | Gemfile | Future session - requires manual test |

---

## Removed Items (Transitive Dependencies - Not in Gemfile)

These items were in the original plan but have been removed because the gems are not explicitly listed in the Gemfile:

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 2.1 (prism) | MEDIUM | N/A | Transitive dependency - not in Gemfile |
| 2.2 (json) | MEDIUM | N/A | Transitive dependency - not in Gemfile |
| 2.3 (net-http) | MEDIUM | N/A | Transitive dependency - not in Gemfile |
| 2.4 (responders) | HIGH | N/A | Transitive dependency of devise - not in Gemfile |
| 3.1 (slop) | CRITICAL | N/A | Transitive dependency of pry-remote-reloaded - not in Gemfile |
| 3.2 (diff-lcs) | CRITICAL | N/A | Transitive dependency of rspec - not in Gemfile |
| 3.4 (public_suffix + addressable) | HIGH | N/A | Transitive dependencies - not in Gemfile |

---

## Dependencies

- Stage 1 must complete before Stage 2
- Stage 2 must complete before Stage 3
- Stage 3 must complete before Stage 4

### Blockers

- **pagy**: Blocked - requires significant API migration from 9.x to 43.x

---

## Progress Tracking

```
Stage 1 (HIGH):      ████████████████████████████ 3/3 items (100%)
Stage 2 (HIGH):      ████████████████████████████ 3/3 items (100%) [1 completed, 1 skipped, 1 transitive N/A]
Stage 3 (CRITICAL):  ████████████████████████████  3/3 items (100%) [1 completed, 1 not started]
Stage 4 (MEDIUM/LOW):░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0/4 items (0%)
Overall:             ██████████████████░░░░░░░░░░  8/13 items (62%)
```

---

## Status Legend

| Icon | Status |
|------|--------|
| ⬜ | Not Started |
| 🔄 | In Progress |
| ✅ | Completed |
| ⏭️ | Skipped |
| ⏸️ | On Hold |
| 🚫 | Blocked |
| N/A | Not Applicable (not in Gemfile) |

---

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-03-21 | Initial plan creation | Assistant |
| 2026-03-21 | Added manual test checkpoints to each stage | Assistant |
| 2026-03-21 | Added Stage 4 for pagy migration (research phase) | Assistant |
| 2026-03-21 | Stage 1 completed: bundle update --patch (26 gems), rspec (1914 tests), manual smoke test | Assistant |
| 2026-03-21 | Stage 2 completed: turbo-rails/pry-remote-reloaded updated, manual test passed | Assistant |
| 2026-03-21 | Stage 3 completed: shoulda-matchers already at latest, rspec passed | Assistant |
| 2026-03-21 | Stage 3.3 completed: Full admin UI smoke test passed | User |

---

## Manual Test Summary

| Stage | When | What to Test |
|-------|------|--------------|
| 1 | End of stage | Quick smoke test - admin dashboard loads |
| 2 | End of stage | Login flow + page navigation in admin |
| 3 | End of stage | Full admin UI smoke test |

---

## Notes

- Only gems explicitly listed in the Gemfile are tracked: devise, shoulda-matchers, pagy, turbo-rails, pry-remote-reloaded, pry-rails
- Transitive dependencies (responders, slop, prism, json, net-http, public_suffix, diff-lcs, addressable) are updated as part of their dependent gems but not tracked separately
- Manual tests are only required at the end of each stage, not after individual gem updates
- **Stage 4** is for future research/execution of pagy update - not part of current session

(End of file - total 258 lines)
