# Booking Module API Design

## Overview
This document outlines the simplified, frontend-compatible booking API design.

## Core Principles
1. **Simple, Direct Queries** - No complex joins
2. **Clear Error Messages** - Frontend knows exactly what went wrong
3. **Consistent Response Format** - Same structure for all responses
4. **Permission Checks** - Clear authorization logic
5. **Status Workflow** - Enforced state machine

## Booking Status Flow
```
pending → accepted → in_progress → completed
   ↓
rejected/cancelled
```

## API Endpoints (via Supabase)

### 1. GET `/bookings/:id` - Get Booking Details
**Purpose:** Fetch complete booking information

**Response:**
```json
{
  "status": true,
  "data": {
    "booking": {
      "id": "uuid",
      "booking_id": "BOOK-123",
      "status": "in_progress",
      "booking_date": "2025-11-25",
      "booking_time": "18:00:00",
      "note": "...",
      "created_at": "...",
      "updated_at": "..."
    },
    "consumer": {
      "id": "uuid",
      "name": "John Doe",
      "avatar": "url",
      "phone": "+123456"
    },
    "provider": {
      "id": "uuid",
      "name": "Jane Smith",
      "avatar": "url",
      "phone": "+789012"
    },
    "service": {
      "id": "uuid",
      "name": "Tailoring",
      "icon": "url"
    },
    "address": {
      "id": "uuid",
      "full_address": "123 Main St, City, Country",
      "latitude": "40.7128",
      "longitude": "-74.0060",
      "city": "New York",
      "country": "USA"
    },
    "payment": {
      "item_total": 100.00,
      "service_fee": 10.00,
      "total": 110.00
    }
  }
}
```

### 2. GET `/bookings` - List Bookings
**Purpose:** Get bookings filtered by status and role

**Query Parameters:**
- `status`: pending | accepted | in_progress | completed | cancelled
- `role`: consumer | provider

**Response:**
```json
{
  "status": true,
  "data": [
    {
      "id": "uuid",
      "booking_id": "BOOK-123",
      "status": "in_progress",
      "consumer_name": "John Doe",
      "provider_name": "Jane Smith",
      "service_name": "Tailoring",
      "address_preview": "123 Main St, City",
      "booking_date": "2025-11-25",
      "booking_time": "18:00:00"
    }
  ]
}
```

### 3. POST `/bookings` - Create Booking
**Purpose:** Consumer creates a new booking

**Request:**
```json
{
  "provider_id": "uuid",
  "service_id": "uuid",
  "plan_id": "uuid",
  "address_id": "uuid",
  "booking_date": "2025-11-25",
  "booking_time": "18:00:00",
  "note": "Special instructions",
  "visiting_charge": 50.00
}
```

**Response:**
```json
{
  "status": true,
  "message": "Booking created successfully",
  "data": {
    "booking_id": "BOOK-123",
    "id": "uuid"
  }
}
```

### 4. POST `/bookings/:id/accept` - Accept Booking
**Purpose:** Provider accepts a pending booking

**Response:**
```json
{
  "status": true,
  "message": "Booking accepted successfully"
}
```

### 5. POST `/bookings/:id/reject` - Reject Booking
**Purpose:** Provider rejects a pending booking

**Request:**
```json
{
  "reason": "Not available at this time"
}
```

### 6. POST `/bookings/:id/start` - Start Work
**Purpose:** Provider starts work on accepted booking

**Response:**
```json
{
  "status": true,
  "message": "Work started successfully"
}
```

### 7. POST `/bookings/:id/complete` - Complete Booking
**Purpose:** Provider marks booking as complete

**Request:**
```json
{
  "remark": "Work completed successfully"
}
```

### 8. POST `/bookings/:id/cancel` - Cancel Booking
**Purpose:** Consumer cancels booking

**Request:**
```json
{
  "reason": "Changed plans"
}
```

## Database Structure

### Tables Needed:
1. `bookings` - Core booking data
2. `user_profiles` - Consumer/Provider profiles
3. `addresses` - Location data
4. `services` - Service catalog
5. `plans` - Service plans/tiers

### Key Foreign Keys:
- `bookings.consumer_id` → `user_profiles.id`
- `bookings.provider_id` → `user_profiles.id`
- `bookings.service_id` → `services.id`
- `bookings.address_id` → `addresses.id`
- `bookings.plan_id` → `plans.id`

## RLS Policies Required

### `bookings` table:
- Consumers can read their own bookings
- Providers can read bookings assigned to them
- Providers can update status of their bookings
- Consumers can create bookings

### `addresses` table:
- **NEW:** Providers can read addresses for bookings assigned to them
- Users can read/write their own addresses

### `user_profiles` table:
- Users can read their own profile
- Public can read provider profiles (for booking)
- Consumers can read provider profiles (for their bookings)
- Providers can read consumer profiles (for their bookings)

## Error Handling

All errors return:
```json
{
  "status": false,
  "error": "Error type",
  "message": "Human-readable error message",
  "code": "ERROR_CODE"
}
```

### Error Codes:
- `BOOKING_NOT_FOUND` - Booking doesn't exist
- `UNAUTHORIZED` - User doesn't have permission
- `INVALID_STATUS` - Can't perform action in current status
- `MISSING_DATA` - Required data not provided
- `ADDRESS_NOT_FOUND` - Address doesn't exist or not accessible

## Implementation Strategy

### Phase 1: Direct Repository (Current)
- Use Supabase client directly from Flutter
- Simple queries without joins
- Fetch related data in separate calls
- ✅ Complete data, no RLS issues

### Phase 2: Edge Functions (Future)
- Create Supabase Edge Functions for complex operations
- Centralize business logic
- Better error handling and validation
- Single source of truth

## Frontend Integration

### Dart API Service Pattern:
```dart
class BookingApiService {
  // Get booking details
  Future<BookingDetails> getBooking(String id);
  
  // List bookings
  Future<List<Booking>> listBookings({String? status, bool forProvider});
  
  // Actions
  Future<void> acceptBooking(String id);
  Future<void> startWork(String id);
  Future<void> completeWork(String id, {String? remark});
}
```

### Controller Pattern:
```dart
class BookingDetailsController extends GetxController {
  final BookingApiService _api;
  
  // Reactive state
  Rx<BookingDetails?> booking = Rxn();
  RxString currentStatus = ''.obs;
  RxBool isLoading = false.obs;
  
  // Methods
  Future<void> fetchBooking(String id);
  Future<void> startWork();
  Future<void> completeWork({String? remark});
}
```

## Testing Checklist

- [ ] Consumer can create booking
- [ ] Provider sees booking request
- [ ] Provider can accept booking
- [ ] Booking appears in "Not Started" tab with correct status
- [ ] Provider can open booking details
- [ ] All data loads (name, address, service, date/time)
- [ ] Start Work button enabled for "accepted" status
- [ ] Mark Complete button enabled for "in_progress" status
- [ ] Directions opens Google Maps
- [ ] On My Way sends notification
- [ ] Status badge shows correct status
- [ ] Consumer sees updated status



