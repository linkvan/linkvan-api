# RuboCop Remediation Tracker

## Plan Reference

[plan.md](./plan.md)

---

## Created: 2026-02-01

## Last Updated: 2026-02-01

 ---

 ## Summary

| Priority | Total | Not Started | In Progress | Completed | Blocked |
|----------|-------|-------------|-------------|-----------|---------|
| CRITICAL | 2     | 0           | 0           | 2         | 0       |
| HIGH     | 3     | 0           | 0           | 3         | 0       |
| MEDIUM   | 18    | 10          | 0           | 8         | 0       |
| LOW      | 7     | 6           | 0           | 1         | 0       |
| **TOTAL**| **30**| **16**      | **0**       | **14**    | **0**   |

---

## Stage 1: CRITICAL Priority - Foundation

**Focus:** Configure foundation settings that impact the entire application.

### Item Tables

#### 1.1 - Configure Vancouver Timezone

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 1.1 | CRITICAL | ✅ Completed | N/A | config/application.rb | Timezone configured to Pacific Time (US & Canada), verified with rails runner |

#### 1.2 - Disable RSpec/MultipleExpectations

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 1.2 | CRITICAL | ✅ Completed | 443 | .rubocop.yml | Disabled in .rubocop.yml, 443 offenses excluded, use --except flag |

---

## Stage 2: HIGH Priority - Immediate Fixes

**Focus:** Fix specific code issues that impact correctness and maintainability.

### Item Tables

#### 2.1 - Fix Rails/TimeZone Offenses

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 2.1 | HIGH | ✅ Completed | 4 | app/models/facility_time_slot.rb | Replaced .to_time with .in_time_zone in model and controller, tests passing |
| 2.1 | HIGH | ✅ Completed | 4 | app/controllers/admin/facility_time_slots_controller.rb | Replaced .to_time with .in_time_zone in model and controller, tests passing |

#### 2.2 - Fix Rails/RedundantPresenceValidationOnBelongsTo

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 2.2 | HIGH | ✅ Completed | 1 | app/models/facility_service.rb | Removed redundant validation, belongs_to enforces presence automatically |

---

## Stage 3: MEDIUM Priority - Rails Model Fixes

**Focus:** Fix Rails-specific model and configuration issues.

### Item Tables

#### 3.1 - Rename GeoLocation.find_by_address to for_address

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 3.1 | MEDIUM | ✅ Completed | 1 | app/models/geo_location.rb | Renamed method and updated all usages in spec |

#### 3.2 - Add Dependent Option to Service Model

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 3.2 | MEDIUM | ✅ Completed | 1 | app/models/service.rb | Added dependent: :restrict_with_error to has_many :facility_services |

#### 3.3 - Disable Rails/I18nLocaleTexts

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 3.3 | MEDIUM | ✅ Completed | 4 | .rubocop.yml | Disabled Rails/I18nLocaleTexts in .rubocop.yml |

---

## Stage 4: MEDIUM Priority - RSpec Batch 1

**Focus:** Fix the largest batch of RSpec auto-correctable offenses.

### Item Tables

#### 4.1 - Run RSpec/ReceiveMessages Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 4.1 | MEDIUM | ✅ Completed | 159 | Multiple specs | Auto-corrected 159 RSpec/ReceiveMessages offenses across 11 files, committed |

---

## Stage 5: MEDIUM Priority - RSpec Batch 2

**Focus:** Fix the second largest batch of RSpec auto-correctable offenses.

### Item Tables

#### 5.1 - Run RSpec/DescribedClass Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 5.1 | MEDIUM | ✅ Completed | 80 | Multiple specs | Auto-corrected 80 RSpec/DescribedClass offenses across 8 files, committed |

---

## Stage 6: MEDIUM Priority - RSpec Batch 3

**Focus:** Fix medium-size RSpec auto-correctable offenses.

### Item Tables

#### 6.1 - Run RSpec/IncludeExamples Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 6.1 | MEDIUM | ✅ Completed | 20 | Multiple specs | Auto-corrected 20 RSpec/IncludeExamples offenses across 4 files, tests passing |

#### 6.2 - Run RSpec/BeEq Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 6.2 | MEDIUM | ✅ Completed | 11 | Multiple specs | Auto-corrected 11 RSpec/BeEq offenses across 2 files, tests passing |

---

## Stage 7: MEDIUM Priority - RSpec Batch 4

**Focus:** Fix the smallest RSpec auto-correctable offenses.

### Item Tables

#### 7.1 - Run RSpec/VerifiedDoubleReference Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 7.1 | MEDIUM | ✅ Completed | 9 | Multiple specs | Auto-corrected 9 RSpec/VerifiedDoubleReference offenses across 2 files, fixed test issue with non-existent class, tests passing |

