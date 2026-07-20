# Facility Phone Numbers Plan

## Status: PENDING

## Created: 2026-07-19

## Goal

Allow each `Facility` to have multiple phone numbers, stored in a dedicated `facility_phone_numbers` table and exposed through the admin UI, API JSON, and CSV exporter. The legacy `Facility#phone` string column is kept untouched during a transition period whose end date is to be decided by the product owner.

## Current State

- `Facility#phone` is a single string column (`db/schema.rb:87`)
- Phone is rendered in the admin show page (`app/components/facilities/show_component/details_card_component.html.erb:67`), the admin edit form (`app/views/admin/facilities/_form_card_details.html.erb`), the API serializer (`app/services/facility_serializer.rb`), the CSV exporter (`app/services/facilities/csv_exporter.rb:52`), and is set by the Vancouver City syncer (`app/services/external/vancouver_city/facility_builder.rb:92`, `facility_mapper.rb:65`)
- Sibling child models (`FacilityService`, `FacilityWelcome`, `FacilitySchedule`) live in `app/models/`, follow a prefixed-noun naming convention, and are NOT `Discardable`; they're hard-deleted via `dependent: :destroy` and left untouched when the parent is soft-discarded
- Sibling admin controllers (`Admin::FacilityServicesController`, etc.) are nested REST resources under `resources :facilities` in `config/routes.rb`, guarded only by `authenticate_user!` via `Admin::BaseController`
- No `CONTEXT.md` or `docs/adr/` existed prior to this plan; both have been created to capture the domain language and architectural decisions

## Target State

- New `FacilityPhoneNumber` model + `facility_phone_numbers` table
- API JSON includes a structured `phone_numbers` array (complete view AND summary view); `phone` field unchanged
- CSV exporter adds one `phone_numbers` column with merged, formatted entries; legacy `phone` column unchanged
- Admin UI gets a dedicated "Phone Numbers" card on the facility show page and a sub-page for CRUD; `primary` is set via a `mark_primary` button only
- Vancouver City syncer dual-writes (legacy `phone` + new `FacilityPhoneNumber`); on validation failure it drops the new row but keeps `Facility#phone`
- All decisions captured in `CONTEXT.md` and ADRs `0001`–`0006`

## Analysis Summary

### Domain Language & Decisions (authoritative)

- **`CONTEXT.md`** (repo root) — glossary, relationships, indices, validations, and sync behaviour for `FacilityPhoneNumber`. Implementation details (controller structure, routes, factory traits) deliberately NOT captured there.
- **`docs/adr/0001-keep-legacy-facility-phone-column.md`** — legacy `Facility#phone` column kept, no backfill.
- **`docs/adr/0002-facility-phone-number-naming.md`** — model named `FacilityPhoneNumber` (not `FacilityPhone`) to avoid clash with legacy `Facility#phone`.
- **`docs/adr/0003-primary-via-mark-primary-only.md`** — `primary` managed only via `mark_primary!`, never via the admin form.
- **`docs/adr/0004-vancouver-syncer-dual-write-and-drop-on-validation-failure.md`** — syncer dual-writes; drops `FacilityPhoneNumber` on validation failure while keeping `Facility#phone`.
- **`docs/adr/0005-sync-find-or-create-preserve-admin-edits.md`** — re-sync is find-or-create by `[facility_id, number]`; never clobers admin edits; never demotes an admin-chosen primary.
- **`docs/adr/0006-csv-merges-json-structured.md`** — CSV merges phone numbers into one human-readable string; API JSON returns structured raw digits.

### Schema Decisions

```
create_table "facility_phone_numbers" do |t|
  t.string   "description",                limit: 100
  t.string   "country_code",   null: false, limit: 3, default: "1"
  t.string   "number",         null: false, limit: 15
  t.string   "extension",       limit: 20
  t.boolean  "primary",         null: false, default: false
  t.references "facility",      null: false, foreign_key: true
  t.timestamps
end

# Uniqueness guards
add_index :facility_phone_numbers, [:facility_id, :number], unique: true
add_index :facility_phone_numbers, :facility_id, unique: true, where: "primary = true"
```

### Model Decisions

