# Test Coverage Implementation Plan

**Status:** In Progress
**Created:** 2025-01-18
**Goal:** Achieve comprehensive test coverage for Linkvan API codebase

## Overview

This plan addresses missing test coverage identified during codebase analysis. The implementation is organized by priority to ensure critical business logic and user-facing features are tested first.

## Priority Levels

- **CRITICAL** - Core business logic, permissions, data integrity
- **HIGH** - Controllers, workflows, user-facing features
- **MEDIUM** - Service objects, analytics, supporting features
- **LOW** - UI components, supporting models

---

## CRITICAL PRIORITY (Models - Core Business Logic)

### 1. User Model Tests
**File:** `spec/models/user_spec.rb`
**Priority:** Critical
**Estimated Time:** 2 hours

**Coverage Needed:**
- `manages` method - returns correct facilities based on admin level
  - Super admin returns all facilities
  - Zone admin returns facilities in their zones
  - Facility admin returns only their facilities
- `manageable_users` - user management permissions
  - Super admin can manage all users
  - Zone admin can manage users in their zone
- `can_manage?(user)` - permission checks
  - Super admins can manage all users
  - Zone admins can manage users in zone (except themselves)
  - Facility admins cannot manage users
- Admin level predicates: `super_admin?`, `zone_admin?`, `facility_admin?`
- `toggle_verified!` - state change
- Scopes: `verified`, `not_verified`, `super_admins`
- Validations: name presence, email format, uniqueness (case-insensitive)
- HABTM zones relationship

**Test Patterns:**
- FactoryBot factories with traits: `:admin`, `:verified`, `:not_verified`
- Context blocks for each admin level
- Expect change tests for state mutations

---

### 2. Facility Model (Expanded)
**File:** `spec/models/facility_spec.rb` (expand existing)
**Priority:** Critical
**Estimated Time:** 2.5 hours

**Coverage Needed:**
- `managed_by?(user)` - permission logic
  - Facility owner can manage
  - Zone admin of facility's zone can manage
  - Others cannot manage
- `status` method - returns live/pending_reviews/discarded
- `update_status(new_status)` - state transitions
- `website_url` - adds https:// if missing protocol
- `coordinates`, `coord`, `distance` calculations
  - Distance to another facility
  - Distance to coordinates
- `clean_data` callback - strips whitespace
  - name, phone, website, address: squish
  - notes: strip
- Scopes: `live`, `is_verified`, `pending_reviews`, `with_service`, `external`, `not_external`
- Validations: lat/long presence if verified?
- Discard enum: `none`, `closed`, `duplicated`

**Test Patterns:**
- Use existing factories: `:open_facility`, `:close_facility`
- Coordinate calculations with GeoLocation
- Discardable concern shared examples

---

### 3. Notice Model
**File:** `spec/models/notice_spec.rb`
**Priority:** Critical
**Estimated Time:** 1.5 hours

**Coverage Needed:**
- Rich text content validation via ActionText
- `NoAttachmentsValidator` - ensures no attachments present
- `set_slug` callback - slug generation from title
  - Handles special characters
  - Ensures uniqueness
- Enum: `notice_type` (general, covid19, warming_center, cooling_center, water_fountain)
- Scopes: `timeline`, `published`, `draft`
- Validations: title, content, slug presence
- `content_html` method

**Test Patterns:**
- FactoryBot with traits: `:published`, `:draft`
- Shoulda matchers for ActionText validations
- Custom matcher for NoAttachmentsValidator

---

### 4. Alert Model
**File:** `spec/models/alert_spec.rb`
**Priority:** Critical
**Estimated Time:** 1 hour

**Coverage Needed:**
- Rich text content validation via ActionText
- `NoAttachmentsValidator` - ensures no attachments
- `content_html` method
- Scopes: `timeline`, `active`, `inactive`
- Validations: title, content presence

**Test Patterns:**
- FactoryBot factory needed
- ActionText validation tests
- Time-based scope tests

---

### 5. Zone Model
**File:** `spec/models/zone_spec.rb`
**Priority:** Critical
**Estimated Time:** 1 hour

**Coverage Needed:**
- Validations:
  - name presence
  - name uniqueness (max 50 characters)
  - description presence
- HABTM relationships:
  - has_many :users
  - has_many :facilities (dependent: :nullify)
- Cascade behavior when zone deleted

**Test Patterns:**
- FactoryBot factory needed
- Shoulda matchers for HABTM
- Nullify dependency testing

---

### 6. Facility Schedule Model
**File:** `spec/models/facility_schedule_spec.rb`
**Priority:** Critical
**Estimated Time:** 1.5 hours