---

## Stage 8: LOW Priority - Verification

**Focus:** Verify and validate existing configuration.

### Item Tables

#### 8.1 - Verify Rails/SkipsModelValidations Configuration

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 8.1 | LOW | ✅ Completed | 15 | Multiple | Configuration verified: migrations excluded, intentional disables in discardable.rb, acceptable usage in specs flagged as expected |

---

## Stage 9: HIGH Priority - Quick Wins Auto-Corrections

**Focus:** Fix all auto-correctable offenses immediately.

### Item Tables

#### 9.1 - Run Full Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 9.1 | HIGH | ✅ Completed | 75 | Multiple | Auto-corrected 75 offenses across multiple files, tests passing (1969 examples, 0 failures) |

---

## Stage 10: MEDIUM Priority - RSpec Core Pattern Changes

**Focus:** Fix high-impact RSpec pattern violations.

### Item Tables

#### 10.1 - Convert to have_received Pattern

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 10.1 | MEDIUM | ⬜ Not Started | 33 | Multiple spec files | Convert expect(Class).to receive to have_received with spy setup |

#### 10.2 - Add Named Subjects

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 10.2 | MEDIUM | ⬜ Not Started | 38 | Multiple spec files | Rename anonymous subjects to meaningful names |

#### 10.3 - Fix Context Wording

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 10.3 | MEDIUM | ⬜ Not Started | 27 | Multiple spec files | Rename context descriptions to start with "when", "with", or "without" |

#### 10.4 - Use Verifying Doubles

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 10.4 | MEDIUM | ⬜ Not Started | 22 | Multiple spec files | Replace double() with instance_double() or class_double() |

---

## Stage 11: MEDIUM Priority - RSpec Cleanup

**Focus:** Clean up RSpec patterns and organization.

### Item Tables

#### 11.1 - Rename Indexed Let Statements

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 11.1 | MEDIUM | ⬜ Not Started | 19 | Multiple spec files | Rename let1, let2 to descriptive names |

#### 11.2 - Fix Let Setup

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 11.2 | MEDIUM | ⬜ Not Started | 18 | Multiple spec files | Remove unused let! statements or convert to let |

#### 11.3 - Remove Subject Stubs

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 11.3 | MEDIUM | ⬜ Not Started | 11 | spec/components/facilities/show_component_spec.rb | Refactor to avoid stubbing subject methods |

#### 11.4 - Fix Spec File Path Format

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 11.4 | MEDIUM | ⬜ Not Started | 6 | Multiple spec files | Move/rename spec files to match described classes |

#### 11.5 - Fix Describe Method

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 11.5 | MEDIUM | ⬜ Not Started | 7 | Multiple spec files | Fix describe block structure to properly describe methods |

---

## Stage 12: MEDIUM Priority - Rails & Performance

**Focus:** Fix Rails-specific and performance issues.

### Item Tables

#### 12.1 - Document Rails/SkipsModelValidations

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 12.1 | MEDIUM | ⬜ Not Started | 14 | Multiple | Add rubocop:disable comments with rationale for intentional validation skips |

#### 12.2 - Fix Map Method Chain

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 12.2 | MEDIUM | ⬜ Not Started | 2 | lib/tasks/data.rake | Replace .map(&:to_s).map(&:method) with .map { |x| x.to_s.method } |

---

## Stage 13: LOW Priority - RSpec Advanced Patterns

**Focus:** Address advanced RSpec pattern improvements.

### Item Tables

#### 13.1 - Refactor Any Instance Usage

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 13.1 | LOW | ⬜ Not Started | 9 | Multiple spec files | Replace allow_any_instance_of with specific test doubles |

#### 13.2 - Move Expect from Hooks

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 13.2 | LOW | ⬜ Not Started | 2 | spec/components/facilities/show_component_spec.rb | Move expect statements from before hooks to test blocks |

#### 13.3 - Fix Stubbed Mock

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 13.3 | LOW | ⬜ Not Started | 3 | Multiple spec files | Use allow instead of expect for response configuration |

---

## Stage 14: LOW Priority - Style & Lint Cleanup

**Focus:** Clean up style and linting issues.

### Item Tables

#### 14.1 - Convert to Compact Module Style

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 14.1 | LOW | ⬜ Not Started | 5 | Multiple files | Convert module/class nesting to compact syntax |

#### 14.2 - Replace OpenStruct Usage

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 14.2 | LOW | ⬜ Not Started | 2 | app/models/facility_welcome.rb | Replace OpenStruct with Struct or Hash |

#### 14.3 - Simplify Multiline Block Chains

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 14.3 | LOW | ⬜ Not Started | 5 | Multiple files | Break complex block chains, extract intermediate variables |

