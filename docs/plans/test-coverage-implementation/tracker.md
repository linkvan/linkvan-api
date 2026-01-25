# Test Coverage Implementation Tracker

**Plan:** docs/plans/test-coverage-implementation/plan.md
**Created:** 2025-01-18
**Last Updated:** 2026-01-18

## Summary

| Priority | Total | In Progress | Completed | Blocked |
| ---------- | ------- | ------------- | ----------- | --------- |
| CRITICAL | 8 | 0 | 8 | 0 |
| HIGH | 6 | 0 | 6 | 0 |
| MEDIUM | 7 | 0 | 7 | 0 |
| LOW (Models) | 5 | 0 | 0 | 0 |
| LOW (Components) | 13 | 0 | 0 | 0 |
| SYSTEM | 1 | 0 | 0 | 0 |
| **TOTAL** | **43** | **0** | **24** | **0** |

---

## CRITICAL PRIORITY

| # | Item | Status | Notes |
| --- | ------ | -------- | ------- |
| 1 | User Model Tests | ✅ Completed | File: `spec/models/user_spec.rb` |
| 2 | Facility Model (Expanded) | ✅ Completed | File: `spec/models/facility_spec.rb` |
| 3 | Notice Model | ✅ Completed | File: `spec/models/notice_spec.rb` |
| 4 | Alert Model | ✅ Completed | File: `spec/models/alert_spec.rb` |
| 5 | Zone Model | ✅ Completed | File: `spec/models/zone_spec.rb` |
| 6 | Facility Schedule Model | ✅ Completed | File: `spec/models/facility_schedule_spec.rb` |
| 7 | Facility Service Model | ✅ Completed | File: `spec/models/facility_service_spec.rb` |
| 8 | Facility Welcome Model | ✅ Completed | File: `spec/models/facility_welcome_spec.rb` |

---

## HIGH PRIORITY

| # | Item | Status | Notes |
| --- | ------ | -------- | ------- |
| 9 | Admin Facilities Controller | ✅ Completed | File: `spec/controllers/admin/facilities_controller_spec.rb` |
| 10 | Admin Users Controller | ✅ Completed | File: `spec/controllers/admin/users_controller_spec.rb` |
| 11 | Admin Notices Controller | ✅ Completed | File: `spec/controllers/admin/notices_controller_spec.rb` |
| 12 | Admin Alerts Controller | ✅ Completed | File: `spec/controllers/admin/alerts_controller_spec.rb` |
| 13 | Admin Nested Facilities Controllers | ✅ Completed | File: `spec/controllers/admin/facilities_nested_controllers_spec.rb` |
| 14 | API Zones Controller | ✅ Completed | File: `spec/controllers/api/zones_controller_spec.rb` |

---

## MEDIUM PRIORITY

| # | Item | Status | Notes |
| --- | ------ | -------- | ------- |
| 15 | Translator Service | ✅ Completed | File: `spec/services/translator_spec.rb` (42 examples) |
| 16 | Locations Searcher Service | ✅ Completed | File: `spec/services/locations/searcher_spec.rb` (38 examples) |
| 17 | Google Maps Services | ✅ Completed | File: `spec/services/locations/google_maps_services_spec.rb` (55 examples) |
| 18 | Vancouver City Syncer Service | ✅ Completed | File: `spec/services/external/vancouver_city/syncer_spec.rb` (63 examples) |
| 19 | Analytics Visit Model | ✅ Completed | File: `spec/models/analytics/visit_spec.rb` (47 examples) + factory created |
| 20 | Analytics Event Model | ✅ Completed | File: `spec/models/analytics/event_spec.rb` (51 examples) |
| 21 | Analytics Impression Model | ✅ Completed | File: `spec/models/analytics/impression_spec.rb` (72 examples) |

---

## LOW PRIORITY - Models

| # | Item | Status | Notes |
| --- | ------ | -------- | ------- |
| 22 | Location Model (ActiveModel) | ⬜ Not Started | File: `spec/models/location_spec.rb` |
| 23 | GeoLocation Model (Utility) | ⬜ Not Started | File: `spec/models/geo_location_spec.rb` |
| 24 | Message Model (Form Object) | ⬜ Not Started | File: `spec/models/message_spec.rb` |
| 25 | SiteStats Model | ⬜ Not Started | File: `spec/models/site_stats_spec.rb` |
| 26 | Status Model | ⬜ Not Started | File: `spec/models/status_spec.rb` |

---

## LOW PRIORITY - ViewComponents