**Coverage Needed:**
- Enum: `week_day` (saturday through sunday)
- Custom validator: `time_slots_presence`
  - Cannot have time slots if open_all_day = true
  - Cannot have time slots if closed_all_day = true
- Default values: closed_all_day: true, open_all_day: false
- `availability` method returns: :open, :set_times, :closed
- `update_schedule_availability` - handles state changes
- Scopes: `open_all_day`, `closed_all_day`, `set_times`
- Validation: week_day uniqueness scope: :facility_id
- Relationship: has_many time_slots (dependent: destroy)

**Test Patterns:**
- FactoryBot factory with traits: `:with_time_slot`, `:with_2_time_slots`
- Custom validator tests
- Enum values for all 7 days

---

### 7. Facility Service Model
**File:** `spec/models/facility_service_spec.rb`
**Priority:** Critical
**Estimated Time:** 0.5 hours

**Coverage Needed:**
- Validations: facility presence, service presence
- Uniqueness: service scope: :facility
- Delegate: key, name to service model
- Scope: `name_search`
- Touch: facility on update
- Relationships: belongs_to :facility, belongs_to :service

**Test Patterns:**
- FactoryBot factory needed
- Shoulda matchers for associations
- Touch behavior testing

---

### 8. Facility Welcome Model
**File:** `spec/models/facility_welcome_spec.rb`
**Priority:** Critical
**Estimated Time:** 0.5 hours

**Coverage Needed:**
- Enum: `customer` (male, female, transgender, children, youth, adult, senior)
- Validations: customer presence, uniqueness scope: :facility
- `name` method - titleized customer value
- Class methods: `all_customers`, `names`
- Scope: `name_search`
- Touch: facility on update
- Relationship: belongs_to :facility

**Test Patterns:**
- FactoryBot factory needed
- Enum value iteration
- Class method tests

---

## HIGH PRIORITY (Controllers & Workflows)

### 9. Admin Facilities Controller
**File:** `spec/controllers/admin/facilities_controller_spec.rb`
**Priority:** High
**Estimated Time:** 3 hours

**Coverage Needed:**
- All CRUD actions: index, show, new, edit, create, update, destroy
- Filtering:
  - by status: live, pending_reviews, discarded
  - by service
  - by welcome_customer
  - by search query (name/address)
- `switch_status` action - toggles live/pending_reviews
- Authorization:
  - `load_facility` before_action
  - `load_facilities` with permissions
- Discard functionality with reasons (closed, duplicated)
- Pagination with Pagy
- Flash messages
- Turbo stream responses

**Test Patterns:**
- Sign in with Devise
- FactoryBot: `:open_all_day_facility`, `:close_facility`, `:with_services`
- Controller specs with shared admin authentication
- RSpec have_http_status, redirect_to, flash expectations
- Pagination testing

---

### 10. Admin Users Controller
**File:** `spec/controllers/admin/users_controller_spec.rb`
**Priority:** High
**Estimated Time:** 2.5 hours

**Coverage Needed:**
- All CRUD actions: index, show, new, edit, create, update, destroy
- `admin` attribute only modifiable by super_admin
- Permission-based access control:
  - Super admin can manage all users
  - Zone admin can manage users in their zone
- Password reset via Admin::PasswordsController
- Pagination with Pagy
- Flash messages

**Test Patterns:**
- Admin authentication shared context
- Permission matrix testing
- Admin attribute protection tests
- Password reset flow testing

---

### 11. Admin Notices Controller
**File:** `spec/controllers/admin/notices_controller_spec.rb`
**Priority:** High
**Estimated Time:** 2 hours

**Coverage Needed:**
- All CRUD actions: index, show, new, edit, create, update, destroy
- Rich text content handling (ActionText)
- Draft/published state management
- Pagination with Pagy
- Flash messages
- Slug generation on create/update

**Test Patterns:**
- ActionText parameter testing
- State management tests
- Shoulda matchers for routes

---

### 12. Admin Alerts Controller
**File:** `spec/controllers/admin/alerts_controller_spec.rb`
**Priority:** High
**Estimated Time:** 2 hours

**Coverage Needed:**
- All CRUD actions: index, show, new, edit, create, update, destroy
- Rich text content handling (ActionText)
- Active/inactive state management (via boolean?)
- Pagination with Pagy
- Flash messages

**Test Patterns:**
- ActionText parameter testing
- State management tests
- Shoulda matchers for routes

---

