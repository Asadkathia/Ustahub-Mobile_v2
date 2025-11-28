# Complete Booking Module Documentation

## Overview
The booking module handles the entire lifecycle of service bookings from creation to completion, including consumer booking creation, provider request management, and status updates.

---

## 📋 Booking Flow Architecture

### 1. **Consumer Booking Creation Flow**

```
Provider Details Screen
    ↓ [Book Button]
Checkout Modal (CheckoutModalBottomSheet)
    ↓ [Select Date, Time, Address, Notes]
Booking Summary Screen (BookingSummaryView)
    ↓ [Confirm Booking]
API: bookService()
    ↓
Success Screen (ServiceSuccessView)
```

#### **Step-by-Step Process:**

1. **Provider Details Screen** (`provider_details_screen.dart`)
   - Consumer views provider profile
   - Clicks "Book" button
   - Opens checkout modal

2. **Checkout Modal** (`checkout_view.dart`)
   - **Date Selection**: Uses `TableCalendar` widget
     - Date range: Today to 3 months ahead
     - Calls `getTimeSlots()` when date is selected
   - **Time Slot Selection**: 
     - Fetches available slots via `getBookingSlots()` RPC function
     - Displays slots in a grid (4 columns)
     - Shows booked slots as disabled (grey)
     - User selects available time slot
   - **Address Selection**:
     - Loads user's addresses from `ManageAddressController`
     - Shows default address or first address
     - Option to change address
   - **Notes**: Optional text field for booking notes
   - **Proceed to Checkout**: Validates and navigates to summary

3. **Booking Summary Screen** (`booking_summary_view.dart`)
   - Displays provider info, service details, address, date/time
   - Shows booking summary
   - **Confirm Button**: Creates booking via `BookingSummaryController.bookService()`

4. **Booking Creation** (`booking_summary_controller.dart` → `supabase_api_services.dart`)
   ```dart
   // Booking data structure:
   {
     "booking_id": "BOOK-{timestamp}",
     "provider_id": "{provider_uuid}",
     "service_id": "{service_uuid}",
     "address_id": "{address_uuid}",
     "booking_date": "YYYY-MM-DD",
     "booking_time": "HH:MM",
     "visiting_charge": 22,
     "note": "{user_notes}",
     "service_fee": 0,
     "total": 0,
     "item_total": 0,
     "status": "pending"
   }
   ```
   - If `plan_id` is provided, calculates totals via `calculate_booking_total` RPC
   - Inserts booking into `bookings` table
   - Returns success response

5. **Success Screen** (`service_success_view.dart`)
   - Shows payment success message
   - Displays booking date and time
   - Shows total amount paid

---

### 2. **Provider Booking Request Management**

```
Provider Homepage
    ↓ [Booking Requests Card]
Booking Request Screen (BookingRequestView)
    ↓ [Shows Pending Bookings]
Accept/Reject Actions
    ↓
Edge Function: booking-workflow
    ↓
Status Updated in Database
```

#### **Step-by-Step Process:**

1. **Booking Request Screen** (`booking_request_view.dart`)
   - Fetches pending bookings via `BookingRequestController.fetchBookingRequests()`
   - Filters: `status='pending'` AND `forProvider=true`
   - Displays list of booking requests with:
     - Consumer name and avatar
     - Service name
     - Address
     - Date and time
     - Notes

2. **Accept/Reject Actions** (`booking_request_controller.dart`)
   ```dart
   acceptOrRejectBooking({
     bookingId: "{booking_uuid}",
     status: "accepted" | "rejected"
   })
   ```
   - Calls `bookingAction()` Edge Function
   - Edge Function handles:
     - Status update in `bookings` table
     - Wallet transactions (if accepted)
     - Notification triggers
     - OTP generation (if needed)

3. **Booking Status Flow**:
   ```
   pending → accepted → in_progress → completed
              ↓
           rejected
   ```

---

## 🔧 Key Components

### **Controllers**

1. **CheckoutController** (`checkout_controller.dart`)
   - Manages date/time selection
   - Fetches time slots
   - Tracks selected service name
   - Observable state: `selectedDate`, `selectedTime`, `timeSlotsLists`

2. **BookingSummaryController** (`booking_summary_controller.dart`)
   - Handles booking creation
   - Calls repository to create booking
   - Navigates to success screen
   - Loading state management

3. **BookingRequestController** (`booking_request_controller.dart`)
   - Fetches pending bookings for provider
   - Handles accept/reject actions
   - Refreshes list after actions

### **API Services** (`supabase_api_services.dart`)

1. **`getBookingSlots(providerId, bookingDate)`**
   - Calls RPC function `get_booking_slots`
   - Returns available time slots for a date
   - Transforms response to `TimeSlotModel` format
   - Calculates end time (start time + 1 hour)

2. **`bookService(bookingData)`**
   - Creates booking record
   - Sets `consumer_id` from current user
   - Sets `status='pending'`
   - Generates `booking_id` if not provided
   - Calculates totals if plan is selected
   - Inserts into `bookings` table

