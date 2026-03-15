# Rails 8.1 Upgrade Plan

## Status: COMPLETE

## Created: 2026-03-15

## Goal

Upgrade the Linkvan API application from Rails 8.0 to Rails 8.1 while maintaining full test coverage and zero RuboCop offenses.

## Current State

- **Current Rails Version**: 8.0.3
- **Target Rails Version**: 8.1.x
- **Ruby Version**: 3.4.5 (compatible with Rails 8.1)
- **load_defaults**: 8.0
- **Test Suite**: 1912 examples, 0 failures
- **RuboCop**: 0 offenses

## Analysis Summary

### Rails 8.0 → 8.1 Changes

**Breaking Changes:**
1. **schema.rb columns sorted alphabetically** - Active Record now sorts table columns in `schema.rb` alphabetically by default

**No Breaking Changes for This App:**
- All other changes in Rails 8.1 are minimal and non-breaking for this application

### JavaScript Dependencies

| Package | Current | Required for 8.1 | Status |
|---------|---------|------------------|--------|
| `@rails/actioncable` | ^8.0.300 | ^8.1.0 | ⚠️ Update needed |
| `@rails/actiontext` | ^8.0.300 | ^8.1.0 | ⚠️ Update needed |
| `@rails/activestorage` | ^8.0.300 | ^8.1.0 | ⚠️ Update needed |
| `@hotwired/turbo-rails` | ^8.0.18 | ^8.1.0 | ⚠️ Update needed |
| `@hotwired/stimulus` | ^3.2.2 | ^3.2.2 | ✅ OK |
| `@rails/request.js` | ^0.0.12 | ^0.0.12 | ✅ OK |
| `trix` | ^2.1.4 | ^2.1.4 | ✅ OK |
| `sass` | ^1.77.8 | ^1.77.8 | ✅ OK |
| `bulma` | ^1.0.2 | ^1.0.2 | ✅ OK |
| `@fortawesome/fontawesome-free` | ^6.5.1 | ^6.5.1 | ✅ OK |

### Ruby Gems Compatibility

All gems in Gemfile are compatible with Rails 8.1:
- **devise**: 4.9.3 ✅
- **puma**: 6.4.2 ✅
- **redis**: 5.4.1 ✅
- **view_component**: ✅
- **pagy**: ✅
- **hotwire-rails**: ✅
- **turbo-rails**: ✅

---

## Priority System

- **CRITICAL** - Must complete for successful upgrade
- **HIGH** - Should complete for full compatibility
- **MEDIUM** - Recommended for best practices
- **LOW** - Optional improvements

---

## Manual Test Protocol

**What "Manual Test" Means:** At specific checkpoints, I will **ask you** (the user) to test the application manually in your browser/local environment. I cannot run browser-based tests myself.

**Protocol:**
1. I will pause execution at each manual test checkpoint
2. I will tell you exactly what to test and how
3. You test and report back pass/fail
4. I continue based on your feedback

---

## Implementation Stages

### Stage 1: CRITICAL - Pre-Upgrade Preparation

**Focus:** Ensure test suite passes and create backup point.

#### 1.1 Run Full Test Suite
- **Priority:** CRITICAL
- **Type:** Verification
- **Command:** `bin/rspec`
- **Expected:** 1912 examples, 0 failures
- **Description:** Verify current test suite passes before making any changes

#### 1.2 Run RuboCop Check
- **Priority:** CRITICAL
- **Type:** Verification
- **Command:** `bin/rubocop`
- **Expected:** 0 offenses
- **Description:** Verify no RuboCop offenses before upgrade

#### 1.3 Commit Current State
- **Priority:** CRITICAL
- **Type:** Version Control
- **Description:** Create a commit to preserve current working state

**Stage 1 Total: 3 tasks**

---

### Stage 2: CRITICAL - Update Ruby Gems

**Focus:** Update Rails and related gems.

#### 2.1 Update Rails Version in Gemfile
- **Priority:** CRITICAL
- **Type:** Configuration
- **Location:** `Gemfile` line 7
- **Change:**
  ```ruby
  # Before
  gem "rails", "~> 8.0.3"
  
  # After
  gem "rails", "~> 8.1.0"
  ```
- **Description:** Update Rails version constraint to 8.1.x

