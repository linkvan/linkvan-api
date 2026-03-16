# RuboCop Remediation Plan

## Status: COMPLETE

## Completion Date: 2026-03-14

## Final Results
- Original Offenses: 1,651
- Final Offenses: 0
- Reduction: 100%
- Tests: 1912 examples, 0 failures

## Created: 2026-02-01

## Goal

Systematically address 1,651 RuboCop offenses to improve code quality, maintainability, and Rails/RSpec best practices compliance.

## Analysis Summary

**Total Offenses:** 0 (down from 1,651)

**Progress:** 1,651 offenses resolved (100%)

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

#### 3.1 Rename GeoLocation.find_by_address to for_address
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** 
  - `app/models/geo_location.rb` (line 20)
  - `spec/models/geo_location_spec.rb` (lines 99, 111, 117, 126, 139, 151)
- **Offense Count:** 1 (false positive)
- **Estimated Time:** 10 minutes
- **Description:** Rename `find_by_address` method to `for_address` to avoid Rails/DynamicFindBy cop flagging. `GeoLocation` is a plain Ruby class (not ActiveRecord), but using the `find_by_*` naming pattern triggers the cop. Renaming to `for_address` is more descriptive and avoids the pattern entirely.
- **Implementation:** 
  - Rename method definition from `find_by_address` to `for_address`
  - Update all call sites in the spec file
- **Testing:** 
  - Run `bin/rubocop --only Rails/DynamicFindBy` and verify no offenses
  - Run `bin/rspec spec/models/geo_location_spec.rb` and verify all tests pass

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
- **Location:** 3 spec files
- **Offense Count:** 18
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

**Stage 6 Total: 2 tasks, 29 offenses addressed**

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

**Stage 7 Total: 1 task, 9 offenses addressed**

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

### Stage 9: HIGH Priority - Quick Wins Auto-Corrections

**Focus:** Fix all auto-correctable offenses immediately.

#### 9.1 - Run Full Auto-Correction
- **Priority:** HIGH
- **Type:** Auto-correction
- **Location:** Multiple files
- **Offense Count:** 75
- **Estimated Time:** 10 minutes
- **Description:** Run full safe auto-correction to address all remaining auto-correctable offenses across the codebase.
- **Implementation:**
  ```bash
  bin/rubocop --parallel -a
  ```
- **Testing:** Run `bin/rspec` to verify no regressions (1,969 examples, 0 failures)

**Stage 9 Total: 1 task, 75 offenses addressed**

---

### Stage 10: MEDIUM Priority - RSpec Core Pattern Changes

**Focus:** Fix high-impact RSpec pattern violations.

#### 10.1 - Convert to have_received Pattern
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 33
- **Estimated Time:** 30 minutes
- **Description:** Convert `expect(Class).to receive` to `have_received` with spy setup for better test isolation and design.
- **Implementation:** Set up spies and use `have_received` matcher instead of expect-receive
- **Testing:** Run affected spec files to verify no regressions

#### 10.2 - Add Named Subjects
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 38
- **Estimated Time:** 20 minutes
- **Description:** Replace anonymous `subject` with meaningful names for better test clarity and documentation.
- **Implementation Example:**
  ```ruby
  # Before
  subject { Facility.live }
  
  it { expect(subject).to include(live_facility) }
  
  # After
  subject(:live_facilities) { Facility.live }
  
  it { expect(live_facilities).to include(live_facility) }
  ```
- **Testing:** Run affected spec files to verify no regressions

#### 10.3 - Fix Context Wording
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 27
- **Estimated Time:** 15 minutes
- **Description:** Rename context descriptions to start with "when", "with", or "without" for better test documentation.
- **Implementation Examples:**
  ```ruby
  # Before
  context "for show action" do
  context "on create" do
  
  # After
  context "when showing" do
  context "when creating" do
  ```
- **Testing:** Run affected spec files to verify no regressions

#### 10.4 - Use Verifying Doubles
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 22
- **Estimated Time:** 15 minutes
- **Description:** Replace `double()` with `instance_double()` or `class_double()` for better test reliability and interface verification.
- **Implementation:** Use verifying doubles that match real class interfaces, revert to `double()` for external library mocks (e.g., Geocoder)
- **Testing:** Run affected spec files to verify no regressions

**Stage 10 Total: 4 tasks, 120 offenses addressed**

---

### Stage 11: MEDIUM Priority - RSpec Cleanup

**Focus:** Clean up RSpec patterns and organization.

