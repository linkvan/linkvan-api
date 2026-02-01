# RuboCop Remediation Plan

## Status: Not Started

## Created: 2026-02-01

## Goal

Systematically address 1,651 RuboCop offenses to improve code quality, maintainability, and Rails/RSpec best practices compliance.

## Analysis Summary

**Total Offenses:** 1,651 across 94 files

**Breakdown by Category:**
- RSpec Style: 1,429 offenses (87%) - Testing patterns and style
- Rails Best Practices: 32 offenses - Framework conventions
- Code Complexity: 11 offenses - Metrics violations
- Other: 179 offenses - Layout, style, lint

## Priority System

- **CRITICAL** - Affects app correctness, security, or stability
- **HIGH** - Affects maintainability, should be addressed soon
- **MEDIUM** - Style improvements, address when convenient
- **LOW** - Optional style preferences, can be deferred

## Implementation Stages

### Stage 1: CRITICAL Priority - Foundation

**Focus:** Configure foundation settings that impact the entire application.

#### 1.1 Configure Vancouver Timezone
- **Priority:** CRITICAL
- **Type:** Configuration
- **Location:** `config/application.rb`
- **Offense Count:** N/A (prevents 8 future offenses)
- **Estimated Time:** 5 minutes
- **Description:** Set application timezone to Pacific Time (Vancouver) to align with user base location and resolve TimeZone-related offenses.
- **Implementation:** Uncomment and set `config.time_zone = "Pacific Time (US & Canada)"` in `application.rb`
- **Testing:** Verify `Rails.application.config.time_zone` returns correct value in console

#### 1.2 Disable RSpec/MultipleExpectations
- **Priority:** CRITICAL
- **Type:** Configuration
- **Location:** `.rubocop.yml`
- **Offense Count:** 443
- **Estimated Time:** 5 minutes
- **Description:** Disable the RSpec/MultipleExpectations cop to reduce noise. This cop enforces single expectation per test, but refactoring 443 instances is impractical for current workflow.
- **Implementation:** Add `RSpec/MultipleExpectations: Enabled: false` to `.rubocop.yml`
- **Testing:** Run `bin/rubocop` and verify count drops by 443

**Stage 1 Total: 2 tasks, 443 offenses addressed**

---

### Stage 2: HIGH Priority - Immediate Fixes

**Focus:** Fix specific code issues that impact correctness and maintainability.

#### 2.1 Fix Rails/TimeZone Offenses
- **Priority:** HIGH
- **Type:** Code Fix
- **Location:**
  - `app/models/facility_time_slot.rb` (lines 21, 25)
  - `app/controllers/admin/facility_time_slots_controller.rb` (lines 63-64)
- **Offense Count:** 4
- **Estimated Time:** 15 minutes
- **Description:** Replace `.to_time` with `.in_time_zone` for proper timezone handling in facility time slot operations.
- **Implementation:**
  - In model: Use `hour_min_to_time_string(...).in_time_zone`
  - In controller: Use `parameters[:start_time].to_s.in_time_zone` or parse with timezone
- **Testing:**
  - Run `spec/models/facility_time_slot_spec.rb`
  - Verify time slot operations work correctly with timezone

#### 2.2 Fix Rails/RedundantPresenceValidationOnBelongsTo
- **Priority:** HIGH
- **Type:** Auto-correctable Code Fix
- **Location:** `app/models/facility_service.rb` line 7
- **Offense Count:** 1
- **Estimated Time:** 5 minutes
- **Description:** Rails 5+ automatically validates presence of belongs_to associations. Remove explicit `validates :facility, :service, presence: true` as it's redundant.
- **Implementation:** RuboCop auto-correct will remove the line
- **Testing:** Run `spec/models/facility_service_spec.rb` to verify validations still work

**Stage 2 Total: 2 tasks, 5 offenses addressed**

---

### Stage 3: MEDIUM Priority - Rails Model Fixes

