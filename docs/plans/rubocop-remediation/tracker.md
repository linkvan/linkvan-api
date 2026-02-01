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
| CRITICAL | 2     | 2           | 0           | 0         | 0       |
| HIGH     | 2     | 2           | 0           | 0         | 0       |
| MEDIUM   | 6     | 6           | 0           | 0         | 0       |
| LOW      | 1     | 1           | 0           | 0         | 0       |
| **TOTAL**| **11**| **11**      | **0**       | **0**     | **0**   |

---

## Stage 1: CRITICAL Priority - Foundation

**Focus:** Configure foundation settings that impact the entire application.

### Item Tables

#### 1.1 - Configure Vancouver Timezone

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 1.1 | CRITICAL | ⬜ Not Started | N/A | config/application.rb | Prevents 8 future offenses |

#### 1.2 - Disable RSpec/MultipleExpectations

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 1.2 | CRITICAL | ⬜ Not Started | 443 | .rubocop.yml | Configuration change |

---

## Stage 2: HIGH Priority - Immediate Fixes

**Focus:** Fix specific code issues that impact correctness and maintainability.

### Item Tables

#### 2.1 - Fix Rails/TimeZone Offenses

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 2.1 | HIGH | ⬜ Not Started | 4 | app/models/facility_time_slot.rb | Lines 21, 25 |
| 2.1 | HIGH | ⬜ Not Started | 4 | app/controllers/admin/facility_time_slots_controller.rb | Lines 63-64 |

#### 2.2 - Fix Rails/RedundantPresenceValidationOnBelongsTo

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 2.2 | HIGH | ⬜ Not Started | 1 | app/models/facility_service.rb | Line 7, auto-correctable |

---

## Stage 3: MEDIUM Priority - Rails Model Fixes

**Focus:** Fix Rails-specific model and configuration issues.

### Item Tables

#### 3.1 - Exclude GeoLocation from Rails/DynamicFindBy

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 3.1 | MEDIUM | ⬜ Not Started | 1 | .rubocop.yml | False positive - custom method |

#### 3.2 - Add Dependent Option to Service Model

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 3.2 | MEDIUM | ⬜ Not Started | 1 | app/models/service.rb | Line 4, add dependent: :restrict_with_error |

#### 3.3 - Disable Rails/I18nLocaleTexts

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 3.3 | MEDIUM | ⬜ Not Started | 4 | .rubocop.yml | Admin-only strings, single-language app |

---

## Stage 4: MEDIUM Priority - RSpec Batch 1

**Focus:** Fix the largest batch of RSpec auto-correctable offenses.

### Item Tables

#### 4.1 - Run RSpec/ReceiveMessages Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 4.1 | MEDIUM | ⬜ Not Started | 159 | Multiple specs | 11 files affected |

---

## Stage 5: MEDIUM Priority - RSpec Batch 2

**Focus:** Fix the second largest batch of RSpec auto-correctable offenses.

### Item Tables

#### 5.1 - Run RSpec/DescribedClass Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 5.1 | MEDIUM | ⬜ Not Started | 80 | Multiple specs | 8 files affected |

---

## Stage 6: MEDIUM Priority - RSpec Batch 3

**Focus:** Fix medium-size RSpec auto-correctable offenses.

### Item Tables

#### 6.1 - Run RSpec/IncludeExamples Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 6.1 | MEDIUM | ⬜ Not Started | 20 | Multiple specs | 4 files affected |

#### 6.2 - Run RSpec/BeEq Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 6.2 | MEDIUM | ⬜ Not Started | 11 | Multiple specs | 2 files affected |

---

## Stage 7: MEDIUM Priority - RSpec Batch 4

**Focus:** Fix the smallest RSpec auto-correctable offenses.

### Item Tables

#### 7.1 - Run RSpec/VerifiedDoubleReference Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 7.1 | MEDIUM | ⬜ Not Started | 9 | Multiple specs | 2 files affected |

#### 7.2 - Run RSpec/SharedExamples Auto-Correction

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 7.2 | MEDIUM | ⬜ Not Started | 8 | Multiple specs | 6 files affected |

---

## Stage 8: LOW Priority - Verification

**Focus:** Verify and validate existing configuration.

### Item Tables

#### 8.1 - Verify Rails/SkipsModelValidations Configuration

| ID | Priority | Status | Offenses | File | Notes |
|----|----------|--------|----------|------|-------|
| 8.1 | LOW | ⬜ Not Started | 0 | .rubocop.yml | Already configured, verification only |

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

### Blockers

None identified at this time.

---

## Completion Metrics

### Overall Progress

```
Stage 1 (CRITICAL):  ████████████████████ 0/2 items completed (0%)
Stage 2 (HIGH):      ████████████████████ 0/2 items completed (0%)
Stage 3 (MEDIUM):    ████████████████████ 0/3 items completed (0%)
Stage 4 (MEDIUM):    ████████████████████ 0/1 items completed (0%)
Stage 5 (MEDIUM):    ████████████████████ 0/1 items completed (0%)
Stage 6 (MEDIUM):    ████████████████████ 0/2 items completed (0%)
Stage 7 (MEDIUM):    ████████████████████ 0/2 items completed (0%)
Stage 8 (LOW):       ████████████████████ 0/1 items completed (0%)
Overall:             ████████████████████ 0/11 items completed (0%)
```

### Offense Resolution Progress

```
Stage 1:   ████████████████████ 0/443 offenses resolved (0%)
Stage 2:   ████████████████████ 0/5 offenses resolved (0%)
Stage 3:   ████████████████████ 0/6 offenses resolved (0%)
Stage 4:   ████████████████████ 0/159 offenses resolved (0%)
Stage 5:   ████████████████████ 0/80 offenses resolved (0%)
Stage 6:   ████████████████████ 0/31 offenses resolved (0%)
Stage 7:   ████████████████████ 0/17 offenses resolved (0%)
Total:     ████████████████████ 0/661 offenses resolved (0%)
Reduction: ████████████████████ 0/1,651 offenses (0%)
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
| 7 | MEDIUM | 2 | 17 | 10 minutes |
| 8 | LOW | 1 | 0 | 10 minutes |
| **TOTAL** | - | **11** | **661** | **1.5 hours** |

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

---

## Notes

- All RSpec auto-corrections are safe to run automatically
- Verify tests pass after each batch of auto-corrections
- Timezone configuration is critical for user-facing time operations
- Rails/SkipsModelValidations is already properly configured for migrations
- Stages 4-7 can be run independently if needed for incremental progress
