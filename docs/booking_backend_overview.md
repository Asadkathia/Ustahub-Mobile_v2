# Booking Module Backend Redesign Notes

This document tracks the new backend implementation plan. Each section corresponds to a task in the approved plan and can be iteratively expanded while we work through the checklist.

---

## 1. Frontend → Backend Data Mapping

| Screen/Component | Primary File(s) | Data Needed | Notes |
| --- | --- | --- | --- |
| Provider booking tabs (Not Started/In Progress/Completed) | `lib/app/modules/provider_bookings/view/provider_booking_view.dart`, `controller/provider_bookings_controller.dart` | Booking card (id, booking_number, status, service name/icon, consumer name/avatar, scheduled date+time, address preview, status badge color) | API should return lightweight collection filtered by status & role. |
| Consumer booking tabs | `lib/app/modules/bookings/view/booking_view.dart`, `controller/booking_controller.dart` | Same fields as provider cards plus provider name/avatar | Support pagination for history tab. |
| Booking detail header (provider) | `provider_completed_booking_details/view/booking_details_view.dart`, `components/widgets.dart:ProviderBookingHeader` | Consumer name, formatted address, schedule window, Google Maps lat/lng, booking status | Address must be normalized string + coordinates. |
| Booking detail header (consumer) | `components/widgets.dart:ConsumerBookingHeader` | Provider name/avatar, rating, address, scheduled time | Provider favorite toggle also needs `is_favorite` boolean. |
| Work control buttons | `components/widgets.dart:WorkControlButtons` | Current status, `canStart`, `canComplete`, timestamps (started_at/completed_at), last action error | API must expose canonical status plus started/completed timestamps. |
| Directions & On My Way actions | `booking_details_view.dart` (`_handleDirections`, `_handleOnMyWay`) | `latitude`, `longitude`, `address_full`, fallback text, booking id | Backend should always return the snapshot of address with valid coordinates; `on_my_way` endpoint returns same payload for confirm message. |
| Notes tab | `app/modules/notes` (controllers/views) | Booking id, list of notes, ability to post note/photo | Booking detail endpoint should return `notes_summary` (count, last updated) so UI knows to fetch details lazily. |
| Notifications/toasts | `CustomToast`, GetX controllers | Human-readable messages from backend actions | All action endpoints must return `message` strings used directly. |

### Status & Workflow Requirements
- Distinct states: `pending`, `accepted`, `in_progress`, `completed`, `rejected`, `cancelled`.
- Transitions permitted: `pending -> accepted/rejected`, `accepted -> in_progress/cancelled`, `in_progress -> completed`.
- Backend must enforce transitions so UI errors are deterministic.

### Address Requirements
- Snapshot text fields (`address_full`, `city`, `state`, `postal_code`) plus `latitude` and `longitude`.
- If lat/lng missing, backend supplies at least formatted address text to keep Directions usable.

This mapping satisfies task **spec-ui-mapping**.

---

## 2. API Contract & Payload Schemas

All endpoints are exposed via Supabase Edge Functions (HTTP JSON). Every response uses:

```json
{
  "success": true,
  "message": "optional description",
  "data": { ... } // or array for list endpoints
}
```

Errors return `success:false`, `error_code`, and `message`.

### 2.1 List Bookings
- **Endpoint:** `GET /bookings`
- **Query Params:** `role=provider|consumer`, `status=pending|accepted|in_progress|completed|cancelled|history`, optional pagination `page`, `page_size`.
- **Response `data`:** array of booking cards

```json
{
  "id": "uuid",
  "booking_number": "UST-00123",
  "status": "in_progress",
  "service": { "id": "uuid", "name": "Tailoring", "image": "https://..." },
  "counterparty": { "id": "uuid", "name": "John Doe", "avatar": "https://..." },
  "scheduled": { "date": "2025-11-25", "time": "18:00:00" },
  "address_preview": "123 Main St, NYC",
  "badge_color": "#F9A826",
  "last_updated": "2025-11-24T10:32:00Z"
}
```

### 2.2 Booking Detail
- **Endpoint:** `GET /bookings/:id`
- **Response `data`:**

```json
{
  "booking": {
    "id": "uuid",
    "booking_number": "UST-00123",
    "status": "in_progress",
    "note": "Ring bell",
    "visiting_charge": 25,
    "started_at": "2025-11-25T18:05:00Z",
    "completed_at": null
  },
  "consumer": { "id": "uuid", "name": "John Doe", "avatar": "https://...", "phone": "+1..." },
  "provider": { "id": "uuid", "name": "Jane Smith", "avatar": "https://...", "phone": "+1..." },
  "service": { "id": "uuid", "name": "Tailoring", "plan": { "id": "uuid", "name": "Premium", "price": 110 } },
  "address": {
    "id": "uuid",
    "full": "123 Main St, NYC",
    "city": "New York",
    "state": "NY",
    "postal_code": "10001",
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "notes_summary": { "count": 3, "last_updated": "2025-11-24T19:00:00Z" },
  "permissions": { "can_start": true, "can_complete": false }
}
```