**Focus:** Fix Rails-specific model and configuration issues.

#### 3.1 Exclude GeoLocation from Rails/DynamicFindBy
- **Priority:** MEDIUM
- **Type:** Configuration
- **Location:** `.rubocop.yml`
- **Offense Count:** 1 (false positive)
- **Estimated Time:** 5 minutes
- **Description:** Exclude `app/models/geo_location.rb` from Rails/DynamicFindBy cop. `GeoLocation` is a plain Ruby class (not ActiveRecord), and `find_by_address` is a custom class method, not a dynamic finder.
- **Implementation:** Add exclude for `app/models/geo_location.rb` in Rails/DynamicFindBy cop configuration
- **Testing:** Run `bin/rubocop --only Rails/DynamicFindBy` and verify no offenses

#### 3.2 Add Dependent Option to Service Model
- **Priority:** MEDIUM
- **Type:** Code Fix
- **Location:** `app/models/service.rb` line 4
- **Offense Count:** 1
- **Estimated Time:** 10 minutes
- **Description:** Specify dependent strategy for `has_many :facility_services` to prevent orphaned records and define expected behavior when a service is deleted.
- **Implementation:** Add `dependent: :restrict_with_error` to prevent deletion of services with associated facility_services
- **Code:**
  ```ruby
  has_many :facility_services, dependent: :restrict_with_error
  ```
- **Testing:**
  - Run `spec/models/service_spec.rb`
  - Test that deleting a service with facility_services raises an error

#### 3.3 Disable Rails/I18nLocaleTexts
- **Priority:** MEDIUM
- **Type:** Configuration
- **Location:** `.rubocop.yml`
- **Offense Count:** 4
- **Estimated Time:** 5 minutes
- **Description:** Disable i18n locale texts requirement. Current offenses are in admin-only areas (tools controller alerts, mailer subjects) and the application is single-language (English only).
- **Implementation:** Add `Rails/I18nLocaleTexts: Enabled: false` to `.rubocop.yml`
- **Testing:** Run `bin/rubocop --only Rails/I18nLocaleTexts` and verify no offenses

**Stage 3 Total: 3 tasks, 6 offenses addressed**

---

### Stage 4: MEDIUM Priority - RSpec Batch 1

**Focus:** Fix the largest batch of RSpec auto-correctable offenses.

#### 4.1 Run RSpec/ReceiveMessages Auto-Correction
- **Priority:** MEDIUM
- **Type:** Safe Auto-correctable
- **Location:** 11 spec files
- **Offense Count:** 159
- **Estimated Time:** 5 minutes
- **Description:** Combine multiple consecutive `receive` stubs into single `receive_messages` calls for cleaner test setup.
- **Files Affected:**
  - `spec/components/facilities/show_component_spec.rb` (11)
  - `spec/controllers/admin/alerts_controller_spec.rb` (9)
  - `spec/controllers/admin/facilities_controller_spec.rb` (3)
  - `spec/controllers/admin/facilities_nested_controllers_spec.rb` (15)
  - `spec/controllers/admin/notices_controller_spec.rb` (3)
  - `spec/controllers/admin/users_controller_spec.rb` (6)
  - `spec/controllers/api/zones_controller_spec.rb` (54)
  - `spec/models/site_stats_spec.rb` (10)
  - `spec/services/external/vancouver_city/syncer_spec.rb` (2)
  - `spec/services/locations/searcher_spec.rb` (48)
- **Implementation:** `bin/rubocop --only RSpec/ReceiveMessages -a`
- **Testing:** Run affected spec files to verify no regressions

**Stage 4 Total: 1 task, 159 offenses addressed**

---

### Stage 5: MEDIUM Priority - RSpec Batch 2

**Focus:** Fix the second largest batch of RSpec auto-correctable offenses.