#### 11.1 - Rename Indexed Let Statements
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** 12 spec files
- **Offense Count:** 40
- **Estimated Time:** 30 minutes
- **Description:** Rename `let1`, `let2`, etc. to descriptive names for better test readability.
- **Implementation Example:**
  ```ruby
  # Before
  let(:content1) { { title: "CARD ACTION CONTENT 1", path: "action1" } }
  let(:content2) { { title: "CARD ACTION CONTENT 2", path: "action2" } }
  
  # After
  let(:action_content_1) { { title: "CARD ACTION CONTENT 1", path: "action1" } }
  let(:action_content_2) { { title: "CARD ACTION CONTENT 2", path: "action2" } }
  ```
- **Testing:** Run affected spec files to verify no regressions

#### 11.2 - Fix Let Setup
- **Priority:** MEDIUM
- **Type:** Code Cleanup
- **Location:** 15 spec files
- **Offense Count:** 29
- **Estimated Time:** 15 minutes
- **Description:** Remove unused `let!` statements or convert to `let` for lazy evaluation.
- **Implementation Example:**
  ```ruby
  # Before
  let!(:unused_facility) { create(:facility) }  # Never referenced
  
  # After
  # Remove entirely if unused, or:
  let(:unused_facility) { create(:facility) }  # Lazy evaluation
  ```
- **Testing:** Run affected spec files to verify no regressions

#### 11.3 - Remove Subject Stubs
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 15
- **Estimated Time:** 15 minutes
- **Description:** Refactor tests to avoid stubbing subject methods for better test clarity.
- **Implementation:** Use explicit test setup instead of stubbing subject
- **Testing:** Run affected spec files to verify no regressions

#### 11.4 - Fix Spec File Path Format
- **Priority:** MEDIUM
- **Type:** File Organization
- **Location:** Multiple spec files
- **Offense Count:** 9
- **Estimated Time:** 15 minutes
- **Description:** Move/rename spec files to match described classes for better organization.
- **Implementation:** Rename or move spec files to follow RSpec naming conventions
- **Testing:** Run `bin/rspec` to verify all tests still pass

#### 11.5 - Fix Describe Method
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 13
- **Estimated Time:** 15 minutes
- **Description:** Fix describe block structure to properly describe methods being tested.
- **Implementation:** Ensure describe blocks use proper method descriptions (e.g., `describe "#method_name"`)
- **Testing:** Run affected spec files to verify no regressions

**Stage 11 Total: 5 tasks, 106 offenses addressed**

---

### Stage 12: MEDIUM Priority - Rails & Performance

**Focus:** Fix Rails-specific and performance issues.

#### 12.1 - Document Rails/SkipsModelValidations
- **Priority:** MEDIUM
- **Type:** Documentation
- **Location:** Multiple files
- **Offense Count:** 15
- **Estimated Time:** 15 minutes
- **Description:** Add `# rubocop:disable` comments with rationale for intentional validation skips.
- **Implementation:** Add inline comments explaining why validation skips are intentional
- **Testing:** Run `bin/rubocop --only Rails/SkipsModelValidations` to verify offenses are documented

#### 12.2 - Fix Map Method Chain
- **Priority:** MEDIUM
- **Type:** Performance Fix
- **Location:** `lib/tasks/data.rake`
- **Offense Count:** 2
- **Estimated Time:** 5 minutes
- **Description:** Replace `.map(&:to_s).map(&:method)` with `.map { |x| x.to_s.method }` for better performance.
- **Implementation:** Consolidate map chains into single block
- **Testing:** Run the rake task to verify it still works correctly

**Stage 12 Total: 2 tasks, 17 offenses addressed**

---

### Stage 13: LOW Priority - RSpec Advanced Patterns

**Focus:** Address advanced RSpec pattern improvements.

#### 13.1 - Refactor Any Instance Usage
- **Priority:** LOW
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 0
- **Estimated Time:** N/A
- **Description:** Already addressed in Stage 10 with verifying doubles.

#### 13.2 - Move Expect from Hooks
- **Priority:** LOW
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 0
- **Estimated Time:** N/A
- **Description:** Already addressed in Stage 10.

#### 13.3 - Fix Stubbed Mock
- **Priority:** LOW
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 0
- **Estimated Time:** N/A
- **Description:** Already addressed in Stage 10.

**Stage 13 Total: 3 tasks, 0 offenses addressed (already completed)**

---

### Stage 14: LOW Priority - Style & Lint Cleanup