### 2.3 Create Booking
- **Endpoint:** `POST /bookings`
- **Body:**

```json
{
  "provider_id": "uuid",
  "service_id": "uuid",
  "plan_id": "uuid",
  "address_id": "uuid",
  "booking_date": "2025-11-25",
  "booking_time": "18:00",
  "note": "Bring ladder",
  "visiting_charge": 25
}
```

- **Response `data`:** `{ "id": "uuid", "booking_number": "UST-00123" }`

### 2.4 Action Endpoints
All use `POST /bookings/:id/<action>` with an optional JSON body and return `{ "success": true, "message": "...", "booking": { ...updated status fields... } }`.

| Action | Body | Validation |
| --- | --- | --- |
| `accept` | `{ "remark": "optional" }` | Current status must be `pending`. |
| `reject` | `{ "reason": "text" }` | Current status `pending`. |
| `start` | `{}` | Current status `accepted`. Sets `started_at`. |
| `complete` | `{ "remark": "optional" }` | Current status `in_progress`. Sets `completed_at`. |
| `cancel` | `{ "reason": "text" }` | Current status `pending` or `accepted`. |
| `on-my-way` | `{}` | Any status ≥ `accepted`. Returns `address` snapshot for navigation. |

Action responses always include the updated booking object so the UI can refresh in-place.

This satisfies task **api-schema**.

---

## 3. Database Snapshot Fields & RLS

### 3.1 Table Updates

`bookings` table gains persistent snapshot columns so the frontend never relies on joins:

| Column | Type | Source | Purpose |
| --- | --- | --- | --- |
| `booking_number` | text | sequence | Human-readable card ID |
| `consumer_name`, `consumer_avatar`, `consumer_phone` | text | `user_profiles` | Show on provider UI even if profile changes later |
| `provider_name`, `provider_avatar`, `provider_phone` | text | `user_profiles` | Consumer detail screen |
| `service_name`, `service_image` | text | `services` | Card & detail |
| `plan_name`, `plan_price` | text/numeric | `plans` | Price display |
| `address_full`, `address_city`, `address_state`, `address_postal`, `latitude`, `longitude` | text/numeric | `addresses` | Directions & labels |
| `scheduled_date`, `scheduled_time` | date/time | booking form | Control logic |
| `remark`, `visiting_charge`, `started_at`, `completed_at` | existing/new | workflow |

Foreign keys (`consumer_id`, `provider_id`, `address_id`, `service_id`, `plan_id`) remain for references.

### 3.2 Supporting Tables

- `booking_notes` (existing) continues; ensure `booking_id` FK with RLS allowing participants to read/write.
- Optional `booking_events` audit table to track transitions for troubleshooting.

### 3.3 RLS Policies

**Bookings:**
- Consumers: `authenticated.uid() = consumer_id` to `SELECT`, `INSERT`, `UPDATE` (limited to cancellation fields).
- Providers: `authenticated.uid() = provider_id` to `SELECT`. Updates only via Edge Function (using service role) to enforce workflow.
- Admin/service role: unrestricted.

**Addresses:**
- Allow base rule: `authenticated.uid() = user_id`.
- Additional policy: permit providers to `SELECT` rows whose `id` matches `bookings.address_id` for bookings where they are assigned. Implement via policy with `EXISTS (SELECT 1 FROM bookings b WHERE b.address_id = addresses.id AND b.provider_id = auth.uid())`.

**User Profiles:**
- Providers/consumers can `SELECT` profiles referenced by their bookings (similar `EXISTS` clause) to populate snapshot creation.

**Edge Function Execution:**
- Action functions run with service role key to bypass RLS when updating booking rows, but validation logic still enforces user ownership.

This covers task **db-policy**.

---

## 4. Edge Function Outline

All functions reside under `supabase/functions/booking-*` and share helper utilities for auth + response formatting.

### 4.1 `booking-list`
- **Input:** Query params `role`, `status`, `page`, `page_size`.
- **Logic:** 
  1. Validate `role` and ensure the authenticated user matches consumer/provider columns.
  2. Build a filtered `SELECT` from `bookings` returning only snapshot fields required for cards.
  3. Apply pagination and ordering by `scheduled_date`, `scheduled_time`.
  4. Return array plus pagination metadata.