#### 5.1 Run RSpec/DescribedClass Auto-Correction
- **Priority:** MEDIUM
- **Type:** Safe Auto-correctable
- **Location:** 8 spec files
- **Offense Count:** 80
- **Estimated Time:** 5 minutes
- **Description:** Replace explicit class names with `described_class` for better maintainability when renaming classes.
- **Files Affected:**
  - `spec/models/analytics/event_spec.rb` (6)
  - `spec/models/analytics/impression_spec.rb` (23)
  - `spec/models/analytics/visit_spec.rb` (2)
  - `spec/models/facility_schedule_spec.rb` (2)
  - `spec/models/facility_spec.rb` (1)
  - `spec/models/status_spec.rb` (1)
  - `spec/services/external/vancouver_city/facility_syncer/service_synchronization_spec.rb` (1)
  - `spec/services/translator_spec.rb` (44)
- **Implementation:** `bin/rubocop --only RSpec/DescribedClass -a`
- **Testing:** Run affected spec files to verify no regressions

**Stage 5 Total: 1 task, 80 offenses addressed**

---

### Stage 6: MEDIUM Priority - RSpec Batch 3

**Focus:** Fix medium-size RSpec auto-correctable offenses.

#### 6.1 Run RSpec/IncludeExamples Auto-Correction
- **Priority:** MEDIUM
- **Type:** Safe Auto-correctable
- **Location:** 4 spec files
- **Offense Count:** 20
- **Estimated Time:** 5 minutes
- **Description:** Replace `include_examples` with `it_behaves_like` for shared examples.
- **Files Affected:**
  - `spec/controllers/api/facilities_controller_spec.rb` (2)
  - `spec/controllers/api/zones_controller_spec.rb` (1)
  - `spec/models/facility_spec.rb` (1)
  - `spec/models/facility_time_slot_spec.rb` (16)
- **Implementation:** `bin/rubocop --only RSpec/IncludeExamples -a`
- **Testing:** Run affected spec files to verify no regressions

#### 6.2 Run RSpec/BeEq Auto-Correction
- **Priority:** MEDIUM
- **Type:** Safe Auto-correctable
- **Location:** 2 spec files
- **Offense Count:** 11
- **Estimated Time:** 5 minutes
- **Description:** Prefer `be` over `eq` for equality comparisons with boolean/nil values.
- **Files Affected:**
  - `spec/controllers/api/home_controller_spec.rb` (6)
  - `spec/models/facility_time_slot_spec.rb` (5)
- **Implementation:** `bin/rubocop --only RSpec/BeEq -a`
- **Testing:** Run affected spec files to verify no regressions

**Stage 6 Total: 2 tasks, 31 offenses addressed**

---

### Stage 7: MEDIUM Priority - RSpec Batch 4

**Focus:** Fix the smallest RSpec auto-correctable offenses.

#### 7.1 Run RSpec/VerifiedDoubleReference Auto-Correction
- **Priority:** MEDIUM
- **Type:** Safe Auto-correctable
- **Location:** 2 spec files
- **Offense Count:** 9
- **Estimated Time:** 5 minutes
- **Description:** Use constant class references instead of string references for verified doubles.
- **Files Affected:**
  - `spec/models/location_spec.rb` (1)
  - `spec/services/locations/searcher_spec.rb` (8)
- **Implementation:** `bin/rubocop --only RSpec/VerifiedDoubleReference -a`
- **Testing:** Run affected spec files to verify no regressions

#### 7.2 Run RSpec/SharedExamples Auto-Correction
- **Priority:** MEDIUM
- **Type:** Safe Auto-correctable
- **Location:** 6 spec files
- **Offense Count:** 8
- **Estimated Time:** 5 minutes
- **Description:** Prefer titleized string names over symbol names for shared examples.
- **Files Affected:**
  - `spec/controllers/api/facilities_controller_spec.rb` (2)
  - `spec/controllers/api/home_controller_spec.rb` (2)
  - `spec/controllers/api/zones_controller_spec.rb` (1)
  - `spec/models/facility_spec.rb` (1)
  - `spec/support/shared_examples/api_tokens.rb` (1)
  - `spec/support/shared_examples/discardable.rb` (1)