```ruby
class FacilityPhoneNumber < ApplicationRecord
  belongs_to :facility

  validates :facility,      presence: true
  validates :country_code, presence: true,
                           format: { with: /\A\d+\z/ },
                           length: { in: 1..3 }
  validates :number,       presence: true,
                           format: { with: /\A\d+\z/ },
                           length: { in: 7..15 },
                           uniqueness: { scope: :facility_id }
  validates :extension,    format: { with: /\A\d*\z/ },
                           length: { maximum: 20 },
                           allow_blank: true
  validates :description,  length: { maximum: 100 }
  validates :primary,      inclusion: { in: [true, false] }
  validate  :validate_single_primary, if: :primary?

  # Demotes existing primary on the facility, promotes self, in a transaction.
  def mark_primary!
    transaction do
      facility.facility_phone_numbers.where.not(id: id).update_all(primary: false)
      update!(primary: true)
    end
  end

  private

  def validate_single_primary
    siblings = facility.facility_phone_numbers.where.not(id: id)
    errors.add(:primary, "already exists for this facility") if siblings.exists?(primary: true)
  end
end
```

```ruby
# Facility (additions)
has_many :facility_phone_numbers, dependent: :destroy, autosave: true
has_one  :primary_phone_number,  -> { where(primary: true) }, class_name: "FacilityPhoneNumber"
```

### Controller / Routes Decisions

```ruby
# config/routes.rb (inside resources :facilities)
resources :phone_numbers, only: %i[new create edit update destroy], controller: :facility_phone_numbers do
  member { put :mark_primary }
end
```

```ruby
# app/controllers/admin/facility_phone_numbers_controller.rb
class Admin::FacilityPhoneNumbersController < Admin::BaseController
  before_action :load_facility
  before_action :set_phone_number, only: %i[edit update destroy mark_primary]

  # new, create, edit, update, destroy, mark_primary
  # strong params: description, country_code, number, extension
  # primary intentionally excluded (managed only via mark_primary)
end
```

### API Serializer Decisions

- `FacilitySerializer::NON_COMPLETE_ATTRIBUTES` keeps `phone` (legacy string, unchanged).
- Add `phone_numbers` array to BOTH summary (NON_COMPLETE) and complete views.
- Each entry: `{ country_code:, number:, extension:, description:, primary: }` (raw stored digits, no formatting).
- Do NOT add a `formatted` field; do NOT synthesize a flat primary string.

### CSV Exporter Decisions

- Keep existing `phone` column (legacy, unchanged).
- Add new `phone_numbers` column containing all rows joined by `"; "`.
- Each entry formatted inline: `"+CC NNN-NNN-NNNN"` (10-digit NA pattern) or `"+CC <digits>"` otherwise; append `" xEXT"` when extension present; prefix `"DESC — "` when description present; suffix `" (primary)"` on the primary row.
- No `PhoneFormatter` service — formatting is inline in the CSV exporter (admin show views render attributes separately, not merged).

### Syncer Decisions

- `External::VancouverCity::FacilityMapper#phone` continues to return the raw string.
- The syncer still writes `facility.phone = mapper.phone` (no formatting change).
- Additionally, the syncer uses a new **generic** parser service `app/services/phone_number_parser.rb` (NOT scoped under `External::VancouverCity`) to extract `{ country_code, number, extension }`:
  - Detects leading `"+CC"` / `"1 …"` country codes (defaults to `"1"` when absent)
  - Detects `" xNNN"` / `" ext. NNN"` / `" ext NNN"` extensions
  - Strips remaining non-digits → `number`
  - Returns `nil` when there are no digits at all, or when `number` length is implausible (< 7)
- The syncer attempt-creates a `FacilityPhoneNumber` from the parsed result; if construction or validation fails, it silently skips and keeps `Facility#phone` (surfaces parsing blindspots — see ADR-0004).
- On re-sync, find-or-create by `[facility_id, number]` (see ADR-0005). Existing rows are never clobbered. A newly synced row is created with `primary: true` ONLY if the facility has no existing primary; otherwise `primary: false`.

### Admin UI Decisions

- New `Admin::FacilityPhoneNumbersController` mirroring sibling controllers (`Admin::FacilityServicesController` etc.).
- New "Phone Numbers" card section on the facility show page (mirror `FacilityService`/`FacilityWelcome` pattern); each row shows attributes separately with `description` on a second line. The currently-primary row shows a "Primary" badge; non-primary rows show a "Set as primary" button (the `mark_primary` action).
- The legacy `phone` row in the existing details card is retained during transition (no removal yet — to be decided by the product owner).
- Phone numbers are NOT on the facility edit form (matches siblings).