### 4.2 `booking-detail`
- **Input:** Path `booking_id`.
- **Logic:**
  1. Fetch booking row; verify requester is consumer or provider.
  2. Join lightweight info from `booking_notes` (count, last updated) and optionally provider availability.
  3. Format permissions: `can_start`, `can_complete`, `can_cancel`.
  4. Return consolidated JSON described in Section 2.2.

### 4.3 `booking-actions`
- **Input:** Body `{ action, booking_id, remark?, reason? }`.
- **Logic:**
  1. Fetch booking row and check ownership.
  2. Switch on `action` to enforce state machine.
  3. Update row with new status/timestamps/remarks.
  4. Trigger side effects: notifications, push to provider calendars, logging table.
  5. Return updated booking snapshot.

### 4.4 `booking-create`
- Optional separate function to keep user-facing API minimal: validates availability, copies snapshot data, inserts booking row, and notifies provider.

### Shared Utilities
- `ensureRole(userId, bookingRow, role)` helper.
- `publishEvent(type, payload)` for analytics/audit.
- `formatBookingResponse(row)` centralizes JSON shape.

This satisfies task **edge-fns**.

---

## 5. Flutter Integration Plan

### 5.1 New Service Layer
- Create `lib/network/booking_api_service.dart` that wraps HTTP calls to the Edge Functions (`/functions/v1/booking-*`).
- Methods:
  - `Future<List<BookingCardModel>> fetchBookings({required String role, required String status, int page = 1})`
  - `Future<BookingDetailsModel> fetchBookingDetails(String id)`
  - `Future<void> bookingAction(String id, BookingAction action, {String? remark, String? reason})`
- Handle auth headers via existing Supabase session token.

### 5.2 Repository Updates
- Replace `SupabaseApiServices.getBookings` and `getBookingDetails` usage with the new service.
- Controllers (`ProviderBookingController`, `BookingController`, `BookingDetailsController`, `ProviderCompleteWorkController`, `StartWorkController`) now depend on `BookingRepository` that internally calls the Edge Functions (centralized).
- Remove fallback logic for missing address/status; rely on backend guarantees.

### 5.3 Model Adjustments
- Update `BookingModel`, `BookingDetailsModelClass`, and related data classes to match the new JSON schema (snapshot fields, permissions object).
- Provide `fromJson` factories mapping to new structures; keep compatibility shims for old fields until removal phase.

### 5.4 UI Wiring
- Booking list views already react to `status` and card fields; ensure the new models supply `displayStatus`, `addressPreview`, etc.
- `BookingDetailsView` uses `permissions.canStart` & `permissions.canComplete` rather than deriving from raw status.
- Directions/on-my-way now read `bookingDetails.address.full`, `latitude`, `longitude` guaranteed by backend.

### 5.5 Migration/Feature Flag
- Introduce config (e.g., `bool useNewBookingApi = true`) to allow staged rollout if needed.
- Once validated, remove old toggle and delete legacy service calls (covered in Section 6).

This addresses task **flutter-integration**.

---

## 6. Testing & Verification Matrix

### 6.1 Data Setup
- Seed at least one booking per status (`pending`, `accepted`, `in_progress`, `completed`) for both provider and consumer accounts.
- Include bookings with/without coordinates to test directions fallback.
- Create sample notes and attachments to validate `notes_summary`.

### 6.2 Manual Test Scenarios

| Scenario | Steps | Expected Result |
| --- | --- | --- |
| Provider sees Not Started list | Login as provider → Bookings tab (Not Started) | API returns accepted bookings only, address preview visible, tap card loads detail. |
| Start Work flow | Accept pending booking → open detail → tap Start Work | Backend transitions to `in_progress`, button disables, Mark Complete enabled, started timestamp shown. |
| Complete flow | Start Work booking → tap Mark Complete → confirm | Status becomes `completed`, buttons disabled, Completed tab entry present. |
| Directions button | Booking with lat/lng → tap Directions | Google Maps opens with coordinates; fallback uses address text if coordinates missing. |
| On My Way | Tap On My Way | Confirmation dialog shows formatted address; selecting Notify triggers endpoint and optional navigation. |
| Consumer history | Switch to consumer role → History tab | Pagination works, cards show provider info and status history. |
| Error handling | Force invalid action (Start Work on pending) | Backend returns validation message surfaced via toast. |

### 6.3 Automated Coverage
- Add unit tests for new repositories mocking HTTP responses (success + error).
- Integration tests for Edge Functions using Supabase test runner to ensure RLS allows intended access.

### 6.4 Monitoring
- Log each action in `booking_events` with `user_id`, `action`, `status_before`, `status_after`.
- Add Sentry/Crashlytics breadcrumbs when API calls fail for easier debugging.

This fulfills task **testing**.

---
