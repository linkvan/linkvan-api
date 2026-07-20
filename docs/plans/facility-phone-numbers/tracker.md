# Facility Phone Numbers Tracker

## Plan Reference

[plan.md](plan.md)

---

## Created: 2026-07-19
## Last Updated: 2026-07-19

---

## Summary

| Priority | Total | Not Started | In Progress | Completed | Blocked |
|----------|-------|-------------|-------------|-----------|---------|
| CRITICAL | 6     | 6           | 0           | 0         | 0       |
| HIGH     | 11    | 11          | 0           | 0         | 0       |
| MEDIUM   | 4     | 4           | 0           | 0         | 0       |
| **TOTAL**| **21** | **21**      | **0**       | **0**     | **0**   |

---

## Stage 1: Schema & Model (CRITICAL)

### Item Tables

#### 1.1 - Create migration for `facility_phone_numbers`

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.1 | CRITICAL | ⬜ Not Started | `db/migrate/<timestamp>_create_facility_phone_numbers.rb` | Two unique indexes (composite + partial on `primary`) |

#### 1.2 - Run migration

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.2 | CRITICAL | ⬜ Not Started | `db/schema.rb` | `bin/rails db:migrate` |

#### 1.3 - Create `FacilityPhoneNumber` model

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.3 | CRITICAL | ⬜ Not Started | `app/models/facility_phone_number.rb` | Validations + `mark_primary!` per plan |

#### 1.4 - Wire `Facility` associations

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.4 | CRITICAL | ⬜ Not Started | `app/models/facility.rb` | `has_many ... dependent: :destroy, autosave: true`, `has_one :primary_phone_number`. Do NOT touch `clean_data`. |

#### 1.5 - Model spec

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.5 | CRITICAL | ⬜ Not Started | `spec/models/facility_phone_number_spec.rb` | Validations, unique-primary, `mark_primary!` transactional |

---

## Stage 2: Factory (CRITICAL)

### Item Tables

#### 2.1 - Create factory

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.1 | CRITICAL | ⬜ Not Started | `spec/factories/facility_phone_numbers.rb` | Default + `:primary` trait |

---

## Stage 3: API Serializer (HIGH)

### Item Tables

#### 3.1 - Update `FacilitySerializer`

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.1 | HIGH | ⬜ Not Started | `app/services/facility_serializer.rb` | Add `hashify_phone_numbers`; include in BOTH summary and complete; keep `phone` |

#### 3.2 - Update serializer spec

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.2 | HIGH | ⬜ Not Started | `spec/services/facility_serializer_spec.rb` | Empty-rows case, primary flag asserted |

---

## Stage 4: Admin Controller + Routes (HIGH)

### Item Tables

#### 4.1 - Add routes

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 4.1 | HIGH | ⬜ Not Started | `config/routes.rb` | Nested `resources :phone_numbers` + member `put :mark_primary` |

#### 4.2 - Create `Admin::FacilityPhoneNumbersController`

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 4.2 | HIGH | ⬜ Not Started | `app/controllers/admin/facility_phone_numbers_controller.rb` | Strong params exclude `primary`; `mark_primary` calls `mark_primary!` |

#### 4.3 - Controller spec

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 4.3 | HIGH | ⬜ Not Started | `spec/controllers/admin/facility_phone_numbers_controller_spec.rb` or `spec/requests/...` | Match existing sibling spec convention |

---

## Stage 5: Admin UI Views (MEDIUM)

### Item Tables

#### 5.1 - Phone numbers card component

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 5.1 | MEDIUM | ⬜ Not Started | `app/components/admin/facilities/phone_numbers_card_component/*` | Attributes shown separately; description on line 2; primary badge; "Set as primary" button |

#### 5.2 - Mount card on facility show page

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 5.2 | MEDIUM | ⬜ Not Started | Facility show host component | Mirror sibling cards; do NOT remove legacy `phone` row |

#### 5.3 - New/edit form partials

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 5.3 | MEDIUM | ⬜ Not Started | `app/views/admin/facility_phone_numbers/` | Fields: description, country_code (default `"1"` in UI), number, extension. NO `primary` checkbox |

