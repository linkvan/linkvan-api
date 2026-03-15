# Rails 8.1 Upgrade Tracker

## Plan Reference

[plan.md](./plan.md)

---

## Created: 2026-03-15

## Last Updated: 2026-03-15

---

## Summary

| Priority | Total | Not Started | In Progress | Completed | Blocked |
|----------|-------|-------------|-------------|-----------|---------|
| CRITICAL | 11    | 11          | 0           | 0         | 0       |
| HIGH     | 7     | 7           | 0           | 0         | 0       |
| MEDIUM   | 1     | 1           | 0           | 0         | 0       |
| LOW      | 2     | 2           | 0           | 0         | 0       |
| **TOTAL**| **21**| **21**      | **0**       | **0**     | **0**   |

**Current Rails Version:** 8.0.3  
**Target Rails Version:** 8.1.x

---

## Stage 1: CRITICAL - Pre-Upgrade Preparation

**Focus:** Ensure test suite passes and create backup point.

### Item Tables

#### 1.1 - Run Full Test Suite

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 1.1 | CRITICAL | ⬜ Not Started | Run `bin/rspec` - verify 1912 examples, 0 failures |

#### 1.2 - Run RuboCop Check

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 1.2 | CRITICAL | ⬜ Not Started | Run `bin/rubocop` - verify 0 offenses |

#### 1.3 - Commit Current State

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 1.3 | CRITICAL | ⬜ Not Started | Create commit to preserve working state |

---

## Stage 2: CRITICAL - Update Ruby Gems

**Focus:** Update Rails and related gems.

### Item Tables

#### 2.1 - Update Rails Version in Gemfile

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.1 | CRITICAL | ⬜ Not Started | Gemfile | Change `~> 8.0.3` to `~> 8.1.0` |

#### 2.2 - Run Bundle Update

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 2.2 | CRITICAL | ⬜ Not Started | Run `bundle update rails` |

#### 2.3 - Smoke Test - App Boots

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 2.3 | HIGH | ⬜ Not Started | Run `bin/rails console`, type `Rails.root` to verify |

---

## Stage 3: CRITICAL - Handle Framework Defaults (Gradual)

**Focus:** Configure new Rails 8.1 defaults using gradual approach per Rails guide.

### Item Tables

#### 3.1 - Run bin/rails app:update

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 3.1 | CRITICAL | ⬜ Not Started | Run `bin/rails app:update` to generate defaults file |

#### 3.2 - Review new_framework_defaults_8_1.rb

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.2 | CRITICAL | ⬜ Not Started | config/initializers/new_framework_defaults_8_1.rb | Review settings, keep disabled initially |

#### 3.3 - Test with Defaults Disabled

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 3.3 | HIGH | ⬜ Not Started | Run tests with load_defaults still at 8.0 |

#### 3.4 - Manual Test - Core Functionality

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 3.4 | HIGH | ⬜ Not Started | Test: home page, login, admin, API endpoints |

#### 3.5 - Enable Defaults Gradually

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 3.5 | MEDIUM | ⬜ Not Started | Enable defaults one by one per Rails guide |

#### 3.6 - Manual Test - With New Defaults

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 3.6 | HIGH | ⬜ Not Started | Verify core functionality works with new defaults |

#### 3.7 - Update config.load_defaults

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.7 | CRITICAL | ⬜ Not Started | config/application.rb | Change to 8.1 AFTER defaults verified |

#### 3.8 - Cleanup

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 3.8 | LOW | ⬜ Not Started | Remove new_framework_defaults_8_1.rb after upgrade complete |

---

## Stage 4: HIGH - Update JavaScript Dependencies

**Focus:** Update Rails JavaScript packages to 8.1.

### Item Tables

#### 4.1 - Update package.json Rails Packages

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 4.1 | HIGH | ⬜ Not Started | package.json | Update @rails/* to ^8.1.0 |

#### 4.2 - Install JavaScript Dependencies

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 4.2 | HIGH | ⬜ Not Started | Run `npm install` or `bin/rails javascript:install` |

---

## Stage 5: HIGH - Schema Changes

**Focus:** Handle schema.rb alphabetical sorting.

### Item Tables

#### 5.1 - Review schema.rb Changes

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 5.1 | HIGH | ⬜ Not Started | db/schema.rb | Review column order changes |

#### 5.2 - Consider Using structure.sql

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 5.2 | LOW | ⬜ Not Started | Optional: use structure.sql to preserve column order |

---

## Stage 6: CRITICAL - Verification

**Focus:** Verify upgrade successful.

### Item Tables

#### 6.1 - Run Test Suite

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 6.1 | CRITICAL | ⬜ Not Started | Run `bin/rspec` - verify all tests pass |

#### 6.2 - Run RuboCop

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 6.2 | CRITICAL | ⬜ Not Started | Run `bin/rubocop` - verify 0 offenses |

#### 6.3 - Verify Rails Version

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 6.3 | CRITICAL | ⬜ Not Started | Run `bin/rails --version` - confirm 8.1.x |

#### 6.4 - Manual Test - Final Verification

| ID | Priority | Status | Notes |
|----|----------|--------|-------|
| 6.4 | HIGH | ⬜ Not Started | Final manual smoke test: home, login, admin, CRUD, API |

---

## Dependencies

### Stage Dependencies

- **Stage 1** must complete before all other stages
- **Stage 2** must complete before Stage 3
- **Stage 3** must complete before Stage 4
- **Stage 4** should complete before Stage 6
- **Stage 5** can run in parallel with Stage 4 or 6
- **Stage 6** is final verification - must complete last

### Blockers

None identified at this time.

---

## Progress Tracking

```
Stage 1 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░ 0/3 items completed (0%)
Stage 2 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░ 0/3 items completed (0%)
Stage 3 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░ 0/8 items completed (0%)
Stage 4 (HIGH):      ░░░░░░░░░░░░░░░░░░░░ 0/2 items completed (0%)
Stage 5 (HIGH):      ░░░░░░░░░░░░░░░░░░░░ 0/2 items completed (0%)
Stage 6 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░ 0/4 items completed (0%)
Overall:             ░░░░░░░░░░░░░░░░░░░░ 0/22 items completed (0%)
```

---

## Status Legend

| Icon | Status | Description |
|------|--------|-------------|
| ⬜ | Not Started | Item has not been started |
| 🔄 | In Progress | Item is currently being worked on |
| ✅ | Completed | Item has been successfully implemented and verified |
| ⏸️ | On Hold | Item is paused indefinitely |
| 🚫 | Blocked | Item has blockers preventing progress |

---

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-03-15 | Initial plan and tracker creation | Assistant |

---

## Notes

- **Manual tests**: I will ask YOU to test in your browser - I cannot do browser-based testing
- Rails 8.1 is a minor upgrade with minimal breaking changes
- Primary change is alphabetical sorting of schema.rb columns
- JavaScript packages (@rails/*) need updating to match Ruby gem version
- All gems in Gemfile are already compatible with Rails 8.1
- **Gradual Framework Defaults**: Per Rails guide - test with defaults disabled first, then enable gradually
- Keep `config.load_defaults 8.0` until all new defaults are verified working

## Pre-Upgrade Checklist

- [ ] Current tests passing
- [ ] Zero RuboCop offenses
- [ ] Recent git commit
- [ ] Review Gemfile.lock changes after bundle update
- [ ] Review db/schema.rb changes after migrations

## Rollback Steps

If issues occur:
1. `git checkout Gemfile Gemfile.lock`
2. `bundle install`
3. `git checkout config/application.rb` (revert load_defaults)
4. `git checkout package.json`
5. `npm install`