### 13. Admin Nested Facilities Controllers
**File:** `spec/controllers/admin/facilities_nested_controllers_spec.rb`
**Priority:** High
**Estimated Time:** 3 hours

**Coverage Needed:**

**FacilitySchedulesController:**
- new, edit, create, update
- Schedule creation with time slots
- Schedule availability updates

**FacilityServicesController:**
- create (associate service with facility)
- update (update service association)
- destroy (remove service from facility)

**FacilityWelcomesController:**
- create (add welcome type)
- destroy (remove welcome type)

**FacilityTimeSlotsController:**
- new, create, destroy
- Time string conversion to hours/minutes
- Overlap validation

**FacilityLocationsController:**
- index - list potential locations
- new - search for locations
- create - update facility with selected location
- Search via Locations::Searcher
- Turbo stream responses

**Test Patterns:**
- Nested resource testing
- Association testing
- Search integration testing
- Time parameter conversion tests
- Turbo stream response testing

---

### 14. API Zones Controller
**File:** `spec/controllers/api/zones_controller_spec.rb`
**Priority:** High
**Estimated Time:** 1.5 hours

**Coverage Needed:**
- index - returns all zones with facilities and users
- list_admin(id) - lists zone admins
- add_admin(id) - adds user as zone admin
- remove_admin(id) - removes user as zone admin
- Authorization: require_admin before_action (except index)
- JSON response structure
- Error handling for unauthorized access

**Test Patterns:**
- API controller specs
- Admin authentication
- Association testing
- JSON response validation
- Shared API token examples

---

## MEDIUM PRIORITY (Service Objects & Analytics)

### 15. Translator Service
**File:** `spec/services/translator_spec.rb`
**Priority:** Medium
**Estimated Time:** 1 hour

**Coverage Needed:**
- Service dictionary lookups (SERVICES_DICTIONARY)
  - shelter → housing
  - hygiene → cleaning
- Welcome dictionary lookups (WELCOMES_DICTIONARY)
  - Currently mostly empty
- Class methods: `.services_dictionary`, `.welcomes_dictionary`, `.dictionary`
- Instance methods: validates search_value exists in dictionary
- Invalid search term handling

**Test Patterns:**
- Service object testing
- Dictionary key-value testing
- Error handling tests

---

### 16. Locations Searcher Service
**File:** `spec/services/locations/searcher_spec.rb`
**Priority:** Medium
**Estimated Time:** 1.5 hours

**Coverage Needed:**
- Geocoder.search() integration
- Lazy enumerator behavior
- Location object generation from geocoder results
- Empty result handling
- Error handling for invalid queries

**Test Patterns:**
- Geocoder mocking/stubbing
- Lazy enumeration testing
- Factory generation testing

---

### 17. Google Maps Services
**File:** `spec/services/locations/google_maps_services_spec.rb` (expand existing)
**Priority:** Medium
**Estimated Time:** 1.5 hours

**Coverage Needed:**

**StaticMapService:**
- URL generation with parameters (center, zoom, size, markers, key)
- API key configuration

**EmbedMapService:**
- Iframe generation with parameters (origin, destination, mode, key)
- API key configuration

**Test Patterns:**
- Service object testing
- URL parameter testing
- API key environment variable testing

---

### 18. Vancouver City Syncer Service
**File:** `spec/services/external/vancouver_city/syncer_spec.rb`
**Priority:** Medium
**Estimated Time:** 2 hours

**Coverage Needed:**
- Pagination handling (PAGE_SIZE = 50)
- Loop until fewer records returned
- FacilitySyncer delegation for each record
- Result data: facilities, total_count, api_key, errors
- Error handling across batches
- API client integration

**Test Patterns:**
- Service object testing
- Pagination testing
- Error accumulation testing
- Mock API responses

---

### 19. Analytics Visit Model
**File:** `spec/models/analytics/visit_spec.rb`
**Priority:** Medium
**Estimated Time:** 1 hour

**Coverage Needed:**
- Validations:
  - uuid presence
  - session_id presence
  - session_id uniqueness scope: :uuid
- `attempt_update_coordinates(visit_params)` - only updates if coordinates not set
- has_many :events (dependent: destroy)
- has_many :impressions (through: events)

**Test Patterns:**
- FactoryBot factory needed
- Coordinate update conditional logic
- Association testing

---

### 20. Analytics Event Model
**File:** `spec/models/analytics/event_spec.rb`
**Priority:** Medium
**Estimated Time:** 1 hour

**Coverage Needed:**
- Validations: controller_name, action_name, request_url presence
- belongs_to :visit
- has_many :impressions (dependent: destroy)
- has_many :facilities (through: impressions, source: :impressionable, source_type: "Facility")