### Testing Decisions

- Factory (`spec/factories/facility_phone_numbers.rb`) with a `:primary` trait.
- Vancouver City syncer spec covers six scenarios:
  1. New facility with valid upstream phone — `Facility#phone` set, `FacilityPhoneNumber` created with `primary: true`.
  2. New facility with blank upstream phone — neither is set/created.
  3. Re-sync of existing facility, same number — find, no duplicate, admin edits preserved.
  4. Re-sync where admin set a different primary — new row created with `primary: false`.
  5. Upstream phone with formatting variants — including `"+1 604-123-4567 x12"` (country code + extension), `"604 408 5164 ext. 5"` (extension via `ext.`). Verify `Facility#phone` is raw string and `FacilityPhoneNumber.number` is digits-only.
  6. Upstream phone that fails parsing (e.g. `"abc"`) — `Facility#phone` saved, no `FacilityPhoneNumber` created (parsing blindspot surfaced).

### Explicitly Out of Scope / Deferred

- **Backfilling `Facility#phone` into `FacilityPhoneNumber`** — rejected (data too messy — ADR-0001).
- **Removing the legacy `Facility#phone` column** — deferred, no fixed timeline (product owner decides).
- **Authorization strengthening** — sibling admin controllers do not enforce `managed_by?`; we will NOT introduce a divergence here.
- **Pagination / row cap per facility** — no cap (mirrors siblings).
- **Explicit display ordering** — no ordering; default DB row order.
- **`PhoneFormatter` shared service** — rejected; only CSV needs formatting, done inline.
- **Schema-level enum on `description`** — rejected; free-text for now.
- **Backporting stricter auth to siblings** — out of scope.

## Priority System

- **CRITICAL** - Must complete for the feature to function (schema, model, validations, association, basic controller, API serializer, CSV exporter, factory)
- **HIGH** - Should complete for full coverage (admin UI components, syncer dual-write + parser, all syncer spec scenarios)
- **MEDIUM** - Recommended for completeness (admin show card component, mark_primary button flow)
- **LOW** - Optional polish

## Manual Test Protocol

Because the Vancouver City syncer behaviour, the admin UI button flow, and CSV output formatting all carry an element of human judgement (does the formatted CSV read correctly? does "Set as primary" toggle correctly?), the following checkpoints require manual browser/CLI verification:

1. After Stage 4 (admin controller + UI): create/edit/destroy + `mark_primary` flow in the browser.
2. After Stage 5 (CSV + API): verify the CSV cell rendering and the JSON `phone_numbers` array shape with `curl` / Postman.
3. After Stage 6 (syncer): run a sync and inspect that both `Facility#phone` and `FacilityPhoneNumber` are written, and that a deliberately bad upstream phone drops the `FacilityPhoneNumber` but keeps the legacy string.

## Implementation Stages

### Stage 1: Schema & Model (CRITICAL)

**Focus:** Create the database table, model, validations, associations.

#### 1.1 Create migration for `facility_phone_numbers`
- **Priority:** CRITICAL
- **Type:** Configuration
- **Location:** `db/migrate/<timestamp>_create_facility_phone_numbers.rb`
- **Command:** `bin/rails g migration CreateFacilityPhoneNumbers`
- **Description:** Table with `description` (string, limit 100), `country_code` (string, null false, limit 3, default "1"), `number` (string, null false, limit 15), `extension` (string, limit 20), `primary` (boolean, null false, default false), `t.references :facility, null: false, foreign_key: true`, timestamps. Add unique index on `[:facility_id, :number]` and partial unique index on `:facility_id` where `primary = true`.

#### 1.2 Run migration
- **Priority:** CRITICAL
- **Type:** Verification
- **Command:** `bin/rails db:migrate`
- **Description:** Apply migration; inspect `db/schema.rb`.

#### 1.3 Create `FacilityPhoneNumber` model
- **Priority:** CRITICAL
- **Type:** Code Fix
- **Location:** `app/models/facility_phone_number.rb`
- **Description:** Validations and `mark_primary!` exactly as in the "Model Decisions" section above.

#### 1.4 Wire `Facility` associations
- **Priority:** CRITICAL
- **Type:** Code Fix
- **Location:** `app/models/facility.rb`
- **Description:** Add `has_many :facility_phone_numbers, dependent: :destroy, autosave: true` and `has_one :primary_phone_number`. Note: do NOT touch `clean_data` (legacy `phone` stays squished as today).