**Focus:** Clean up style and linting issues.

#### 14.1 - Convert to Compact Module Style
- **Priority:** LOW
- **Type:** Code Refactoring
- **Location:** Multiple files
- **Offense Count:** 0
- **Estimated Time:** N/A
- **Description:** Already fixed in Stage 9 auto-correction.

#### 14.2 - Replace OpenStruct Usage
- **Priority:** LOW
- **Type:** Code Refactoring
- **Location:** `app/models/facility_welcome.rb`
- **Offense Count:** 2
- **Estimated Time:** 10 minutes
- **Description:** Replace OpenStruct with Struct or Hash for better type safety.
- **Implementation:** Use `Struct.new` or Hash instead of `OpenStruct.new`
- **Testing:** Run affected specs to verify behavior unchanged

#### 14.3 - Simplify Multiline Block Chains
- **Priority:** LOW
- **Type:** Code Refactoring
- **Location:** `spec/services/external/vancouver_city/vancouver_api_client/error_handling_spec.rb`
- **Offense Count:** 7
- **Estimated Time:** 15 minutes
- **Description:** Extract intermediate variables for complex block chains to improve readability.
- **Implementation Example:**
  ```ruby
  # Before
  expect { some_action }.to change { complex.calculation.chain }.from(old).to(new)
  
  # After
  before { @original_result = complex.calculation.chain }
  expect { some_action }.to change { complex.calculation.chain }.from(@original_result).to(new)
  ```
- **Testing:** Run the spec file to verify no regressions

#### 14.4 - Fix Remaining Lint Issues
- **Priority:** LOW
- **Type:** Code Quality
- **Location:** Multiple files
- **Offense Count:** 5
- **Estimated Time:** 15 minutes
- **Description:** Fix linting issues for code quality.
- **Implementation:** Fix Lint/MissingSuper, Lint/EmptyBlock, Lint/UselessConstantScoping, Lint/ConstantDefinitionInBlock
- **Testing:** Run `bin/rubocop --only Lint` to verify issues are resolved

**Stage 14 Total: 4 tasks, 14 offenses addressed**

---

## Phase 3: Prioritized Remediation Plan

**Current State:** 380 offenses across 248 files

### Stage 15: HIGH Priority - Auto-Corrections (15 min, 31 offenses)

**Focus:** Run unsafe auto-correction for quick wins.

#### 15.1 - Run Unsafe Auto-Correction
- **Priority:** HIGH
- **Type:** Unsafe Auto-correction
- **Location:** Multiple files
- **Offense Count:** 31
- **Estimated Time:** 15 minutes
- **Description:** Run `bin/rubocop --parallel -A` to fix all auto-correctable offenses, including unsafe corrections.
- **Implementation:** 
  ```bash
  bin/rubocop --parallel -A
  ```
- **Files Affected:**
  - RSpec/IncludeExamples: 20 offenses - Replace `include_examples` with `it_behaves_like`
  - RSpec/BeEq: 11 offenses - Use `be` instead of `eq` for boolean/nil values
  - RSpec/IteratedExpectation: 3 offenses - Use `all` matcher instead of iterating
  - Style/ClassAndModuleChildren: 3 offenses - Convert to compact module syntax
  - Lint/Void: 1 offense - Fix void expressions
- **Testing:** Run `bin/rspec` to verify no regressions

**Stage 15 Total: 1 task, 31 offenses addressed**

---

### Stage 16: MEDIUM Priority - High-Impact Manual Fixes (2 hours, 186 offenses)

**Focus:** Fix the largest RSpec style violations with significant impact.

#### 16.1 - Fix RSpec/ContextWording
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** 25+ spec files
- **Offense Count:** 74
- **Estimated Time:** 45 minutes
- **Description:** Rename context descriptions to start with "when", "with", or "without" for better readability.
- **Implementation Examples:**
  ```ruby
  # Before
  context "for show action" do
  context "switching to live" do
  context "on create" do
  context "GET #index" do
  
  # After
  context "when showing" do
  context "when switching to live" do
  context "when creating" do
  context "when GET #index is called" do
  ```
- **Testing:** Run affected spec files to verify no regressions

#### 16.2 - Rename Named Subjects
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** 6 spec files
- **Offense Count:** 43
- **Estimated Time:** 30 minutes
- **Description:** Replace anonymous `subject` with meaningful names for better test clarity.
- **Implementation Example:**
  ```ruby
  # Before
  subject { Facility.live }
  
  it { expect(subject).to include(live_facility) }
  
  # After
  subject(:live_facilities) { Facility.live }
  
  it { expect(live_facilities).to include(live_facility) }
  ```
