# Feature: Reservation Management

## Overview

Create a reservation management feature that allows users to:
- View their **upcoming reservations**
- View their **past reservations**
- **Cancel** an upcoming reservation
- **Download the reservation confirmation/ticket** if it has not already been downloaded
- **View reservation details** in a reservation overview screen
- **Re-book** a past reservation for another date

The design should follow the provided mobile mockups.

---

## UI Reference

The feature consists of the following screens:

### Screen 1 — My Bookings
This screen contains two tabs:
- **Upcoming** reservations
- **Past** reservations

Each reservation card should display:
- Facility / field image
- Facility name (e.g. `FIS CSR`)
- Rating summary (e.g. `4.0` with review count)
- Reservation date and time (e.g. `14 Sep [16:00-18:00]`)
- Sport type (e.g. `Football`)
- Action buttons based on reservation type:
  - Upcoming: `Cancel Reservation`, `Show Reservation`
  - Past: `Show Reservation`

### Screen 2 — Reservation Overview (Upcoming)
When opening an upcoming reservation, show:
- Large facility image at the top
- Facility name and city/location
- Rating summary
- Buttons:
  - `Show on Map`
  - `Make a player search post` (if this feature already exists in the app)
- Reservation ID section with a styled ticket-like panel
- Reservation details:
  - Name
  - Mobile
  - Sport Name
  - Address
  - Date
  - Price
  - Court Name
  - Pitch Number
  - Booking Time
- Bottom primary button: `Download Ticket`

### Screen 3 — Reservation Overview (Past)
When opening a past reservation, show:
- Same facility image header and facility information
- Reservation details displayed in a clean summary layout
- Optional favorite/like icon in the header if already supported in the app
- Bottom primary button: `Reserve again`

---

## Flutter Implementation Instructions

### 1. Screens to Create

#### `my_bookings_screen.dart`
- Route: `/bookings`
- Contains segmented tab switcher for `Upcoming` and `Past`
- Fetches reservations for the authenticated user from the API
- Splits reservations into upcoming and past based on reservation date/time
- Displays reservation cards in a vertical list
- Tapping `Show Reservation` navigates to the reservation overview screen

#### `reservation_overview_screen.dart`
- Route: `/bookings/:reservationId`
- Fetches complete reservation details by reservation ID
- Reuses the same screen for both upcoming and past reservations
- Shows different bottom actions depending on reservation status:
  - Upcoming → `Download Ticket`
  - Past → `Reserve again`
- If reservation is upcoming, also show `Show on Map` and optional `Make a player search post` button

### 2. Widgets to Create

#### `reservation_card.dart`
Displays a booking card in the bookings list:
- Facility thumbnail/image
- Facility name
- Rating and review count
- Reservation date/time
- Sport type
- Action buttons depending on tab/status

#### `reservation_ticket_card.dart`
Displays reservation details in a stylized card/ticket format:
- Reservation ID
- User details
- Facility/court details
- Date/time
- Price

#### `booking_tab_switcher.dart`
- Reusable segmented control for `Upcoming` and `Past`
- Matches the green/white tab style from the mockup

---

## Required Flutter Behavior

### Upcoming reservations
- Show only reservations whose start date/time is in the future and are not cancelled
- Buttons:
  - `Cancel Reservation`
  - `Show Reservation`

### Past reservations
- Show reservations whose reservation time has already passed
- Buttons:
  - `Show Reservation`
- Reservation overview should include `Reserve again`

### Cancel reservation flow
- On tapping `Cancel Reservation`, show a confirmation dialog:
  - Title: `Cancel reservation?`
  - Message: explain that the reservation will be cancelled and may not be recoverable
- If user confirms, call backend cancel endpoint
- Refresh the list after successful cancellation
- Cancelled reservations should no longer appear under upcoming reservations

### Download ticket flow
- On the upcoming reservation overview screen, show `Download Ticket`
- If the ticket/confirmation was already downloaded before, hide or disable the button according to backend state
- Download the confirmation as PDF or the existing supported file type
- Save locally using the platform's supported storage/share flow

### Reserve again flow
- On past reservation overview, tapping `Reserve again` should navigate the user into the existing reservation flow
- Pre-fill as much data as possible from the old reservation:
  - Facility
  - Sport
  - Court/Pitch
  - Duration
- User must select a **new available date/time** before confirming a new reservation

---

## ASP.NET Backend Instructions

### 1. Endpoints to Create

#### `GET /api/reservations/my`
- Returns all reservations for the authenticated user
- Supports optional query param `status=upcoming|past|all`
- Should include enough data for card display:
  - Reservation ID
  - Facility name
  - Facility image
  - Rating average / review count
  - Sport type
  - Date
  - Start time
  - End time
  - Status

