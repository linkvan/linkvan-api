# Vancouver City Water Fountain Sync Enhancement Tracker

## Plan Reference

[plan.md](plan.md)

---

## Created: 2026-03-21
## Last Updated: 2026-04-11

---

## Summary

| Priority | Total | Not Started | In Progress | Completed | Blocked |
|----------|-------|-------------|-------------|-----------|---------|
| CRITICAL | 8     | 0           | 0           | 8         | 0       |
| HIGH     | 2     | 0           | 0           | 2         | 0       |
| **TOTAL**| **10**| **0**       | **0**       | **10**    | **0**   |

---

## Stage 1: Full Sync with Deletion + Undelete Support

### Item Tables

#### 1.1 - Add Tests for Facility Undeletion

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.1 | CRITICAL | ✅ Completed | spec/.../facility_syncer/undelete_facility_spec.rb | 12 tests - all passing |

#### 1.2 - Update FacilitySyncer to Handle Discarded Facilities

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.2 | CRITICAL | ✅ Completed | app/.../facility_syncer.rb | Uses with_discarded + undiscard |

#### 1.3 - Add Tests for Full Sync Deletion

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.3 | CRITICAL | ✅ Completed | spec/.../syncer_spec.rb | Tests for full_sync option |

#### 1.4 - Implement Full Sync Deletion Logic

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.4 | CRITICAL | ✅ Completed | app/.../syncer.rb | full_sync param + deletion |

#### 1.5 - Enhance Result with Counts

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.5 | HIGH | ✅ Completed | app/.../syncer.rb | created/updated/deleted counts |

---

## Stage 2: Discard All Water Fountains

### Item Tables

#### 2.1 - Add Tests for Discard Service

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.1 | CRITICAL | ✅ Completed | spec/.../discard_service_spec.rb | 7 tests - all passing |

#### 2.2 - Implement Discard Service

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.2 | CRITICAL | ✅ Completed | app/.../discard_service.rb | New service file |

#### 2.3 - Add Tests for Discard Controller Action

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.3 | CRITICAL | ✅ Completed | spec/controllers/admin/tools_controller_spec.rb | 11 tests - all passing |

#### 2.4 - Implement Discard Action + Route

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.4 | CRITICAL | ✅ Completed | app/.../tools_controller.rb, config/routes.rb | DELETE route added |

---

## Stage 3: Update Admin Tools View

### Item Tables

#### 3.1 - Update Admin Tools View

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.1 | HIGH | ✅ Completed | app/views/admin/tools/index.html.erb | Added discard button + note about full sync |

---

## Dependencies

- Stage 1 must complete before Stage 2
- Stage 1.2 must complete before 1.4 (FacilitySyncer changes needed for Syncer)

### Blockers

None identified at this time.

---

## Progress Tracking

```
Stage 1 (CRITICAL):  ████████████████████ 5/5 items (100%)
Stage 2 (CRITICAL):  ████████████████████ 4/4 items (100%)
Stage 3 (HIGH):       ████████████████████ 1/1 items (100%)
Overall:             ████████████████████ 10/10 items (100%)
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
| 2026-03-21 | Initial plan creation | Assistant |
| 2026-04-11 | Implementation completed | Assistant |

---

## Notes

- Discard reason for removed facilities: `sync_removed`
- `full_sync: true` (default) - soft-deletes missing facilities; use `full_sync: false` for incremental sync
- Discard action uses DELETE HTTP method
- Confirmation dialog required before discard
- Since discard is used, operation is soft-delete (non-destructive, reversible)