- **Testing:** Run affected spec files to verify no regressions

#### 16.3 - Rename Indexed Let Statements
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** 12 spec files
- **Offense Count:** 40
- **Estimated Time:** 30 minutes
- **Description:** Rename `let1`, `let2`, etc. to descriptive names for better test readability.
- **Implementation Example:**
  ```ruby
  # Before
  let(:content1) { { title: "CARD ACTION CONTENT 1", path: "action1" } }
  let(:content2) { { title: "CARD ACTION CONTENT 2", path: "action2" } }
  
  # After
  let(:action_content_1) { { title: "CARD ACTION CONTENT 1", path: "action1" } }
  let(:action_content_2) { { title: "CARD ACTION CONTENT 2", path: "action2" } }
  ```
- **Testing:** Run affected spec files to verify no regressions

#### 16.4 - Fix Let Setup
- **Priority:** MEDIUM
- **Type:** Code Cleanup
- **Location:** 15 spec files
- **Offense Count:** 29
- **Estimated Time:** 15 minutes
- **Description:** Remove unused `let!` statements or convert to `let` for lazy evaluation.
- **Implementation Example:**
  ```ruby
  # Before
  let!(:unused_facility) { create(:facility) }  # Never referenced
  
  # After
  # Remove entirely if unused, or:
  let(:unused_facility) { create(:facility) }  # Lazy evaluation
  ```
- **Testing:** Run affected spec files to verify no regressions

**Stage 16 Total: 4 tasks, 186 offenses addressed**

---

### Stage 17: MEDIUM Priority - Style & Minor Fixes (45 min, 24 offenses)

**Focus:** Clean up style issues and minor code improvements.

#### 17.1 - Fix Style/MultilineBlockChain
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** `spec/services/external/vancouver_city/vancouver_api_client/error_handling_spec.rb`
- **Offense Count:** 7
- **Estimated Time:** 15 minutes
- **Description:** Extract intermediate variables for complex block chains to improve readability.
- **Implementation Example:**
  ```ruby
  # Before
  expect { some_action }.to change { complex.calculation.chain }.from(old).to(new)
  
  # After
  before { @original_result = complex.calculation.chain }
  expect { some_action }.to change { complex.calculation.chain }.from(@original_result).to(new)
  ```
- **Testing:** Run the spec file to verify no regressions

#### 17.2 - Document Rails/SkipsModelValidations
- **Priority:** MEDIUM
- **Type:** Documentation
- **Location:** Multiple files
- **Offense Count:** 15
- **Estimated Time:** 15 minutes
- **Description:** Add `# rubocop:disable` comments with rationale for intentional validation skips.
- **Implementation:** Add inline comments explaining why validation skips are intentional
- **Testing:** Run `bin/rubocop --only Rails/SkipsModelValidations` to verify offenses are documented

#### 17.3 - Fix Performance/MapMethodChain
- **Priority:** MEDIUM
- **Type:** Performance Fix
- **Location:** `lib/tasks/data.rake`
- **Offense Count:** 2
- **Estimated Time:** 5 minutes
- **Description:** Replace `.map(&:to_s).map(&:method)` with `.map { |x| x.to_s.method }` for better performance.
- **Implementation:** Consolidate map chains into single block
- **Testing:** Run the rake task to verify it still works correctly

**Stage 17 Total: 3 tasks, 24 offenses addressed**

---

### Stage 18: MEDIUM Priority - Remaining RSpec Improvements (1.5 hours, 85 offenses)

**Focus:** Address remaining RSpec pattern violations for better test design.

#### 18.1 - Fix RSpec/MessageSpies
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 24
- **Estimated Time:** 30 minutes
- **Description:** Convert `expect(Class).to receive` to `have_received` with spy setup for better test isolation.
- **Implementation:** Set up spies and use `have_received` matcher
- **Testing:** Run affected spec files to verify no regressions

#### 18.2 - Use Verifying Doubles
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 17
- **Estimated Time:** 25 minutes
- **Description:** Replace `double()` with `instance_double()` or `class_double()` for better test reliability.
- **Implementation:** Use verifying doubles that match real class interfaces
- **Testing:** Run affected spec files to verify no regressions

