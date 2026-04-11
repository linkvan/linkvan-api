# Vancouver City Water Fountain Sync Enhancement

## Status: COMPLETED

## Created: 2026-03-21

## Goal

Enhance the Vancouver City API water fountain sync feature with two new capabilities:
1. **Full Sync**: Remove facilities not present in the API (soft-delete with `sync_removed` reason)
2. **Purge All**: Add ability to remove all water fountains via admin action
3. **Undelete Support**: Sync should undelete and update facilities that were previously soft-deleted but now appear in the API

## Current State

- `External::VancouverCity::Syncer` fetches facilities from Vancouver Open Data API
- `External::VancouverCity::FacilitySyncer` processes each record (create/update by external_id or name match)
- Facilities with `external_id` are tracked as "external" facilities
- No mechanism to remove facilities not present in the API
- Discarded (soft-deleted) facilities are not considered during sync

## Target State

- **Full Sync**: After fetching all records, any external facility for that API not in the response will be soft-deleted with `discard_reason: "sync_removed"` (enabled by default)
- **Undelete**: Discarded facilities matching API records will be undeleted and updated
- **Purge All**: New admin action to soft-delete all water fountains for a given API
- **Enhanced Result**: `Syncer.call` result includes `created_count`, `updated_count`, `deleted_count`

## Analysis Summary

### Key Changes Required

1. **FacilitySyncer** - Modify to use `Facility.with_discarded` queries and call `undiscard` before updates
2. **Syncer** - Add `full_sync:` parameter (default `true`), track synced IDs, discard missing facilities
3. **PurgeService** - New service to purge all facilities for an API
4. **Admin Tools Controller** - Add `purge_facilities` action (DELETE method)
5. **Routes** - Add DELETE route for purge action
6. **Views** - Add checkbox for full sync and "Purge All" button

### Discard Reason

`"sync_removed"` - Indicates facility was removed during API synchronization

### Dependencies

- Rails `discard` gem (already in use via `Discardable` module)
- `External::ApiHelper` for API key validation and mapping

### Breaking Changes

- None - Full sync is enabled by default, but can be disabled via `full_sync: false` for incremental sync

---

## Priority System

- **CRITICAL** - Must complete for success
- **HIGH** - Should complete for full functionality
- **MEDIUM** - Recommended for best UX
- **LOW** - Optional improvements

---

## Implementation Stages

### Stage 1: Full Sync with Deletion + Undelete Support

**Focus:** Modify FacilitySyncer and Syncer to support full sync with deletion and undelete

#### 1.1 Add Tests for Facility Undeletion
- **Priority:** CRITICAL
- **Type:** Test
- **Location:** `spec/services/external/vancouver_city/facility_syncer/undelete_facility_spec.rb`
- **Description:** Add tests for undeleting discarded facilities during sync
- **Tests:**
  - Discarded facility with matching `external_id` → undeleted and updated
  - Discarded facility with matching name (internal update) → undeleted and services added
  - Verify `undiscard` is called before update operations

#### 1.2 Update FacilitySyncer to Handle Discarded Facilities
- **Priority:** CRITICAL
- **Type:** Code Fix
- **Location:** `app/services/external/vancouver_city/facility_syncer.rb`
- **Description:** Modify queries to use `with_discarded` and add undiscard logic
- **Changes:**
  - Line 32: `Facility.find_by(external_id: ...)` → `Facility.with_discarded.find_by(external_id: ...)`
  - Line 36: Name-match query also use `with_discarded`
  - Add `facility.undiscard` before `update_external_facility` and `update_internal_facility`

#### 1.3 Add Tests for Full Sync Deletion
- **Priority:** CRITICAL
- **Type:** Test
- **Location:** `spec/services/external/vancouver_city/syncer_spec.rb`
- **Description:** Add tests for `full_sync` option
- **Tests:**
  - `full_sync: true` (default) → orphaned facilities discarded with `"sync_removed"`
  - `full_sync: false` → no deletion (facilities kept even if missing from API)
  - Result includes `created_count`, `updated_count`, `deleted_count`

#### 1.4 Implement Full Sync Deletion Logic
- **Priority:** CRITICAL
- **Type:** Code Fix
- **Location:** `app/services/external/vancouver_city/syncer.rb`
- **Description:** Add `full_sync` parameter and deletion logic
- **Changes:**
  - Add `full_sync:` boolean parameter (default `true`) to `initialize`
  - Track fetched `external_id`s during `call`
  - After processing all records, if `full_sync: true`: discard facilities not in response

