# Linkvan API

A Rails API serving facility information (services, schedules, welcomes, phone numbers) to the Linkvan frontend, with an admin interface for managing facilities.

## Language

### Facilities

**Facility**:
A place offering services to people in need (e.g. shelters, clinics, community centres).
_Avoid_: Location, place, site

**FacilityPhoneNumber**:
A phone number belonging to a **Facility**. Carries its own attributes: `description`, `country_code`, `number`, `extension`, `primary`.
_Avoid_: Phone, FacilityPhone

**Primary phone number**:
The single **FacilityPhoneNumber** of a **Facility** flagged with `primary: true`. The frontend identifies it via the `primary` attribute on the array element — there is no separate flat API field for it.

### Phone number fields

**country_code**:
Digits-only string identifying the phone number's country code (e.g. `"1"`). Required, defaults to `"1"` (Canada).

**number**:
Digits-only string holding the local phone number (e.g. `"6044371940"`). Required. Display formatting (dashes, spaces) is a view concern and never stored.

**extension**:
Digits-only string for an optional phone extension (e.g. `"1234"`). May be blank. Stored as a string to preserve leading zeros.

**description**:
Optional free-text label for the phone number (e.g. `"Main"`, `"After hours"`, `"TDD/TTY"`). Not a controlled vocabulary.

**primary**:
Boolean indicating whether this **FacilityPhoneNumber** is the single primary number for its **Facility**. Enforced unique per facility at both the validation layer and via a partial unique DB index.

## Relationships

- A **Facility** has many **FacilityPhoneNumber**s (`dependent: :destroy`)
- A **Facility** has at most one **Primary phone number**
- A **FacilityPhoneNumber** belongs to exactly one **Facility**
- The legacy `Facility#phone` string column is kept temporarily alongside **FacilityPhoneNumber** rows; it is not migrated or backfilled
- **FacilityPhoneNumber** is not `Discardable`; soft-discarding a **Facility** leaves its phone number rows intact

## Validations

- **`facility`**: required.
- **`country_code`**: required, digits only, length 1–3.
- **`number`**: required, digits only, length 7–15, unique per `facility_id`.
- **`extension`**: digits only, optional, length ≤ 20.
- **`description`**: optional, length ≤ 100.
- **`primary`**: inclusion in `[true, false]`; at most one row with `primary: true` per facility (validation + partial unique index).

## Indices and uniqueness

- **`(facility_id, number)`** is uniquely indexed — a facility cannot have two **FacilityPhoneNumber** rows with the same digits.
- **`facility_id` WHERE `primary = true`** is uniquely indexed (partial) — at most one **Primary phone number** per facility.

## Sync behaviour (Vancouver City)

- The Vancouver City syncer always writes the raw upstream phone string to `Facility#phone` (legacy).
- It additionally attempts to build a **FacilityPhoneNumber** from the parsed (digits-only) mapper output, marked `primary: true`.
- If that **FacilityPhoneNumber** fails validation, it is silently dropped — `Facility#phone` is still saved. The dropped-state is useful for surfacing parsing blindspots.
- On re-sync, **FacilityPhoneNumber**s are find-or-create by `(facility_id, number)`. Existing rows are never clobbered.
- A synced number is marked `primary: true` only if the facility has no existing primary. If a primary exists (e.g. set by an admin), the synced row is created with `primary: false`.

## Example dialogue

> **Dev:** "When the admin saves a facility's phone numbers, how is the primary one chosen?"
> **Domain expert:** "The admin explicitly marks one as primary. The `mark_primary!` command demotes the existing primary and promotes the new one in a single transaction. If none is marked primary, none is."
>
> **Dev:** "And the API still returns the old flat `phone` string?"
> **Domain expert:** "Yes, for now — `phone_numbers` is the new array, `phone` stays for backward compatibility until the frontend has migrated."

## Flagged ambiguities

- "phone" was historically used to mean both the legacy flat string column on **Facility** (`Facility#phone`) and, generically, any phone number. Resolved: the new model is **FacilityPhoneNumber**; `Facility#phone` refers specifically to the legacy column kept for backward compatibility.
- "primary phone" — canonical term is **Primary phone number**, i.e. the **FacilityPhoneNumber** row with `primary: true`. Not a separate API field.