#### 18.3 - Replace AnyInstance
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 16
- **Estimated Time:** 25 minutes
- **Description:** Replace `allow_any_instance_of` with specific test doubles for better test isolation.
- **Implementation:** Create specific test doubles instead of modifying class behavior
- **Testing:** Run affected spec files to verify no regressions

#### 18.4 - Remove Subject Stubs
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 15
- **Estimated Time:** 15 minutes
- **Description:** Refactor tests to avoid stubbing subject methods for better test clarity.
- **Implementation:** Use explicit test setup instead of stubbing subject
- **Testing:** Run affected spec files to verify no regressions

#### 18.5 - Fix Describe Method
- **Priority:** MEDIUM
- **Type:** Code Refactoring
- **Location:** Multiple spec files
- **Offense Count:** 13
- **Estimated Time:** 15 minutes
- **Description:** Fix describe block structure to properly describe methods being tested.
- **Implementation:** Ensure describe blocks use proper method descriptions (e.g., `describe "#method_name"`)
- **Testing:** Run affected spec files to verify no regressions

**Stage 18 Total: 5 tasks, 85 offenses addressed**

---

### Stage 19: LOW Priority - Final Cleanup (1 hour, 46 offenses)

**Focus:** Address remaining low-priority offenses.

#### 19.1 - Fix RSpec/SpecFilePathFormat
- **Priority:** LOW
- **Type:** File Organization
- **Location:** Multiple spec files
- **Offense Count:** 9
- **Estimated Time:** 15 minutes
- **Description:** Move/rename spec files to match described classes for better organization.
- **Implementation:** Rename or move spec files to follow RSpec naming conventions
- **Testing:** Run `bin/rspec` to verify all tests still pass

#### 19.2 - Fix Remaining RSpec Issues
- **Priority:** LOW
- **Type:** Code Cleanup
- **Location:** Multiple spec files
- **Offense Count:** 16
- **Estimated Time:** 20 minutes
- **Description:** Fix remaining minor RSpec violations.
- **Implementation:** Address RSpec/ExpectChange (4), RSpec/ReceiveMessages (4), RSpec/RepeatedDescription (4), RSpec/MultipleDescribes (2), RSpec/RepeatedExampleGroupDescription (2)
- **Testing:** Run affected spec files to verify no regressions

#### 19.3 - Fix Remaining Lint Issues
- **Priority:** LOW
- **Type:** Code Quality
- **Location:** Multiple files
- **Offense Count:** 6
- **Estimated Time:** 15 minutes
- **Description:** Fix linting issues for code quality.
- **Implementation:** Fix Lint/MissingSuper (2), Lint/EmptyBlock (1), Lint/ConstantDefinitionInBlock (1), Lint/UselessConstantScoping (1), Naming/PredicateMethod (1), RSpec/StubbedMock (1)
- **Testing:** Run `bin/rubocop --only Lint` to verify issues are resolved

#### 19.4 - Fix Remaining Style Issues
- **Priority:** LOW
- **Type:** Style Improvements
- **Location:** Multiple files
- **Offense Count:** 3
- **Estimated Time:** 5 minutes
- **Description:** Fix remaining style violations.
- **Implementation:** Fix Style/OpenStructUse (2), Style/SafeNavigationChainLength (1), Style/SingleArgumentDig (1)
- **Testing:** Run `bin/rubocop --only Style` to verify issues are resolved

#### 19.5 - Document Metrics Offenses
- **Priority:** LOW
- **Type:** Documentation
- **Location:** Multiple files
- **Offense Count:** 12
- **Estimated Time:** 5 minutes
- **Description:** Document metric violations with disable comments if acceptable.
- **Implementation:** Add `# rubocop:disable Metrics/*` comments with rationale for complex methods that are acceptable as-is
- **Testing:** Run `bin/rubocop` to verify offenses are documented

**Stage 19 Total: 5 tasks, 46 offenses addressed**

---

## Recommended Execution Order

1. **Immediate:** Stage 15 (15 min, 31 offenses) - Auto-correction
2. **High Impact:** Stage 16 (2 hours, 186 offenses) - ContextWording + NamedSubject + IndexedLet + LetSetup
3. **Quick Wins:** Stage 17 (45 min, 24 offenses) - Style fixes
4. **Remaining:** Stage 18 (1.5 hours, 85 offenses) - Advanced RSpec patterns
5. **Final:** Stage 19 (1 hour, 46 offenses) - Low-priority cleanup

**Total Time:** ~5 hours  
**Total Offenses Resolved:** ~372 out of 380 (98%)