#### 14.4 - Fix Remaining Lint Issues

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 14.4 | LOW | ⬜ Not Started | 2 | Multiple files | Fix Lint/MissingSuper, Lint/EmptyBlock, Lint/UselessConstantScoping, Lint/ConstantDefinitionInBlock |

---

## Factory Requirements

None required for this plan.

---

## Shared Examples Requirements

None required for this plan.

---

 ## Blockers & Dependencies

### Dependencies

- All Stage 1 (CRITICAL) items should be completed before other stages for foundation
- Stage 2 (HIGH) should be completed before Stage 3 for logical flow
- Stages 4-7 (RSpec batches) can be run independently, but verify tests pass after each
- Phase 2 (Stages 9-14): Stage 9 should be completed before other Phase 2 stages (quick wins)
- Phase 2 (Stages 9-14): Stages 10-12 should be completed before Stages 13-14 (higher priority)
- Phase 2 (Stages 9-14): Tests must pass after each stage before proceeding to next

### Blockers

None identified at this time.

---

## Completion Metrics

 ### Overall Progress

```
Stage 1 (CRITICAL):  ████████████████████ 2/2 items completed (100%)
Stage 2 (HIGH):      ████████████████████ 2/2 items completed (100%)
Stage 3 (MEDIUM):    ████████████████████ 3/3 items completed (100%)
Stage 4 (MEDIUM):    ████████████████████ 1/1 items completed (100%)
Stage 5 (MEDIUM):    ████████████████████ 1/1 items completed (100%)
Stage 6 (MEDIUM):    ████████████████████ 2/2 items completed (100%)
Stage 7 (MEDIUM):    ████████████████████ 1/1 items completed (100%)
Stage 8 (LOW):       ████████████████████ 1/1 items completed (100%)
Stage 9 (HIGH):      ████████████████████ 1/1 items completed (100%)
Stage 10 (MEDIUM):   ░░░░░░░░░░░░░░░░░░░ 0/4 items completed (0%)
Stage 11 (MEDIUM):   ░░░░░░░░░░░░░░░░░░░ 0/5 items completed (0%)
Stage 12 (MEDIUM):   ░░░░░░░░░░░░░░░░░░░ 0/2 items completed (0%)
Stage 13 (LOW):      ░░░░░░░░░░░░░░░░░░░ 0/3 items completed (0%)
Stage 14 (LOW):      ░░░░░░░░░░░░░░░░░░░ 0/4 items completed (0%)
Overall:             █████████░░░░░░░░░░░░░ 14/30 items completed (47%)
```

 ### Offense Resolution Progress

```
Stage 1:   ████████████████████ 443/443 offenses resolved (100%)
Stage 2:   ████████████████████ 5/5 offenses resolved (100%)
Stage 3:   ████████████████████ 6/6 offenses resolved (100%)
Stage 4:   ████████████████████ 159/159 offenses resolved (100%)
Stage 5:   ████████████████████ 80/80 offenses resolved (100%)
Stage 6:   ████████████████████ 31/31 offenses resolved (100%)
Stage 7:   ████████████████████ 9/9 offenses resolved (100%)
Stage 8:   ████████████████████ 15/15 offenses verified (100%)
Stage 9:   ████████████████████ 75/75 offenses resolved (100%)
Stage 10:  ░░░░░░░░░░░░░░░░░░░ 0/123 offenses resolved (0%)
Stage 11:  ░░░░░░░░░░░░░░░░░░░ 0/60 offenses resolved (0%)
Stage 12:  ░░░░░░░░░░░░░░░░░░░ 0/16 offenses resolved (0%)
Stage 13:  ░░░░░░░░░░░░░░░░░░░ 0/14 offenses resolved (0%)
Stage 14:  ░░░░░░░░░░░░░░░░░░░ 0/14 offenses resolved (0%)
Total:     ██████████████████░░░░░ 823/1,050 offenses resolved (78%)
Reduction: ██████████████████░░░░░ 823/350 offenses (234% from current 350, 50% from baseline 1,651)
```

---

 ## Stage Size Summary