#### 1.5 Enhance Result with Counts
- **Priority:** HIGH
- **Type:** Code Fix
- **Location:** `app/services/external/vancouver_city/syncer.rb`
- **Description:** Add operation counts to result data
- **Changes:** Result data includes:
  ```ruby
  {
    facilities: facilities,
    total_count: facilities.size,
    created_count: <int>,
    updated_count: <int>,
    deleted_count: <int>,
    api_key: api_key
  }
  ```

---

### Stage 2: Purge All Water Fountains

**Focus:** Add ability to remove all water fountains for an API

#### 2.1 Add Tests for Purge Service
- **Priority:** CRITICAL
- **Type:** Test
- **Location:** `spec/services/external/vancouver_city/purge_service_spec.rb`
- **Description:** Add tests for purge service
- **Tests:**
  - Purges all external facilities for `api_key`
  - Discards with `discard_reason: "sync_removed"`
  - Returns `discarded_count`
  - Validates `api_key` is supported

#### 2.2 Implement Purge Service
- **Priority:** CRITICAL
- **Type:** Code Fix
- **Location:** `app/services/external/vancouver_city/purge_service.rb`
- **Description:** Create new service to purge all facilities for an API
- **Implementation:** Find all external facilities for the service, discard each with `sync_removed` reason

#### 2.3 Add Tests for Purge Controller Action
- **Priority:** CRITICAL
- **Type:** Test
- **Location:** `spec/controllers/admin/tools_controller_spec.rb`
- **Description:** Add tests for purge action
- **Tests:**
  - `DELETE /admin/tools/purge_facilities?api=drinking-fountains`
  - Admin only; non-admins redirect with access denied
  - Success redirects with notice showing count
  - Invalid `api_key` returns alert

#### 2.4 Implement Purge Action + Route
- **Priority:** CRITICAL
- **Type:** Code Fix
- **Location:** `app/controllers/admin/tools_controller.rb`, `config/routes.rb`
- **Description:** Add purge_facilities action and DELETE route
- **Changes:**
  - Add `purge_facilities` action (DELETE method)
  - Add route: `delete :purge_facilities, to: 'admin/tools#purge_facilities'`

---

### Stage 3: Update Admin Tools View

#### 3.1 Update Admin Tools View
- **Priority:** HIGH
- **Type:** Code Fix
- **Location:** `app/views/admin/tools/index.html.*`
- **Description:** Add UI for full sync and purge options
- **Changes:**
   - Remove checkbox (full sync is now the default behavior)
  - Add "Purge All" button with confirmation dialog → `DELETE /admin/tools/purge_facilities?api=drinking-fountains`

---

## Quality Checks

### Stage 1 Completion Criteria
- [ ] Undeletion tests pass (1.1)
- [ ] FacilitySyncer updated with undelete logic (1.2)
- [ ] Deletion tests pass (1.3)
- [ ] Full sync deletion logic implemented (1.4)
- [ ] Result enhanced with counts (1.5)
- [ ] Run `bin/rspec spec/services/external/vancouver_city/`

### Stage 2 Completion Criteria
- [ ] Purge service tests pass (2.1)
- [ ] Purge service implemented (2.2)
- [ ] Purge controller tests pass (2.3)
- [ ] Purge action and route implemented (2.4)
- [ ] Run `bin/rspec spec/controllers/admin/tools_controller_spec.rb`

### Stage 3 Completion Criteria
- [ ] View updated with checkbox (3.1)
- [ ] Manual test: Verify UI elements work correctly

### Overall Completion Criteria
- [ ] All tests pass
- [ ] `bin/rubocop` passes
- [ ] Manual verification of full sync and purge features

---

## Rollback Plan

If issues occur:
1. Revert `app/services/external/vancouver_city/syncer.rb` - removes `full_sync` and deletion logic
2. Revert `app/services/external/vancouver_city/facility_syncer.rb` - removes `with_discarded` and undelete logic
3. Revert `app/controllers/admin/tools_controller.rb` - removes `purge_facilities` action
4. Revert `config/routes.rb` - removes purge route
5. Delete new files: `purge_service.rb`, `undelete_facility_spec.rb`

---

## Estimated Time

| Stage | Tasks | Time |
|-------|-------|------|
| 1 | 5 | 45 min |
| 2 | 4 | 30 min |
| 3 | 1 | 10 min |
| Total | 10 | ~85 min |

---

## Related Documentation

- [Vancouver City API Syncer](../../app/services/external/vancouver_city/syncer.rb)
- [Vancouver City FacilitySyncer](../../app/services/external/vancouver_city/facility_syncer.rb)
- [AGENTS.md](../../AGENTS.md)
- [Rails Migrations Skill](../../.opencode/skills/rails-migrations/SKILL.md)
- [RSpec Testing Skill](../../.opencode/skills/rspec-testing/SKILL.md)