3. **`getBookings({status, forProvider})`**
   - Fetches bookings with filters
   - Joins related data: services, plans, addresses, consumer profile
   - Transforms response to match `BookingRequestModel`
   - Handles both consumer and provider views

4. **`bookingAction(action, bookingId, {remark, otp})`**
   - Calls Edge Function `booking-workflow`
   - Actions: `accept`, `reject`, `start`, `complete`
   - Handles complex business logic server-side

---

## 📊 Database Schema

### **Bookings Table**
```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id TEXT UNIQUE NOT NULL,
  consumer_id UUID REFERENCES user_profiles(id),
  provider_id UUID REFERENCES user_profiles(id),
  service_id UUID REFERENCES services(id),
  plan_id UUID REFERENCES plans(id),
  address_id UUID REFERENCES addresses(id),
  booking_date DATE NOT NULL,
  booking_time TIME NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, accepted, rejected, in_progress, completed
  visiting_charge DECIMAL DEFAULT 0,
  service_fee DECIMAL DEFAULT 0,
  item_total DECIMAL DEFAULT 0,
  total DECIMAL DEFAULT 0,
  note TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### **RPC Functions**

1. **`get_booking_slots(p_provider_id, p_booking_date)`**
   - Returns available time slots for a provider on a specific date
   - Excludes already booked slots
   - Returns format: `{time_slot, is_available}`

2. **`calculate_booking_total(p_service_id, p_plan_id, p_visiting_charge)`**
   - Calculates booking totals
   - Returns: `{item_total, service_fee, total}`

---

## 🔄 Data Flow

### **Booking Creation**
```
Consumer Input
    ↓
CheckoutController (Date/Time/Address)
    ↓
BookingSummaryController
    ↓
BookingSummaryRepository
    ↓
SupabaseApiServices.bookService()
    ↓
Supabase Database (bookings table)
    ↓
Response → Success Screen
```

### **Booking Request Fetching**
```
BookingRequestController.fetchBookingRequests()
    ↓
SupabaseApiServices.getBookings(status='pending', forProvider=true)
    ↓
Supabase Query (with joins)
    ↓
Response Transformation
    ↓
BookingRequestModel List
    ↓
UI Display
```

### **Accept/Reject Flow**
```
Provider Action (Accept/Reject)
    ↓
BookingRequestController.acceptOrRejectBooking()
    ↓
SupabaseApiServices.bookingAction()
    ↓
Edge Function: booking-workflow
    ↓
Database Update + Business Logic
    ↓
Response → Refresh List
```

---

## 🎯 Key Features

1. **Time Slot Management**
   - Real-time availability checking
   - Prevents double-booking
   - Visual indication of booked slots

2. **Address Management**
   - Default address selection
   - Multiple address support
   - Address validation

3. **Status Workflow**
   - Pending → Accepted/Rejected
   - Accepted → In Progress → Completed
   - Status-based filtering

4. **Price Calculation**
   - Automatic total calculation
   - Plan-based pricing
   - Visiting charge inclusion

5. **Provider Dashboard**
   - Pending booking count
   - Quick access to requests
   - Status overview

---

## 🐛 Known Issues & Solutions

1. **Time Slot Display**
   - ✅ Fixed: Null check errors in time slot grid
   - ✅ Fixed: Empty state handling

2. **Booking Request Parsing**
   - ✅ Fixed: UUID type conversion (int → String)
   - ✅ Fixed: Nested data transformation

3. **Address Validation**
   - ✅ Fixed: Missing address ID validation
   - ✅ Fixed: Default address selection

---

## 📝 Future Enhancements

1. **Real-time Updates**
   - Supabase Realtime subscriptions for booking status
   - Push notifications for status changes

2. **Payment Integration**
   - Payment gateway integration
   - Wallet payment option

3. **Booking Modifications**
   - Reschedule functionality
   - Cancel booking option

4. **Advanced Filtering**
   - Date range filtering
   - Service-based filtering
   - Status history

5. **Analytics**
   - Booking trends
   - Revenue tracking
   - Provider performance metrics

---

## 🔍 Debugging Tips

1. **Check Booking Creation**:
   ```dart
   print('[BOOKING] Data: $bookingData');
   print('[BOOKING] Response: $response');
   ```

2. **Check Time Slots**:
   ```dart
   print('[TIME_SLOTS] Provider: $providerId, Date: $date');
   print('[TIME_SLOTS] Response: $response');
   ```

3. **Check Booking Requests**:
   ```dart
   print('[BOOKING_REQUEST] Status: ${response['statusCode']}');
   print('[BOOKING_REQUEST] Data: ${response['body']['data']}');
   ```

---

## 📚 Related Files

- `lib/app/modules/checkout/` - Checkout flow
- `lib/app/modules/booking_summary/` - Booking summary and creation
- `lib/app/modules/booking_request/` - Provider booking requests
- `lib/app/modules/bookings/` - Consumer booking history
- `lib/app/modules/provider_bookings/` - Provider booking management
- `lib/network/supabase_api_services.dart` - API layer
- `supabase/migrations/` - Database schema and functions