#### `GET /api/reservations/{reservationId}`
- Returns full details for one reservation overview screen
- Includes:
  - Reservation ID
  - Facility data
  - Address/location
  - Reservation timing
  - User contact info
  - Court/Pitch info
  - Price
  - Whether confirmation/ticket has already been downloaded
  - Whether reservation is upcoming or past

#### `POST /api/reservations/{reservationId}/cancel`
- Cancels an upcoming reservation belonging to the authenticated user
- Validation:
  - Reservation belongs to current user
  - Reservation is still upcoming
  - Reservation is not already cancelled
- Returns success response and updated reservation status

#### `GET /api/reservations/{reservationId}/ticket`
- Generates or returns the reservation confirmation file
- Marks confirmation as downloaded if your current business logic requires tracking first download
- Only available for reservations that belong to the authenticated user

#### `POST /api/reservations/{reservationId}/rebook`
- Optional helper endpoint
- Returns data needed to pre-fill the booking form for a new reservation
- Does **not** create the reservation automatically
- Alternatively, reuse existing booking endpoints and pass the original reservation data from the details response

### 2. DTO Suggestions

```csharp
public class ReservationListItemDto
{
    public int Id { get; set; }
    public string FacilityName { get; set; }
    public string FacilityImageUrl { get; set; }
    public double RatingAverage { get; set; }
    public int ReviewCount { get; set; }
    public string SportName { get; set; }
    public DateTime ReservationDate { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public string Status { get; set; }
}

public class ReservationDetailsDto
{
    public int Id { get; set; }
    public string ReservationNumber { get; set; }
    public string FullName { get; set; }
    public string Mobile { get; set; }
    public string FacilityName { get; set; }
    public string City { get; set; }
    public string Address { get; set; }
    public string SportName { get; set; }
    public string CourtName { get; set; }
    public string PitchName { get; set; }
    public DateTime ReservationDate { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public decimal Price { get; set; }
    public string FacilityImageUrl { get; set; }
    public bool IsUpcoming { get; set; }
    public bool IsCancelled { get; set; }
    public bool TicketDownloaded { get; set; }
}
```

---

## Business Logic Rules

- Users can only see and manage **their own** reservations.
- Upcoming reservations are reservations with a future start date/time and not cancelled.
- Past reservations are reservations whose end date/time has passed.
- Cancelled reservations should be excluded from the standard upcoming list unless the app already has a cancelled section.
- A reservation can only be cancelled while it is still upcoming.
- `Download Ticket` should only be available if the reservation confirmation has not already been downloaded, based on the requirement.
- `Reserve again` must create a **new booking flow**, not duplicate the old booking immediately.

---

## Navigation Flow

```text
[Bottom Navigation]
      |
      v
[My Bookings Screen] (/bookings)
   |                     |
   | Upcoming            | Past
   v                     v
[Reservation Card]    [Reservation Card]
   |                     |
   v                     v
[Reservation Overview] [Reservation Overview]
   |                     |
   | Download Ticket     | Reserve again
   | Cancel Reservation  |
   v                     v
[file download]      [Existing booking flow with prefilled data]
```

---

## Design Notes

Follow the mockup closely:
- Use green as the primary brand/action color
- Use rounded cards and pill-style tab buttons
- Reservation cards should have the image at the top and action buttons at the bottom
- Reservation overview should use a ticket/invoice-like card for booking details
- The bottom action button should be full-width, green, and fixed near the bottom
- Keep spacing, typography, and section hierarchy clean and mobile-first

---

## Acceptance Criteria

- [ ] User can open a `My Bookings` screen and switch between `Upcoming` and `Past`
- [ ] Upcoming reservations display `Cancel Reservation` and `Show Reservation`
- [ ] Past reservations display `Show Reservation`
- [ ] User can open reservation details from either tab
- [ ] User can cancel an upcoming reservation after confirming in a dialog
- [ ] Cancelled reservations are removed from the upcoming list after refresh
- [ ] User can download the reservation confirmation/ticket if it has not already been downloaded
- [ ] Download button is hidden or disabled after ticket is already downloaded, depending on returned state
- [ ] Past reservation details screen includes `Reserve again`
- [ ] `Reserve again` starts a new booking flow with prefilled reservation data
- [ ] Backend validates ownership before returning, cancelling, downloading, or rebooking any reservation
- [ ] UI follows the structure and style of the provided design mockup

---

## Copilot Notes

- Reuse existing models, authentication, API service classes, and booking flow where possible.
- Do not recreate database schema unless a missing field is required (for example `TicketDownloaded` or `IsCancelled`).
- Match existing Flutter project architecture and ASP.NET controller/service/repository patterns.
- Keep the code modular and production-ready.