- **Implementation:** `bin/rubocop --only RSpec/SharedExamples -a`
- **Testing:** Run affected spec files to verify no regressions

**Stage 7 Total: 2 tasks, 17 offenses addressed**

---

### Stage 8: LOW Priority - Verification

**Focus:** Verify and validate existing configuration.

#### 8.1 Verify Rails/SkipsModelValidations Configuration
- **Priority:** LOW
- **Type:** Verification
- **Location:** `.rubocop.yml` and various files
- **Offense Count:** Already configured (0 to fix)
- **Estimated Time:** 10 minutes
- **Description:** Verify existing configuration properly handles intentional validation skips. Current exclusions for migrations are correct. The `discardable.rb` concern has intentional `# rubocop:disable` comments for soft-delete performance.
- **Implementation:** Review configuration and verify it's still appropriate
- **Files to Review:**
  - `.rubocop.yml` - Lines 57-59 (migration exclusions)
  - `app/models/concerns/discardable.rb` - Lines 46, 58 (intentional skips with comments)
  - `spec/models/site_stats_spec.rb` - Test setup (acceptable usage)
- **Testing:** Run `bin/rubocop --only Rails/SkipsModelValidations` and verify no unexpected offenses

**Stage 8 Total: 1 task, verification only**

---

## Implementation Guidelines

### Configuration Changes

- **.rubocop.yml** modifications should follow existing indentation and structure
- Add configuration sections at appropriate positions (grouped by cop type)
- Document reasons for any exclusions with inline comments

### Code Changes

- **Timezone fixes:** Ensure `.in_time_zone` is used consistently for user-facing time operations
- **Model changes:** Test thoroughly before and after modifications to ensure no regression
- **RSpec changes:** All are safe auto-corrections, but verify tests pass after batch updates

### Testing Strategy

1. **Before changes:** Run `bin/rspec` to establish baseline
2. **After each stage:** Run relevant tests to verify no regressions
3. **Final verification:** Run full test suite and `bin/rubocop` to confirm all addressed offenses are resolved

---

## Quality Checks

### Stage 1 Completion Criteria
- [ ] Application timezone configured correctly
- [ ] RSpec/MultipleExpectations disabled
- [ ] RuboCop count reduced by 443

### Stage 2 Completion Criteria
- [ ] Rails/TimeZone offenses resolved (4)
- [ ] Redundant validation removed (1)
- [ ] Time zone operations work correctly
- [ ] Model specs passing

### Stage 3 Completion Criteria
- [ ] GeoLocation excluded from DynamicFindBy
- [ ] Service model has dependent option
- [ ] Rails/I18nLocaleTexts disabled
- [ ] All Rails-specific offenses resolved

### Stage 4-7 Completion Criteria
- [ ] All 287 RSpec auto-correctable offenses resolved
- [ ] Full test suite passing (`bin/rspec`)
- [ ] No test failures introduced by auto-corrections

### Stage 8 Completion Criteria
- [ ] Rails/SkipsModelValidations configuration verified
- [ ] No unexpected offenses found

### Overall Completion Criteria
- [ ] All addressed RuboCop offenses resolved
- [ ] Code quality improved without breaking changes
- [ ] Test suite passing with 100% coverage maintained
- [ ] Documentation updated (this plan and tracker)
- [ ] Run `bin/rubocop` and verify offense count reduced by at least 443

---

## Progress Tracking Reference

See [tracker.md](./tracker.md) for detailed status of each item.

---

## Related Documentation

- [AGENTS.md](../../AGENTS.md) - Rails Code Quality skill for additional guidance
- [RuboCop Rails Documentation](https://docs.rubocop.org/rubocop-rails/)
- [RuboCop RSpec Documentation](https://docs.rubocop.org/rubocop-rspec/)