#### 1.5 Model spec
- **Priority:** CRITICAL
- **Type:** Verification
- **Location:** `spec/models/facility_phone_number_spec.rb`
- **Description:** Cover all validations, the unique-primary validation path, and `mark_primary!` (demotes siblings, promotes self, transactional). Also add a `facility_spec.rb` example asserting `has_many`/`has_one`.

---

### Stage 2: Factory (CRITICAL)

**Focus:** FactoryBot support for tests.

#### 2.1 Create factory
- **Priority:** CRITICAL
- **Type:** Code Fix
- **Location:** `spec/factories/facility_phone_numbers.rb`
- **Description:** Default traits per Q15; add `trait :primary { primary { true } }`.

---

### Stage 3: API Serializer (HIGH)

**Focus:** Expose `phone_numbers` in JSON output without touching `phone`.

#### 3.1 Update `FacilitySerializer`
- **Priority:** HIGH
- **Type:** Code Fix
- **Location:** `app/services/facility_serializer.rb`
- **Description:** Add a `hashify_phone_numbers` method returning the array of `{ country_code:, number:, extension:, description:, primary: }`. Include the resulting array in BOTH the complete and summary (NON_COMPLETE) data hashes. Keep `phone` field unchanged.

#### 3.2 Update serializer spec
- **Priority:** HIGH
- **Type:** Verification
- **Location:** `spec/services/facility_serializer_spec.rb`
- **Description:** Assert `phone` is still the legacy string, and `phone_numbers` is the structured array including the primary flag. Cover the empty-rows case (empty array).

---

### Stage 4: Admin Controller + Routes (HIGH)

**Focus:** REST controller mirroring sibling controllers.

#### 4.1 Add routes
- **Priority:** HIGH
- **Type:** Configuration
- **Location:** `config/routes.rb`
- **Description:** Add nested `resources :phone_numbers` per Q7 (only `new create edit update destroy` + member `put :mark_primary`).

#### 4.2 Create `Admin::FacilityPhoneNumbersController`
- **Priority:** HIGH
- **Type:** Code Fix
- **Location:** `app/controllers/admin/facility_phone_numbers_controller.rb`
- **Description:** Mirror `Admin::FacilityServicesController` structure. Strong params permit `description, country_code, number, extension` and **exclude `primary`** (managed only via `mark_primary`). The `mark_primary` action calls `@phone_number.mark_primary!` and redirects to `admin_facility_path(@facility)`.

#### 4.3 Controller spec
- **Priority:** HIGH
- **Type:** Verification
- **Location:** `spec/controllers/admin/facility_phone_numbers_controller_spec.rb` (or `spec/requests/admin/facility_phone_numbers_spec.rb` — match the existing convention used by siblings)
- **Description:** Cover each action, including the strong-params exclusion of `primary`, and the `mark_primary` happy path.

---

### Stage 5: Admin UI Views (MEDIUM)

**Focus:** Show-page card mirroring siblings; per-row partial with separate attribute display.

#### 5.1 Phone numbers card component
- **Priority:** MEDIUM
- **Type:** Code Fix
- **Location:** `app/components/admin/facilities/phone_numbers_card_component/*` (mirrors `Facilities::ShowComponent` structure)
- **Description:** Lists each phone number row with attributes shown separately (NOT a merged string), description on a second line, primary badge on the primary row, "Set as primary" button on non-primary rows. Buttons link to the routes from Stage 4. Confirm a sibling ViewComponent (e.g. `facility_services` card) for the exact structure to mirror.

#### 5.2 Mount the card on the facility show page
- **Priority:** MEDIUM
- **Type:** Code Fix
- **Location:** The existing facility show component that hosts sibling cards (`FacilityService`, `FacilityWelcome` cards).
- **Description:** Add `<%= render Facilities::PhoneNumbersCardComponent.new(facility: @facility) %>` (or equivalent) in the same place siblings are rendered. **Do NOT remove** the legacy `phone` row from the existing details card.

#### 5.3 New/edit form partials
- **Priority:** MEDIUM
- **Type:** Code Fix
- **Location:** `app/views/admin/facility_phone_numbers/` (mirrors `app/views/admin/facility_services/`)
- **Description:** Basic form with fields for `description, country_code, number, extension` (country_code defaults to `"1"` in the UI). NO `primary` checkbox.