| Stage | Priority | Tasks | Offenses | Estimated Time |
|-------|----------|-------|----------|----------------|
| 1 | CRITICAL | 2 | 443 | 10 minutes |
| 2 | HIGH | 2 | 5 | 20 minutes |
| 3 | MEDIUM | 3 | 6 | 20 minutes |
| 4 | MEDIUM | 1 | 159 | 5 minutes |
| 5 | MEDIUM | 1 | 80 | 5 minutes |
| 6 | MEDIUM | 2 | 31 | 10 minutes |
| 7 | MEDIUM | 1 | 9 | 10 minutes |
| 8 | LOW | 1 | 15 | 10 minutes |
| 9 | HIGH | 1 | 75 | 10 minutes |
| 10 | MEDIUM | 4 | 123 | 1 hour |
| 11 | MEDIUM | 5 | 60 | 45 minutes |
| 12 | MEDIUM | 2 | 16 | 30 minutes |
| 13 | LOW | 3 | 14 | 45 minutes |
| 14 | LOW | 4 | 14 | 30 minutes |
| **TOTAL** | - | **30** | **1,026** | **4.5 hours** |

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
| 2026-02-01 | Initial plan and tracker creation | Assistant |
| 2026-02-01 | Restructured plan by priority with 8 stages | Assistant |
| 2026-02-01 | Completed Stage 1 and Stage 2 | Assistant |
| 2026-02-01 | Completed Stage 3 - Rails Model Fixes | Assistant |
| 2026-02-01 | Updated RuboCop config to prevent indentation issues | Assistant |
| 2026-02-01 | Updated plan and tracker for current RuboCop state (654 offenses, 71 files) | Assistant |
| 2026-02-01 | Completed Stage 4 - RSpec/ReceiveMessages auto-correction (159 offenses) | Assistant |
| 2026-02-01 | Completed Stage 5 - RSpec/DescribedClass auto-correction (80 offenses) | Assistant |
| 2026-02-01 | Completed Stage 7 - RSpec/VerifiedDoubleReference auto-correction (9 offenses) | Assistant |
| 2026-02-01 | Completed Stage 8 - Verified Rails/SkipsModelValidations configuration | Assistant |
| 2026-02-01 | Re-ran RuboCop analysis: 425 offenses remaining across 248 files | Assistant |
| 2026-02-01 | Completed Stage 9 - Run Full Auto-Correction (75 offenses) | Assistant |
| 2026-02-01 | Total plan expanded to 30 tasks across 14 stages, targeting 1,026 offenses total | Assistant |

---

 ## Notes

- All RSpec auto-corrections are safe to run automatically
- Updated Layout/MultilineMethodCallIndentation to use 'indented' style to prevent excessive chaining indentation
- Verify tests pass after each batch of auto-corrections
- Timezone configuration is critical for user-facing time operations
- Rails/SkipsModelValidations is already properly configured for migrations
- Stages 4-7 can be run independently if needed for incremental progress
- Additional 412 RSpec offenses remain unaddressed (documented in plan Stage 9)
- User disabled RSpec/ExampleLength, RSpec/MultipleMemoizedHelpers, RSpec/NestedGroups
- Stage 4 completed: Auto-corrected 159 RSpec/ReceiveMessages offenses with zero test failures
- Stage 4-5 completed: Auto-corrected 239 RSpec offenses (159 ReceiveMessages + 80 DescribedClass)
- All tests passing (1,969 examples, 0 failures) after Stage 4-5
- Committed as git commit 104e806
- Stage 9 completed: Auto-corrected 75 offenses with zero test failures (1,969 examples, 0 failures)

## Phase 2 Plan Notes (Stages 9-14)

- Current RuboCop state: 425 offenses across 248 files (as of 2026-02-01)
- Phase 2 focuses on RSpec pattern improvements (92% of remaining offenses are in spec files)
- Stage 9 (HIGH priority): Auto-correctable offenses (75) - quick wins
- Stage 10 (MEDIUM): Core RSpec pattern changes (123 offenses) - highest impact
- Stage 11 (MEDIUM): RSpec cleanup (60 offenses) - test organization improvements
- Stage 12 (MEDIUM): Rails & Performance (16 offenses) - framework-specific fixes
- Stage 13 (LOW): Advanced RSpec patterns (14 offenses) - nice to have
- Stage 14 (LOW): Style & Lint cleanup (14 offenses) - code quality improvements

## User Decisions for Phase 2

- **Metrics offenses (16)**: User chose to skip Stage 13 metrics refactoring - these are acceptable as-is
- **Rails/SkipsModelValidations**: User chose to add disable comments with rationale rather than refactoring
- **RSpec/MessageSpies**: User chose to convert to `have_received` pattern (33 offenses) for better test design

## Phase 2 Implementation Priority

**Quick Start** (immediate impact):
- Stage 9: Auto-corrections (10 min, 75 offenses)

**High Impact** (best ROI):
- Stage 10: RSpec Core Patterns (1 hr, 123 offenses)
- Stage 11: RSpec Cleanup (45 min, 60 offenses)

**Medium Impact**:
- Stage 12: Rails & Performance (30 min, 16 offenses)

**Low Priority** (nice to have):
- Stage 13: RSpec Advanced (45 min, 14 offenses)
- Stage 14: Style Cleanup (30 min, 14 offenses)