#### 5.4 - ViewComponent spec

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 5.4 | MEDIUM | ⬜ Not Started | `spec/components/admin/facilities/phone_numbers_card_component_spec.rb` | `type: :component` |

---

## Stage 6: CSV Exporter (HIGH)

### Item Tables

#### 6.1 - Update `Facilities::CsvExporter`

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 6.1 | HIGH | ⬜ Not Started | `app/services/facilities/csv_exporter.rb` | Add `phone_numbers` column; inline formatting; legacy `phone` column untouched |

#### 6.2 - CSV exporter spec

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 6.2 | HIGH | ⬜ Not Started | `spec/services/facilities/csv_exporter_spec.rb` | No rows, single primary, mixed, international, primary suffix |

---

## Stage 7: Vancouver City Syncer (HIGH)

### Item Tables

#### 7.1 - Create `PhoneNumberParser` service

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 7.1 | HIGH | ⬜ Not Started | `app/services/phone_number_parser.rb` | Generic (not Vancouver-specific); returns `nil` on parse failure |

#### 7.2 - Update `External::VancouverCity::FacilityBuilder`

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 7.2 | HIGH | ⬜ Not Started | `app/services/external/vancouver_city/facility_builder.rb` | Dual-write; find-or-create; `primary: true` only when no existing primary; swallow validation failures |

#### 7.3 - Parser spec

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 7.3 | HIGH | ⬜ Not Started | `spec/services/phone_number_parser_spec.rb` | Five cases from Q11b |

#### 7.4 - Syncer spec additions (six scenarios)

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 7.4 | HIGH | ⬜ Not Started | `spec/services/external/vancouver_city/facility_builder_spec.rb` (and/or syncer spec) | Six scenarios from Q11 + Q11a |

---

## Dependencies

- Stage 1 (schema/model) must complete before Stage 2 (factory needs the model).
- Stage 1 must complete before Stage 3 (serializer references `facility_phone_numbers`).
- Stage 1 + Stage 4 (routes) must complete before Stage 5 (admin UI uses routes).
- Stage 1 must complete before Stage 7 (syncer builds `FacilityPhoneNumber`).
- Stages 3, 4, 5, 6, 7 may proceed in parallel after Stage 1.

### Blockers

None identified at this time. All decisions resolved during the grilling session; see `CONTEXT.md` and ADRs 0001–0006.

---

## Progress Tracking

```
Stage 1 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░  0/5 items (0%)
Stage 2 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░  0/1 items (0%)
Stage 3 (HIGH):      ░░░░░░░░░░░░░░░░░░░░  0/2 items (0%)
Stage 4 (HIGH):      ░░░░░░░░░░░░░░░░░░░░  0/3 items (0%)
Stage 5 (MEDIUM):    ░░░░░░░░░░░░░░░░░░░░  0/4 items (0%)
Stage 6 (HIGH):      ░░░░░░░░░░░░░░░░░░░░  0/2 items (0%)
Stage 7 (HIGH):      ░░░░░░░░░░░░░░░░░░░░  0/4 items (0%)

Overall:             ░░░░░░░░░░░░░░░░░░░░  0/21 items (0%)
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
| 2026-07-19 | Initial plan creation — hand-off document after grilling session. Resolves all design branches; no implementation performed. All decisions captured in `CONTEXT.md` and ADRs 0001–0006. | Assistant |

---

## Notes

- **No implementation was performed.** This plan is a hand-off document. The grilling session resolved every branch in the design tree; downstream work can proceed stage-by-stage.
- **Authoritative references**: any discrepancy between this tracker and `CONTEXT.md` / `docs/adr/0001`–`0006` should be resolved in favour of `CONTEXT.md` / the ADRs (the tracker is a summary).
- **Git policy**: per `AGENTS.md`, agents must NOT perform git operations (`git add`, `git commit`, etc.). Leave staging/committing to the user.
- **Run commands**: `bin/rspec` for tests, `bin/rails` for Rails commands. ViewComponent tests use `type: :component`.
- **Legacy `Facility#phone` retirement**: deferred with no fixed timeline. Product owner decides when to drop the column.