**Test Patterns:**
- FactoryBot factory needed
- Polymorphic through association testing
- Validation testing

---

### 21. Analytics Impression Model
**File:** `spec/models/analytics/impression_spec.rb`
**Priority:** Medium
**Estimated Time:** 1 hour

**Coverage Needed:**
- Validations:
  - impressionable_id presence
  - impressionable_type presence
  - impressionable_id uniqueness scope: [:impressionable_type, :event_id]
- belongs_to :event
- belongs_to :impressionable (polymorphic)
- has_one :visit (through: event)
- Scope: `facilities`

**Test Patterns:**
- FactoryBot factory needed
- Polymorphic association testing
- Uniqueness scope testing
- Scope testing

---

## LOW PRIORITY (Supporting Models & Components)

### 22. Location Model (ActiveModel)
**File:** `spec/models/location_spec.rb`
**Priority:** Low
**Estimated Time:** 1 hour

**Coverage Needed:**
- ActiveModel validations
- `build(params)` class method
- `build_from(geocoder_location:, facility:)` class method
- `coordinates` method
- `distance_from(*coords)` method
- Attributes: address, lat, long, facility

**Test Patterns:**
- ActiveModel::Model testing
- FactoryBot factory
- Coordinate calculation tests

---

### 23. GeoLocation Model (Utility)
**File:** `spec/models/geo_location_spec.rb`
**Priority:** Low
**Estimated Time:** 1.5 hours

**Coverage Needed:**
- `.coord(lat, long)` - creates Coord struct
- `.distance(from_coord, to_coord)` - Haversine distance calculation
- `.find_by_address(address, params:)` - Geocoder wrapper
- `.search(*args)` - Geocoder search
- Distance accuracy testing
- Geocoder integration

**Test Patterns:**
- Utility class testing
- Haversine formula verification
- Geocoder mocking
- Coordinate edge cases

---

### 24. Message Model (Form Object)
**File:** `spec/models/message_spec.rb`
**Priority:** Low
**Estimated Time:** 0.5 hours

**Coverage Needed:**
- ActiveModel validations: name, phone, content presence
- Form object behavior

**Test Patterns:**
- ActiveModel::Model testing
- Shoulda matchers for validations

---

### 25. SiteStats Model
**File:** `spec/models/site_stats_spec.rb`
**Priority:** Low
**Estimated Time:** 0.5 hours

**Coverage Needed:**
- `.facilities` class method
- `.notices` class method
- `.compute_last_updated` class method
- last_updated attribute (datetime)
- ActiveModel::Attributes

**Test Patterns:**
- ActiveModel::Attributes testing
- Class method testing

---

### 26. Status Model
**File:** `spec/models/status_spec.rb`
**Priority:** Low
**Estimated Time:** 0.25 hours

**Coverage Needed:**
- Currently empty model - placeholder for future functionality

**Test Patterns:**
- Minimal spec if needed

---

## ViewComponents Tests

### 27. Facility Show Component
**File:** `spec/components/facilities/show_component_spec.rb`
**Priority:** Low
**Estimated Time:** 1 hour

### 28. Facility Status Component
**File:** `spec/components/facilities/status_component_spec.rb`
**Priority:** Low
**Estimated Time:** 0.75 hours

### 29. Facility Card Component
**File:** `spec/components/facilities/card_component_spec.rb`
**Priority:** Low
**Estimated Time:** 1 hour

### 30. Facility Discard Reason Component
**File:** `spec/components/facilities/discard_reason_component_spec.rb`
**Priority:** Low
**Estimated Time:** 0.75 hours

### 31. Locations Embed Map Component
**File:** `spec/components/locations/embed_map_component_spec.rb`
**Priority:** Low
**Estimated Time:** 1 hour

### 32. Shared Modal Card Component
**File:** `spec/components/shared/modal_card_component_spec.rb`
**Priority:** Low
**Estimated Time**: 1 hour

### 33. Shared Status Component
**File:** `spec/components/shared/status_component_spec.rb`
**Priority:** Low
**Estimated Time:** 0.75 hours

### 34. Users Table Component
**File:** `spec/components/users/table_component_spec.rb`
**Priority:** Low
**Estimated Time:** 1.25 hours

### 35. Users Show Component
**File:** `spec/components/users/show_component_spec.rb`
**Priority:** Low
**Estimated Time:** 1 hour

### 36. Notices Table Component
**File:** `spec/components/notices/table_component_spec.rb`
**Priority:** Low
**Estimated Time:** 1.25 hours