---

## Files with Most Offenses

| File | Offenses | Primary Issues |
|------|----------|----------------|
| spec/models/site_stats_spec.rb | 34 | LetSetup, DescribeMethod, RepeatedDescription |
| spec/models/facility_time_slot_spec.rb | 24 | BeEq, ContextWording, IncludeExamples |
| spec/services/external/vancouver_city/syncer_spec.rb | 24 | ContextWording, DescribeMethod |
| spec/components/facilities/show_component_spec.rb | 22 | SubjectStub, ContextWording |
| spec/models/facility_spec.rb | 19 | NamedSubject, ContextWording |

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
- [ ] GeoLocation.find_by_address renamed to for_address
- [ ] Service model has dependent option
- [ ] Rails/I18nLocaleTexts disabled
- [ ] All Rails-specific offenses resolved

### Stage 4-7 Completion Criteria
- [ ] All 277 RSpec auto-correctable offenses resolved
- [ ] Full test suite passing (`bin/rspec`)
- [ ] No test failures introduced by auto-corrections

### Stage 8 Completion Criteria
- [ ] Rails/SkipsModelValidations configuration verified
- [ ] No unexpected offenses found

### Stage 9 Completion Criteria
- [ ] All auto-correctable offenses resolved (75)
- [ ] Test suite passing with no regressions

### Stage 10 Completion Criteria
- [ ] All message spies converted to have_received (33)
- [ ] All named subjects added (38)
- [ ] All context wording fixed (27)
- [ ] All verifying doubles used (22)
- [ ] All tests passing

### Stage 11 Completion Criteria
- [ ] All indexed let statements renamed (40)
- [ ] All let setup issues resolved (29)
- [ ] All subject stubs removed (15)
- [ ] All spec file path format issues resolved (9)
- [ ] All describe method issues resolved (13)
- [ ] Full test suite passing

### Stage 12 Completion Criteria
- [ ] Rails/SkipsModelValidations documented (15)
- [ ] Map method chain fixed (2)
- [ ] No performance regressions

### Stage 13 Completion Criteria
- [ ] All advanced RSpec patterns addressed (0 - already done)

### Stage 14 Completion Criteria
- [ ] OpenStruct usage replaced (2)
- [ ] Multiline block chains simplified (7)
- [ ] All lint issues resolved (5)
- [ ] No style regressions

### Stage 15 Completion Criteria
- [ ] All auto-correctable offenses resolved (31)
- [ ] Test suite passing with no regressions

### Stage 16 Completion Criteria
- [ ] All RSpec/ContextWording offenses resolved (74)
- [ ] All RSpec/NamedSubject offenses resolved (43)
- [ ] All RSpec/IndexedLet offenses resolved (40)
- [ ] All RSpec/LetSetup offenses resolved (29)
- [ ] Full test suite passing

### Stage 17 Completion Criteria
- [ ] Style/MultilineBlockChain offenses resolved (7)
- [ ] Rails/SkipsModelValidations documented (15)
- [ ] Performance/MapMethodChain fixed (2)
- [ ] No style regressions

### Stage 18 Completion Criteria
- [ ] All RSpec pattern improvements completed (85 offenses)
- [ ] Message spies converted to have_received (24)
- [ ] Verifying doubles used throughout (17)
- [ ] AnyInstance replaced with specific doubles (16)
- [ ] Subject stubs removed (15)
- [ ] Describe method structure fixed (13)
- [ ] All tests passing

### Stage 19 Completion Criteria
- [ ] All file path format issues resolved (9)
- [ ] Remaining RSpec issues resolved (16)
- [ ] All lint issues resolved (6)
- [ ] All style issues resolved (3)
- [ ] Metrics offenses documented (12)
- [ ] Final RuboCop count < 10

### Overall Completion Criteria
- [ ] All addressed RuboCop offenses resolved
- [ ] Code quality improved without breaking changes
- [ ] Test suite passing with 100% coverage maintained
- [ ] Documentation updated (this plan and tracker)
- [ ] Run `bin/rubocop` and verify offense count < 10

---

## Progress Tracking Reference

See [tracker.md](./tracker.md) for detailed status of each item.

---

## Related Documentation

- [AGENTS.md](../../AGENTS.md) - Rails Code Quality skill for additional guidance
- [RuboCop Rails Documentation](https://docs.rubocop.org/rubocop-rails/)
- [RuboCop RSpec Documentation](https://docs.rubocop.org/rubocop-rspec/)