#### 2.2 Run Bundle Update
- **Priority:** CRITICAL
- **Type:** Dependency Update
- **Command:** `bundle update rails`
- **Description:** Update Rails and all dependencies

#### 2.3 Smoke Test - App Boots
- **Priority:** HIGH
- **Type:** Manual Verification
- **Command:** `bin/rails console`
- **Description:** Verify Rails can load without errors
- **Manual Test:** Type `Rails.root` in console to confirm app is loaded

**Stage 2 Total: 3 tasks**

---

### Stage 3: CRITICAL - Handle Framework Defaults (Gradual)

**Focus:** Configure new Rails 8.1 defaults using gradual approach per Rails guide.

#### 3.1 Run bin/rails app:update
- **Priority:** CRITICAL
- **Type:** Code Generation
- **Command:** `bin/rails app:update`
- **Description:** Run Rails update task to generate new framework defaults file

#### 3.2 Review new_framework_defaults_8_1.rb
- **Priority:** CRITICAL
- **Type:** Configuration Review
- **Location:** `config/initializers/new_framework_defaults_8_1.rb`
- **Description:** Review each setting - keep defaults disabled initially

#### 3.3 Test with Defaults Disabled
- **Priority:** HIGH
- **Type:** Verification
- **Command:** `bin/rspec`
- **Description:** Run tests with load_defaults still at 8.0 to verify base upgrade

#### 3.4 Manual Test - Core Functionality
- **Priority:** HIGH
- **Type:** Manual Verification
- **Description:** Test key app functionality manually
- **Manual Tests:**
  - [ ] Home page loads
  - [ ] Login/logout works
  - [ ] Admin dashboard accessible (if applicable)
  - [ ] API endpoints respond correctly
- **Note:** This is the critical manual test before enabling new defaults

#### 3.5 Enable Defaults Gradually
- **Priority:** MEDIUM
- **Type:** Configuration
- **Location:** `config/initializers/new_framework_defaults_8_1.rb`
- **Description:** Per Rails guide - enable defaults one by one, testing after each

#### 3.6 Manual Test - With New Defaults
- **Priority:** HIGH
- **Type:** Manual Verification
- **Description:** After enabling defaults, verify app still works
- **Manual Tests:**
  - [ ] Core pages still load
  - [ ] Database operations work
  - [ ] No new errors in logs

#### 3.7 Update config.load_defaults
- **Priority:** CRITICAL
- **Type:** Configuration
- **Location:** `config/application.rb`
- **Change:** `config.load_defaults 8.1`
- **Description:** Only update AFTER all defaults verified

#### 3.8 Cleanup
- **Priority:** LOW
- **Type:** Cleanup
- **Description:** Remove new_framework_defaults_8_1.rb after fully upgraded

**Stage 3 Total: 8 tasks**

---

### Stage 4: HIGH - Update JavaScript Dependencies

**Focus:** Update Rails JavaScript packages to 8.1.

#### 4.1 Update package.json Rails Packages
- **Priority:** HIGH
- **Type:** Configuration
- **Location:** `package.json`
- **Changes:**
  ```json
  "@rails/actioncable": "^8.1.0",
  "@rails/actiontext": "^8.1.0",
  "@rails/activestorage": "^8.1.0"
  ```
- **Description:** Update Rails JavaScript packages to 8.1 (keep turbo-rails at ^8.0)

#### 4.2 Install JavaScript Dependencies
- **Priority:** HIGH
- **Type:** Dependency Update
- **Command:** `bin/rails javascript:install` or `npm install`
- **Description:** Install updated JavaScript packages

**Stage 4 Total: 2 tasks**

---

### Stage 5: HIGH - Schema Changes

**Focus:** Handle schema.rb alphabetical sorting.

#### 5.1 Review schema.rb Changes
- **Priority:** HIGH
- **Type:** Verification
- **Location:** `db/schema.rb`
- **Description:** After running migrations, review schema.rb to see column order changes
- **Note:** This is a non-breaking change - columns will be sorted alphabetically

#### 5.2 Consider Using structure.sql (Optional)
- **Priority:** LOW
- **Type:** Configuration
- **Location:** `config/application.rb`
- **Alternative:** If alphabetical sorting causes noisy diffs, consider using `structure.sql` instead
- **Description:** Alternative schema dump format preserves exact column order

**Stage 5 Total: 2 tasks**

---