#### 5.4 ViewComponent spec
- **Priority:** MEDIUM
- **Type:** Verification
- **Location:** `spec/components/admin/facilities/phone_numbers_card_component_spec.rb` (type: `:component`)
- **Description:** Assert attributes render separately, the primary row shows the badge, non-primary rows show the "Set as primary" link to `mark_primary_admin_facility_phone_number_path`.

---

### Stage 6: CSV Exporter (HIGH)

**Focus:** Add `phone_numbers` column with inline-merged formatted entries.

#### 6.1 Update `Facilities::CsvExporter`
- **Priority:** HIGH
- **Type:** Code Fix
- **Location:** `app/services/facilities/csv_exporter.rb`
- **Description:** Add a `phone_numbers` column after the existing `phone` column. Format each row inline:
  - Base: `"+#{country_code} #{number formatted as XXX-XXX-XXXX if 10 digits else raw}"`
  - With extension: append `" x#{extension}"`
  - With description: prefix `"#{description} — "`
  - With primary: suffix `" (primary)"`
  - Join rows with `"; "`
- Keep `phone` column as-is.

#### 6.2 CSV exporter spec
- **Priority:** HIGH
- **Type:** Verification
- **Location:** `spec/services/facilities/csv_exporter_spec.rb` (or equivalent)
- **Description:** Cover: no rows (blank cell), one primary row, mixed primary + non-primary with extension and description, international (>10-digit) `number`, long cell overflow.

---

### Stage 7: Vancouver City Syncer (HIGH)

**Focus:** Dual-write; parser; re-sync find-or-create.

#### 7.1 Create `PhoneNumberParser` service
- **Priority:** HIGH
- **Type:** Code Fix
- **Location:** `app/services/phone_number_parser.rb`
- **Description:** Generic PORO (or `ApplicationService` subclass for consistency). Returns `{ country_code:, number:, extension: }` or `nil` if parsing fails (no digits, or `number` length < 7). Detection rules per Q11b. Defaults `country_code` to `"1"` when no country prefix is found.

#### 7.2 Update `External::VancouverCity::FacilityBuilder`
- **Priority:** HIGH
- **Type:** Code Fix
- **Location:** `app/services/external/vancouver_city/facility_builder.rb`
- **Description:** Continue assigning `facility.phone = mapper.phone` (unchanged). Additionally, after assigning `facility_data_from_record`, attempt to build a `FacilityPhoneNumber`: parse `mapper.phone` via `PhoneNumberParser`; if parsing produces a result AND no existing row matches `[facility_id, number]`, build a new `FacilityPhoneNumber` with `primary: facility.primary_phone_number.blank?`. Wrap in `begin/rescue` so any validation failure is silently swallowed (legacy `phone` is still saved).

#### 7.3 Parser spec
- **Priority:** HIGH
- **Type:** Verification
- **Location:** `spec/services/phone_number_parser_spec.rb`
- **Description:** Cover all cases from Q11b:
  - `"604-123-4567"` → `{"1", "6041234567", ""}`
  - `"+1 604-123-4567 x12"` → `{"1", "6041234567", "12"}`
  - `"604 408 5164 ext. 5"` → `{"1", "6044085164", "5"}`
  - `""`, `" "` → `nil`
  - `"abc"` → `nil`

#### 7.4 Syncer spec additions (six scenarios)
- **Priority:** HIGH
- **Type:** Verification
- **Location:** `spec/services/external/vancouver_city/facility_builder_spec.rb` and/or `spec/services/external/vancouver_city/facility_syncer/`
- **Description:** Cover the six scenarios listed in "Testing Decisions" above. Verify `Facility#phone` is always the raw upstream string; `FacilityPhoneNumber` is created/skipped per ADR-0004 and ADR-0005.

---

## Quality Checks

### Stage 1 Completion Criteria
- [ ] Migration applied; `db/schema.rb` contains the new table with both unique indexes
- [ ] `bin/rspec spec/models/facility_phone_number_spec.rb` passes
- [ ] `bin/rspec spec/models/facility_spec.rb` passes (no regressions)

### Stage 2 Completion Criteria
- [ ] Factory loads in the console: `FactoryBot.build(:facility_phone_number, :primary)`

### Stage 3 Completion Criteria
- [ ] `bin/rspec spec/services/facility_serializer_spec.rb` passes
- [ ] A request through the API returns `phone_numbers` array in both summary and complete views

