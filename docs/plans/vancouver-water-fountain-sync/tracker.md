# Vancouver City Water Fountain Sync Enhancement Tracker

## Plan Reference

[plan.md](plan.md)

---

## Created: 2026-03-21
## Last Updated: 2026-03-21

---

## Summary

| Priority | Total | Not Started | In Progress | Completed | Blocked |
|----------|-------|-------------|-------------|-----------|---------|
| CRITICAL | 8     | 8           | 0           | 0         | 0       |
| HIGH     | 2     | 2           | 0           | 0         | 0       |
| **TOTAL**| **10**| **10**     | **0**       | **0**     | **0**   |

---

## Stage 1: Full Sync with Deletion + Undelete Support

### Item Tables

#### 1.1 - Add Tests for Facility Undeletion

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.1 | CRITICAL | ⬜ Not Started | spec/.../facility_syncer/undelete_facility_spec.rb | New test file |

#### 1.2 - Update FacilitySyncer to Handle Discarded Facilities

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.2 | CRITICAL | ⬜ Not Started | app/.../facility_syncer.rb | Use with_discarded, add undiscard |

#### 1.3 - Add Tests for Full Sync Deletion

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.3 | CRITICAL | ⬜ Not Started | spec/.../syncer_spec.rb | Tests for full_sync option (default true) |

#### 1.4 - Implement Full Sync Deletion Logic

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.4 | CRITICAL | ⬜ Not Started | app/.../syncer.rb | Add full_sync param (default true) + deletion |

#### 1.5 - Enhance Result with Counts

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 1.5 | HIGH | ⬜ Not Started | app/.../syncer.rb | Add created/updated/deleted counts |

---

## Stage 2: Purge All Water Fountains

### Item Tables

#### 2.1 - Add Tests for Purge Service

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.1 | CRITICAL | ⬜ Not Started | spec/.../purge_service_spec.rb | New test file |

#### 2.2 - Implement Purge Service

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.2 | CRITICAL | ⬜ Not Started | app/.../purge_service.rb | New service file |

#### 2.3 - Add Tests for Purge Controller Action

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.3 | CRITICAL | ⬜ Not Started | spec/controllers/admin/tools_controller_spec.rb | Add purge tests |

#### 2.4 - Implement Purge Action + Route

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 2.4 | CRITICAL | ⬜ Not Started | app/.../tools_controller.rb, config/routes.rb | Add action + route |

---

## Stage 3: Update Admin Tools View

### Item Tables

#### 3.1 - Update Admin Tools View

| ID | Priority | Status | File | Notes |
|----|----------|--------|------|-------|
| 3.1 | HIGH | ⬜ Not Started | app/views/admin/tools/index.html.* | Add "Purge All" button (full sync is default) |

---

## Dependencies

- Stage 1 must complete before Stage 2
- Stage 1.2 must complete before 1.4 (FacilitySyncer changes needed for Syncer)

### Blockers

None identified at this time.

---

## Progress Tracking

```
Stage 1 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░ 0/5 items (0%)
Stage 2 (CRITICAL):  ░░░░░░░░░░░░░░░░░░░░ 0/4 items (0%)
Stage 3 (HIGH):       ░░░░░░░░░░░░░░░░░░░░ 0/1 items (0%)
Overall:             ░░░░░░░░░░░░░░░░░░░░ 0/10 items (0%)
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

---

## Notes

- Discard reason for removed facilities: `sync_removed`
- `full_sync: true` (default) - soft-deletes missing facilities; use `full_sync: false` for incremental sync
- Purge action uses DELETE HTTP method
- Confirmation dialog required before purge
- Since discard is used, operation is soft-delete (non-destructive, reversible)