### 37. Notices Show Component
**File:** `spec/components/notices/show_component_spec.rb`
**Priority:** Low
**Estimated Time:** 1 hour

### 38. Alerts Table Component
**File:** `spec/components/alerts/table_component_spec.rb`
**Priority:** Low
**Estimated Time:** 1.25 hours

### 39. Alerts Show Component
**File:** `spec/components/alerts/show_component_spec.rb`
**Priority:** Low
**Estimated Time:** 1 hour

**Component Testing Patterns:**
- ViewComponent spec structure: `type: :component`
- FactoryBot for test data
- Rendered content testing with `have_text`, `have_css`
- Slot testing (if applicable)
- Variant testing (if applicable)
- Icon/location method testing

---

## System Tests

### 40. Admin System Tests
**File:** `spec/system/admin/`
**Priority:** Medium
**Estimated Time:** 6 hours

**Coverage Needed:**

**Facility Management Workflow:**
- Create facility with name, address, coordinates
- Add schedules with time slots
- Add services
- Add welcome types
- Edit facility details
- Update status (live/pending_reviews)
- Discard facility with reason

**User Management Workflow:**
- Create user
- Assign zone admin role
- Verify permission-based access
- Edit user details
- Password reset flow

**Content Management Workflow:**
- Create notice with rich text
- Set as draft/published
- Create alert
- Test display on home page

**Search & Filtering:**
- Filter facilities by status, service, welcome type
- Search by name/address
- Verify permission-based results

**Test Patterns:**
- Capybara with Puma driver
- Devise login helper
- FactoryBot for test data
- Page object pattern (if desired)
- JavaScript testing (if needed for Turbo)

---

## Implementation Guidelines

### Testing Patterns to Follow

**Model Specs:**
- Use RSpec with Shoulda Matchers
- FactoryBot for test data
- Context blocks for different states
- Use `be_valid`, `have_many`, `validate_presence_of`, etc.
- Test custom validators
- Test custom methods with expectations

**Controller Specs:**
- Use `before_action` with authentication
- Test authorization (unauthorized access returns 401/403)
- Test successful responses (200, 302, 201)
- Test flash messages
- Test redirect paths
- Use `assigns` for instance variables
- Test params filtering

**Service Specs:**
- Test `.call` method returns Result struct
- Test success/failure branches
- Validate Result object structure
- Mock external dependencies

**Component Specs:**
- Use `type: :component`
- Test rendered HTML structure
- Test with different input data
- Test slots and variants

**System Specs:**
- Use Capybara with Puma
- Full user journey testing
- Test JavaScript interactions (Turbo)
- Use meaningful selectors

### Shared Examples

**Existing Shared Examples:**
- `spec/support/shared_examples/discardable.rb` - Use for models including Discardable
- `spec/support/shared_examples/api_tokens.rb` - Use for API controllers

**Consider Creating:**
- `spec/support/shared_examples/authorized_admin.rb` - Admin authorization
- `spec/support/shared_examples/crud_actions.rb` - Standard CRUD testing
- `spec/support/shared_examples/filterable.rb` - Index filter testing

### FactoryBot Factories Needed

Create/update factories in `spec/factories/`:
- `user.rb` - Already exists, add zone association factory
- `facility.rb` - Already exists
- `facility_service.rb` - Already exists
- `facility_welcome.rb` - Already exists
- `services.rb` - Already exists
- `notices.rb` - Already exists
- **NEW:** `alerts.rb`
- **NEW:** `zones.rb` (with users, facilities associations)
- **NEW:** `facility_schedule.rb` - Already exists
- **NEW:** `facility_time_slot.rb` - Already exists
- **NEW:** `analytics/visit.rb`
- **NEW:** `analytics/event.rb`
- **NEW:** `analytics/impression.rb`

---

## Quality Checks

After each test suite implementation:

1. **Run Tests:** `bin/rspec` or specific test file
2. **Run Linting:** `bin/rubocop`
3. **Check Coverage:** (if SimpleCov configured)
4. **Verify Tests Pass:** All tests must be green before moving to next item

---

## Progress Tracking

Track progress in `docs/plans/tracker.md`

---

## Estimated Total Time

- CRITICAL: ~12 hours
- HIGH: ~15.5 hours
- MEDIUM: ~10.5 hours
- LOW: ~17.5 hours
- SYSTEM: ~6 hours

**Total: ~61.5 hours**

---

## Notes

- Prioritize CRITICAL and HIGH priority items first
- System tests provide highest value for catching integration issues
- Consider running tests in parallel for faster execution
- Update this plan as requirements change