### Stage 4 Completion Criteria
- [ ] `bin/rspec` for the new controller spec passes
- [ ] `bin/rails routes` shows the new nested routes including `mark_primary`

### Stage 5 Completion Criteria
- [ ] Facility show page renders the Phone Numbers card and the legacy `phone` row simultaneously
- [ ] Browser: create a phone number, edit it, destroy it, mark another as primary — verify the badge moves between rows

### Stage 6 Completion Criteria
- [ ] CSV export for a facility with mixed rows contains the merged `phone_numbers` cell AND the legacy `phone` column

### Stage 7 Completion Criteria
- [ ] `bin/rspec spec/services/phone_number_parser_spec.rb` passes
- [ ] `bin/rspec spec/services/external/vancouver_city/` passes (no regressions + new scenarios)
- [ ] Manual sync: confirm both `Facility#phone` and `FacilityPhoneNumber` are written for a clean record; `Facility#phone` alone is written for a deliberately-bad upstream phone

### Final Quality Gate
- [ ] `bin/rspec` (full suite) passes with 0 failures
- [ ] `bin/rubocop` (or the project's lint command — see AGENTS.md) reports 0 offenses on new/modified files
- [ ] Brakeman run reports no new warnings
- [ ] `CONTEXT.md` and `docs/adr/0001`–`0006` reviewed for accuracy against the implementation

## Rollback Plan

If issues occur:

1. **Revert migration**: `bin/rails db:rollback` (drops `facility_phone_numbers` table).
2. **Revert code**: `git revert` the offending commit(s); the legacy `Facility#phone` column is untouched, so removal of `FacilityPhoneNumber`-related code does not break existing functionality.
3. **Syncer rollback**: if syncer dual-write introduced a regression, revert the `FacilityBuilder` change — the syncer continues to write `Facility#phone` exactly as before (the new table is simply not populated).
4. **API rollback**: if `phone_numbers` field breaks a frontend consumer, remove it from the serializer — `phone` continues to be returned unchanged.

## Estimated Time

| Stage | Tasks | Time |
|-------|-------|------|
| 1 — Schema & Model | 5 | ~45 min |
| 2 — Factory | 1 | ~5 min |
| 3 — API Serializer | 2 | ~25 min |
| 4 — Admin Controller + Routes | 3 | ~40 min |
| 5 — Admin UI Views | 4 | ~60 min |
| 6 — CSV Exporter | 2 | ~30 min |
| 7 — Syncer + Parser | 4 | ~75 min |
| **Total** | **21** | **~280 min (~4.5 h)** |

---

## Related Documentation

- [CONTEXT.md](../../CONTEXT.md) — domain language for `Facility`, `FacilityPhoneNumber`, "Primary phone number", relationships, indices, validations, and sync behaviour.
- [ADR-0001 — Keep legacy `Facility#phone` column](../../docs/adr/0001-keep-legacy-facility-phone-column.md)
- [ADR-0002 — Model named `FacilityPhoneNumber`](../../docs/adr/0002-facility-phone-number-naming.md)
- [ADR-0003 — `primary` set only via `mark_primary!`](../../docs/adr/0003-primary-via-mark-primary-only.md)
- [ADR-0004 — Syncer dual-writes and drops on validation failure](../../docs/adr/0004-vancouver-syncer-dual-write-and-drop-on-validation-failure.md)
- [ADR-0005 — Re-sync is find-or-create, preserves admin edits](../../docs/adr/0005-sync-find-or-create-preserve-admin-edits.md)
- [ADR-0006 — CSV merges, JSON structured](../../docs/adr/0006-csv-merges-json-structured.md)
- [AGENTS.md](../../AGENTS.md) — project conventions (no git operations by agents, `bin/rspec`, `bin/rails`, admin interface under `/admin/dashboard`, ViewComponent tests use `type: :component`).
- Sibling models for pattern reference: `app/models/facility_service.rb`, `app/models/facility_welcome.rb`, `app/models/facility_schedule.rb`.
- Sibling admin controllers for pattern reference: `app/controllers/admin/facility_services_controller.rb`, `app/controllers/admin/facility_welcomes_controller.rb`.
- Syncer entry point: `app/services/external/vancouver_city/facility_builder.rb`, `app/services/external/vancouver_city/facility_mapper.rb`.