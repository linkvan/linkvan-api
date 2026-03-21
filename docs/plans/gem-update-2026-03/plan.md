# Gem Update Plan - March 2026

## Status: IN PROGRESS

## Created: 2026-03-21

## Goal
Update outdated Ruby gems to their latest versions while maintaining compatibility and running tests to verify no regressions.

## Current State
- Ruby: 3.4.5
- Rails: 8.1.2
- Bundler: 2.7.2
- 39 gems have updates available
- See `bundle outdated` output for full list

## Target State
- All gems updated to latest compatible versions
- All tests passing (bin/rspec)
- No breaking changes introduced

## Direct Gemfile Gems (In Scope)

| Gem | Current | Latest | Notes |
|-----|---------|--------|-------|
| devise | 4.9.4 | 5.0.3 | Constraint: ~> 4.9.3 |
| shoulda-matchers | 7.0.1 | 7.0.1 | Already at latest |
| pagy | 9.4.0 | 43.4.2 | MASSIVE jump - SKIP for now |
| turbo-rails | 2.0.23 | 2.0.23 | Already at latest |
| pry-remote-reloaded | varies | latest | Uses slop (transitive) |
| pry-rails | varies | latest | In Gemfile |

## Analysis Summary

### Critical Gems (Major Version Jumps - Breaking Changes Likely)
- **pagy**: 9.4.0 → 43.4.2 - MASSIVE jump - SKIP for now
- **shoulda-matchers**: 6.5.0 → 7.0.1 - Requires Ruby >= 3.2, Rails >= 7.1 (ALREADY UPDATED)

### High Risk Gems (Minor Updates with Potential Issues)
- **devise**: 4.9.4 → 5.0.3 - Requires responders update first (transitive)

### Safe to Update
- turbo-rails: Already at latest
- pry-rails: Already at latest
- pry-remote-reloaded: Already updated (includes slop transitive)

### Transitive Dependencies (NOT in Gemfile - Handled as Part of Dependency Updates)
- responders (dependency of devise)
- slop (dependency of pry-remote-reloaded - already updated)
- prism, json, net-http, public_suffix, diff-lcs, addressable

---

## Priority System

- **CRITICAL** - Must complete for success
- **HIGH** - Should complete for full compatibility
- **MEDIUM** - Recommended for best practices
- **LOW** - Optional improvements

---

## Implementation Stages

### Stage 1: Safe Patch/Minor Updates

**Focus:** Low-risk updates that don't require special handling

#### 1.1 - Update Low-Risk Gems
- **Priority:** HIGH
- **Type:** Configuration
- **Command:** `bundle update --patch`
- **Description:** Run bundle update for patch-level changes across all gems
- **Manual Test:** Not required - rspec sufficient

#### 1.2 - Verify Patch Updates
- **Priority:** HIGH
- **Type:** Verification
- **Command:** `bin/rspec`
- **Description:** Run full test suite after patch updates
- **Manual Test:** Not required - rspec sufficient

#### 1.3 - Stage 1 Manual Test Checkpoint
- **Priority:** HIGH
- **Type:** Manual
- **Description:** Quick smoke test of admin UI
- **Manual Test:**
  1. Start server: `bin/rails s -p 3000`
  2. Visit: http://localhost:3000/admin/dashboard
  3. Test: Page loads, navigation works
  4. Report: Pass/Fail

---

### Stage 2: High-Risk Minor Updates (devise + turbo-rails)

**Focus:** Gems with minor version jumps that may have behavioral changes

#### 2.1 - Update turbo-rails
- **Priority:** HIGH
- **Type:** Configuration
- **Command:** `bundle update turbo-rails`
- **Description:** Update turbo-rails - affects page transitions
- **Manual Test:** Not required

#### 2.2 - Update pry-remote-reloaded (includes slop)
- **Priority:** HIGH
- **Type:** Configuration
- **Command:** `bundle update pry-remote-reloaded`
- **Description:** Update pry-remote-reloaded (slop is transitive dependency - updated together)
- **Manual Test:** Not required

#### 2.3 - Stage 2 Manual Test Checkpoint
- **Priority:** CRITICAL
- **Type:** Manual
- **Description:** Test authentication and page navigation in admin UI
- **Manual Test:**
  1. Start server: `bin/rails s -p 3000`
  2. Visit: http://localhost:3000/admin
  3. Test: Login flow works (if not logged in)
  4. Test: Navigate between admin pages - notice any visual glitches or broken turbo frames
  5. Report: Pass/Fail