| # | Item | Status | Notes |
| --- | ------ | -------- | ------- |
| 27 | Facility Show Component | ⬜ Not Started | File: `spec/components/facilities/show_component_spec.rb` |
| 28 | Facility Status Component | ⬜ Not Started | File: `spec/components/facilities/status_component_spec.rb` |
| 29 | Facility Card Component | ⬜ Not Started | File: `spec/components/facilities/card_component_spec.rb` |
| 30 | Facility Discard Reason Component | ⬜ Not Started | File: `spec/components/facilities/discard_reason_component_spec.rb` |
| 31 | Locations Embed Map Component | ⬜ Not Started | File: `spec/components/locations/embed_map_component_spec.rb` |
| 32 | Shared Modal Card Component | ⬜ Not Started | File: `spec/components/shared/modal_card_component_spec.rb` |
| 33 | Shared Status Component | ⬜ Not Started | File: `spec/components/shared/status_component_spec.rb` |
| 34 | Users Table Component | ⬜ Not Started | File: `spec/components/users/table_component_spec.rb` |
| 35 | Users Show Component | ⬜ Not Started | File: `spec/components/users/show_component_spec.rb` |
| 36 | Notices Table Component | ⬜ Not Started | File: `spec/components/notices/table_component_spec.rb` |
| 37 | Notices Show Component | ⬜ Not Started | File: `spec/components/notices/show_component_spec.rb` |
| 38 | Alerts Table Component | ⬜ Not Started | File: `spec/components/alerts/table_component_spec.rb` |
| 39 | Alerts Show Component | ⬜ Not Started | File: `spec/components/alerts/show_component_spec.rb` |

---

## SYSTEM TESTS

| # | Item | Status | Notes |
| --- | ------ | -------- | ------- |
| 40 | Admin System Tests | ⬜ Not Started | Directory: `spec/system/admin/` |

---

## Additional Achievements (Beyond Original 40 Items)

| # | Achievement | Status | Notes |
| --- | ----------- | -------- | ------- |
| 41 | Bug Fixes in Facility Model | ✅ Completed | Fixed `this.user_id` → `user_id` and distance method parameter handling |
| 42 | SimpleCov Setup | ✅ Completed | Added SimpleCov to Gemfile and configured coverage reporting |
| 43 | Coverage Reporting | ✅ Completed | Achieved 64.3% overall code coverage with detailed HTML reports |

---

## Factory Requirements

Track creation of needed FactoryBot factories:

| Factory | Status | Notes |
| --------- | -------- | ------- |
| `alerts.rb` | ✅ Completed | For Alert model specs |
| `zones.rb` | ✅ Completed | For Zone model specs |
| `facility_schedule.rb` | ✅ Exists | Update if needed |
| `facility_time_slot.rb` | ✅ Exists | Update if needed |
| `analytics/visit.rb` | ✅ Completed | For Analytics::Visit specs |
| `analytics/event.rb` | ✅ Completed | For Analytics::Event specs |
| `analytics/impression.rb` | ✅ Completed | For Analytics::Impression specs |

---

## Shared Examples Requirements

Track creation of shared example groups:

| Shared Example | Status | Notes |
| ---------------- | -------- | ------- |
| `authorized_admin.rb` | ⬜ Not Started | Admin authorization patterns |
| `crud_actions.rb` | ⬜ Not Started | Standard CRUD testing patterns |
| `filterable.rb` | ⬜ Not Started | Index filter testing patterns |

---

## Blockers & Dependencies

| Item | Dependent On | Notes |
| ------ | ----------- | ------- |
| | | |

---

## Completion Metrics

### Progress by Priority

```plain
CRITICAL: ██████████ 8/8 (100%)
HIGH:     ██████████ 6/6 (100%)
MEDIUM:   ██████████ 7/7 (100%)
LOW:      ░░░░░░░░░░ 0/18 (0%)
SYSTEM:   ░░░░░░░░░░ 0/1 (0%)
```

### Overall Progress

```plain
TOTAL: █████████████████████████████████░░░░░ 24/43 (56%)
```

---

## Status Legend

- ⬜ Not Started
- 🟡 In Progress
- ✅ Completed
- 🚫 Blocked

---

## Change Log

| Date | Item # | Action | Notes |
| ------ | -------- | -------- | ------- |
| 2026-01-25 | 15-21 | Completed | Phase 1 (MEDIUM priority) completed - 7 service and analytics model tests with 368 examples |
| 2026-01-25 | All | Coverage | Improved coverage from 64.3% to 71.33% with Phase 1 completion |
| 2026-01-25 | Factories | Completed | Created analytics factories: `visit.rb`, `event.rb`, `impression.rb` |
| 2026-01-18 | 41 | Completed | Fixed critical bugs in Facility model (`this.user_id` → `user_id`, distance method parameter handling) |
| 2026-01-18 | 42 | Completed | Added SimpleCov to Gemfile and configured coverage reporting |
| 2026-01-18 | 43 | Completed | Achieved 64.3% overall code coverage with detailed HTML reports |
| 2025-01-18 | All High Priority | Completed | Implemented 6 controller test files (450+ examples) |
| 2025-01-18 | All Critical | Completed | Implemented 8 model test files with 132 passing examples |
| 2025-01-18 | All | Created tracker | Initial setup with 40 items |

---

## Notes

- Update this tracker after completing each item
- Mark blockers as they arise
- Track estimated vs actual time
- Run `bin/rspec` after each completion to verify
- Run `bin/rubocop` to ensure code quality