### Stage 6: CRITICAL - Verification

**Focus:** Verify upgrade successful.

#### 6.1 Run Test Suite
- **Priority:** CRITICAL
- **Type:** Verification
- **Command:** `bin/rspec`
- **Expected:** All tests pass (1912 examples, 0 failures)
- **Description:** Verify full test suite passes after upgrade

#### 6.2 Run RuboCop
- **Priority:** CRITICAL
- **Type:** Verification
- **Command:** `bin/rubocop`
- **Expected:** 0 offenses
- **Description:** Verify no RuboCop offenses introduced

#### 6.3 Verify Rails Version
- **Priority:** CRITICAL
- **Type:** Verification
- **Command:** `bin/rails --version`
- **Expected:** Rails 8.1.x
- **Description:** Confirm Rails version updated

#### 6.4 Manual Test - Final Verification
- **Priority:** HIGH
- **Type:** Manual Verification
- **Description:** Final manual smoke test of key functionality
- **Manual Tests:**
  - [ ] Home page loads
  - [ ] Login/logout works  
  - [ ] Admin dashboard (if applicable)
  - [ ] Create/Edit/Delete operations work
  - [ ] API endpoints return expected responses
  - [ ] Check for any errors in logs

**Stage 6 Total: 4 tasks**

---

## Implementation Guidelines

### Pre-Upgrade Checklist

- [ ] Full test suite passing
- [ ] Zero RuboCop offenses
- [ ] Recent backup/commit of current state

### During Upgrade

1. **Gemfile changes** - Always run `bundle update rails` after changing Rails version
2. **Framework defaults** - Review and enable new defaults in generated file
3. **JavaScript** - Update npm packages after Ruby gems
4. **Schema changes** - Expect changes in db/schema.rb (alphabetical sorting)

### Testing Strategy

1. **Before changes:** Run `bin/rspec` to establish baseline
2. **After Gemfile change:** Run `bundle update rails` and check for errors
3. **After app:update:** Review generated files carefully
4. **After complete:** Run full test suite and RuboCop

---

## Quality Checks

### Stage 1 Completion Criteria
- [ ] Test suite passes (1912 examples, 0 failures)
- [ ] RuboCop shows 0 offenses
- [ ] Current state committed to git

### Stage 2 Completion Criteria
- [ ] Gemfile updated to Rails 8.1.x
- [ ] Bundle update successful (no errors)
- [ ] Smoke test: app boots in console

### Stage 3 Completion Criteria
- [ ] new_framework_defaults_8_1.rb reviewed
- [ ] Tests pass with defaults disabled (load_defaults still at 8.0)
- [ ] Manual test: core functionality works
- [ ] Defaults enabled gradually (one by one or batch)
- [ ] Manual test: app works with new defaults
- [ ] config.load_defaults set to 8.1
- [ ] Old defaults file removed

### Stage 4 Completion Criteria
- [ ] package.json updated
- [ ] JavaScript dependencies installed

### Stage 5 Completion Criteria
- [ ] Schema changes reviewed
- [ ] No data loss or corruption

### Stage 6 Completion Criteria
- [ ] All tests passing
- [ ] RuboCop at 0 offenses
- [ ] Rails 8.1.x confirmed
- [ ] Development server starts without errors

---

## Rollback Plan

If issues occur:

1. **Revert Gemfile** - Change back to `~> 8.0.3` and run `bundle install`
2. **Revert config/application.rb** - Set `config.load_defaults 8.0`
3. **Revert package.json** - Restore previous versions
4. **Run git checkout** - Restore any modified files

---

## Estimated Time

| Stage | Tasks | Estimated Time |
|-------|-------|----------------|
| 1 - Pre-Upgrade | 3 | 10 minutes |
| 2 - Update Gems | 3 | 15 minutes |
| 3 - Framework Defaults (Gradual) | 8 | 25 minutes |
| 4 - JavaScript | 2 | 10 minutes |
| 5 - Schema | 2 | 5 minutes |
| 6 - Verification | 4 | 15 minutes |
| **TOTAL** | **22** | **~80 minutes** |

---

## Related Documentation

- [Rails Upgrade Guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)
- [Rails 8.1 Release Notes](https://guides.rubyonrails.org/8_1_release_notes.html)
- [AGENTS.md](../../AGENTS.md) - Project conventions