---

### Stage 3: Critical Major Version Updates

**Focus:** Gems with major version jumps requiring careful testing

#### 3.1 - Update shoulda-matchers
- **Priority:** CRITICAL
- **Type:** Configuration
- **Command:** `bundle update shoulda-matchers`
- **Description:** Update shoulda-matchers (major version)
- **Manual Test:** Not required

#### 3.2 - Verify Stage 3 Updates
- **Priority:** HIGH
- **Type:** Verification
- **Command:** `bin/rspec`
- **Description:** Run full test suite after major updates
- **Manual Test:** Not required

#### 3.3 - Stage 3 Manual Test Checkpoint
- **Priority:** CRITICAL
- **Type:** Manual
- **Description:** Full admin UI smoke test after major gem updates
- **Manual Test:**
  1. Start server: `bin/rails s -p 3000`
  2. Visit: http://localhost:3000/admin/dashboard
  3. Test:
     - Dashboard loads correctly
     - Navigation between pages works
     - Any forms or actions still function
  4. Report: Pass/Fail

---

### Stage 4: pagy Update - Future Migration

**Focus:** Plan for pagy migration (9.x → 43.x)

#### 4.1 - Research pagy version history
- **Priority:** MEDIUM
- **Type:** Research
- **Description:**
  - Check pagy changelog between 9.x and 43.x
  - Identify major breaking changes in each version bump
  - Document what changed in v10, v20, v30, etc.
- **Manual Test:** Not required

#### 4.2 - Analyze current pagy usage in codebase
- **Priority:** MEDIUM
- **Type:** Research
- **Command:** `grep -r "pagy" app/ --include="*.rb"`
- **Description:**
  - Find all pagy helpers used (pagy_nav, pagy_nav_js, etc.)
  - Identify any custom pagy configuration
  - Document what needs to change for v10+ API
- **Manual Test:** Not required

#### 4.3 - Plan incremental update path
- **Priority:** MEDIUM
- **Type:** Planning
- **Description:**
  - Determine if direct 9.x → 43.x is possible or needs intermediate steps
  - Create migration plan: which versions to update through
  - Document code changes needed for each version jump
- **Manual Test:** Not required

#### 4.4 - Execute pagy update (future)
- **Priority:** LOW
- **Type:** Configuration
- **Description:** Perform the pagy update in a future session when ready
- **Manual Test:** Will be required after update

---

## Quality Checks

### Stage 1 Completion Criteria
- [ ] Bundle update --patch completed
- [ ] All tests pass (bin/rspec)
- [ ] Manual smoke test: admin UI loads

### Stage 2 Completion Criteria
- [ ] turbo-rails updated
- [ ] pry-remote-reloaded updated (includes slop transitive)
- [ ] All tests pass (bin/rspec)
- [ ] Manual test: login flow + page navigation

### Stage 3 Completion Criteria
- [ ] shoulda-matchers updated
- [ ] All tests pass (bin/rspec)
- [ ] Manual test: full admin UI smoke test

### Stage 4 Completion Criteria (Future)
- [ ] Research completed on pagy version history
- [ ] Current usage analyzed in codebase
- [ ] Incremental update path documented
- [ ] Update scheduled for future session

---

## Rollback Plan

If issues occur:

1. **Restore Gemfile.lock:** `git checkout Gemfile.lock`
2. **Reinstall gems:** `bundle install`
3. **Run tests:** `bin/rspec`
4. If still failing, revert Gemfile changes: `git checkout Gemfile`

---

## Estimated Time

| Stage | Tasks | Time | Manual Tests |
|-------|-------|------|---------------|
| 1 | 3 | 15 min | 1 (smoke test) |
| 2 | 3 | 20 min | 1 (auth + nav) |
| 3 | 3 | 20 min | 1 (full smoke) |
| 4 | 4 | Research only | 0 |
| **Total** | **13** | **~55 min (+ research)** | **3** |

---

## Related Documentation

- [RubyGems.org](https://rubygems.org) - Gem registry
- [bundle outdated](https://bundler.io/man/bundle-outdated.1.html) - Bundler outdated command
- [AGENTS.md](../../AGENTS.md) - Project conventions

(End of file - total 268 lines)
