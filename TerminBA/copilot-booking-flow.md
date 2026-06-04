# GitHub Copilot Instructions: Booking an Appointment

## Feature Overview

Implement a multi-step **booking flow** that begins after the user selects a sports facility. The flow covers:

1. **Court Selection Screen** — browse and select a court/hall
2. **Court Detail Screen** — view court photos, specs, and tap "Select"
3. **Date & Time Slot Screen** — pick a date from a calendar and a time slot
4. **Booking Summary & Payment Screen** — review details, choose payment method, confirm
5. **Booking Confirmation Screen** — digital ticket shown after successful booking

The backend is **ASP .NET**. Use existing models, the existing HTTP client, and the existing state management solution already in the project. Do **not** introduce new packages or redefine models.

---

## Screen 1: Court Selection

### Visual Layout

```
┌─────────────────────────────────────┐
│  ← Skenderija (14 Sept)             │  ← AppBar: back + facility name + date
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │  Court 1                    │    │  ← Court card
│  │  Surface Type: Wood         │    │
│  │  Indoor                     │    │
│  │  Duration: 60 min           │    │
│  │  Sport Name: Basketball     │    │
│  │  Max players on court: 10   │    │
│  │  Price: 70 KM               │    │
│  │                  [ Select ] │    │  ← Select button
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │  Court 2                    │    │
│  │  Surface Type: Wood         │    │
│  │  Indoor                     │    │
│  │  Duration: 60 min           │    │
│  │  Sport Name: Basketball     │    │
│  │  Max players on court: 10   │    │
│  │  Price: 60 KM               │    │
│  │                  [ Select ] │    │
│  └─────────────────────────────┘    │
├─────────────────────────────────────┤
│  [ PROCEED TO SELECT A SLOT ]       │  ← Sticky bottom CTA (disabled until selected)
└─────────────────────────────────────┘
```

### Components

#### AppBar
- Leading back arrow (`Navigator.pop`)
- Title: facility name + selected date in parentheses (e.g., `"Skenderija (14 Sept)"`)
- White background

#### Court Card (`CourtCard` widget)
- `Card` with `BorderRadius.circular(12)` and subtle `BoxShadow`
- **Header row**: court name (bold) 
- **Detail rows** (icon + label pattern):
  - Surface Type
  - Indoor / Outdoor indicator
  - Duration (minutes)
  - Sport Name
  - Max players on court
  - Price (formatted with currency, e.g., `70 KM`)
- **Select button**: `OutlinedButton` or `ElevatedButton` aligned to bottom-right of the card
  - When selected: green filled (`Color(0xFF4CAF50)`), white text `"Selected ✓"`
  - When unselected: outlined, dark text `"Select"`
- Only one court can be selected at a time (single-select)

#### Court List
- `ListView.builder` — do not use a static `Column`
- Fetch courts from API using `facilityId` and `sport` passed from the previous screen

#### Sticky Bottom CTA
- Full-width `ElevatedButton`: `"PROCEED TO SELECT A SLOT"`
- Green background (`Color(0xFF4CAF50)`), white bold text
- **Disabled** (grey) until at least one court is selected
- On tap: navigates to **Screen 3: Date & Time Slot**

---

## Screen 2: Court Detail (optional tap from card)

### Visual Layout

```
┌─────────────────────────────────────┐
│  ← Skenderija (14 Sept)             │
│  ┌─────────────────────────────┐    │
│  │  [Court Photo Carousel]     │    │  ← Swipeable images
│  └─────────────────────────────┘    │
│  Court 1                            │
│  Surface Type: Wood                 │
│  Duration: 60 min                   │
│  Sport Name: Basketball             │
│  Max players on court: 10           │
│  Price: 60 KM                       │
│                                     │
│                  [ Select ]         │
├─────────────────────────────────────┤
│  [ PROCEED TO SELECT A SLOT ]       │
└─────────────────────────────────────┘
```

### Components

- Same `AppBar` as Screen 1
- **Photo carousel**: `PageView` with `CachedNetworkImage`; dot indicator below
- **Court specs**: same detail rows as the card, displayed as a `Column` with generous spacing
- **Select button**: same behaviour as on the card — toggles selection state
- **Sticky bottom CTA**: same as Screen 1

---

## Screen 3: Date & Time Slot Selection

### Visual Layout

```
┌─────────────────────────────────────┐
│  ← Skenderija Court 1 (14 Sept)     │
├─────────────────────────────────────┤
│  Sep 2025          <  >             │  ← Month navigator
│  Mo Tu We Th Fr Sa Su              │
│   1   2   3   4   5   6   7        │
│   8   9  10  11  12  13  14        │
│  15  16  17 [18] 19  20  21        │  ← Selected date highlighted (green circle)
│  22  23  24  25  26  27  28        │  ← Past/unavailable days greyed out
│  29  30                             │
├─────────────────────────────────────┤
│  [8:00] [8:00-9:00] [9:00-10:00]   │  ← Time slot chips (scrollable Wrap)
│  [10:00-11:00] [11:00-12:00] ...   │
│  [BOOKED] [17:00-18:00] ...        │  ← Booked slots shown in red/grey, disabled
├─────────────────────────────────────┤
│  70KM          [ PROCEED → ]        │  ← Price + proceed CTA
└─────────────────────────────────────┘
```

### Components

#### AppBar
- Title: `"[Facility] [Court Name] ([Date])"` — updates as date changes
- Back arrow

#### Calendar Widget
- Build a custom inline calendar using a `GridView` or `TableCalendar` (if already in `pubspec.yaml`; otherwise build custom)
- **Month navigation**: left/right `IconButton` arrows to change month
- **Day cell states**:
  - **Past date**: greyed out text, not tappable
  - **Available date**: normal dark text, tappable
  - **Selected date**: filled green circle (`Color(0xFF4CAF50)`), white text
  - **Today**: outlined circle, no fill
- Selecting a date triggers an API call to fetch time slots for that date + courtId

#### Time Slot Chips
- `Wrap` of `ChoiceChip` widgets below the calendar
- Each chip shows the time range (e.g., `"9:00 - 10:00"`)
- **Available slot**: green background (`Color(0xFF4CAF50)`), white text — selectable
- **Booked / Unavailable slot**: red or dark grey background, white text — disabled, not selectable
- Only one slot can be selected at a time
- Slots are fetched dynamically from the API on each date change — never hardcoded

#### Bottom Bar
- Left: total price for the selected slot (e.g., `"70KM"`) in bold
- Right: `ElevatedButton` labeled `"PROCEED →"`
  - Disabled until both a date and a time slot are selected
  - On tap: navigates to **Screen 4: Booking Summary**

---

## Screen 4: Booking Summary & Payment

### Visual Layout

```
┌─────────────────────────────────────┐
│  ← Skenderija Court 1 (14 Sept)     │
├─────────────────────────────────────┤
│  Payment Options                    │
│  [ On site ]  [ Online ]            │  ← Toggle between payment methods
├─────────────────────────────────────┤
│  Location:        Skenderija        │
│  Court:           Court 1           │
│  Facilities Type: Outdoor           │
│  Sport:           Basketball        │
│  Date:            14.9.2025.        │
│  Time:            20:00 - 21:00     │
├─────────────────────────────────────┤
│  Bill Details                       │
│  No. of Slots:    1         70KM    │
│  Slot Cost:                 70KM    │
│  Service Fee:               2KM     │
│  ─────────────────────────────      │
│  Total:                     72KM    │
├─────────────────────────────────────┤
│  Additional Notes                   │
│  [Placeholder text input]           │  ← Optional notes field
├─────────────────────────────────────┤
│  [ 72KM    PROCEED TO PAY → ]       │  ← Sticky bottom CTA
└─────────────────────────────────────┘
```

### Components

#### Payment Options Toggle
- Two-option segmented control: `"On site"` and `"Online"`
- Use a `Row` of two `ChoiceChip` or custom toggle buttons
- **Active option**: green background, white text
- **Inactive option**: outlined, grey text
- Selecting `"Online"` may show additional payment fields (card input or redirect) — implement as a placeholder `Column` ready for integration

#### Booking Details Section
- Section header: none (or subtle divider)
- `Table` or `Column` of key-value rows:
  - Location, Court, Facilities Type, Sport, Date, Time
- Values populated from the state passed through the navigation flow

#### Bill Details Section
- Section header: `"Bill Details"`
- Rows: No. of Slots + unit price, Slot Cost, Service Fee
- Divider line
- **Total row**: bold, larger font
- All values from the API response or computed locally

#### Additional Notes
- Section header: `"Additional Notes"`
- `TextField` with placeholder text, multiline, optional

#### Sticky Bottom CTA
- Full-width bar: left side shows total price bold; right side `ElevatedButton` `"PROCEED TO PAY →"`
- Green background
- On tap: submits booking via `POST /bookings` and navigates to **Screen 5** on success

---

## Screen 5: Booking Confirmation (Digital Ticket)

### Visual Layout

```
┌─────────────────────────────────────┐
│                                     │
│          ✅ (green checkmark)       │
│   Your slot has been booked!!       │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Reservation ID             │    │
│  │  21487987329578             │    │  ← Large bold reservation ID
│  ├──────────────┬──────────────┤    │
│  │ NAME         │ MOBILE       │    │
│  │ John Doe     │ +38761954923 │    │
│  ├──────────────┼──────────────┤    │
│  │ Sport Name   │ Court Name   │    │
│  │ Basketball   │ Court 1      │    │
│  ├──────────────┼──────────────┤    │
│  │ Address      │ Booking Time │    │
│  │ Terezija bb  │ 20:00-21:00  │    │
│  ├──────────────┼──────────────┤    │
│  │ Date         │ Amount       │    │
│  │ 14-09-2025   │ 72KM         │    │
│  └─────────────────────────────┘    │
│                                     │
│  [ Home ]   [ Download Ticket ]     │  ← Two bottom actions
└─────────────────────────────────────┘
```

### Components

#### Success Header
- Large green animated checkmark (`Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 80)`) or a `Lottie` animation if already used in the project
- Bold heading: `"Your slot has been booked!!"`
- No AppBar back button — this is a terminal screen; use `WillPopScope` or `PopScope` to prevent accidental back navigation

#### Reservation Ticket Card
- `Card` with rounded corners and a light shadow
- **Top section**: label `"Reservation ID"` + bold large reservation ID number
- **Grid section**: 2-column `Table` or `GridView` with labelled cells:
  - Name, Mobile
  - Sport Name, Court Name
  - Address, Booking Time
  - Date, Amount
- Subtle internal dividers between rows

#### Bottom Actions
- Two buttons side by side:
  - `"Home"`: `OutlinedButton` — navigates to the home/search screen clearing the entire booking back stack
  - `"Download Ticket"`: `ElevatedButton` (green) — generates a PDF or image of the ticket using the existing PDF/share utility in the project, or scaffolds the method with a `TODO` if not yet implemented

---

## Navigation Flow

```
FacilityDetailScreen
        │ (facilityId, sport, date)
        ▼
CourtSelectionScreen          ← /facilities/:id/courts
        │ (courtId, facilityId, sport, date)
        ▼
DateTimeSlotScreen            ← /courts/:id/timeslots?date=
        │ (courtId, facilityId, sport, date, timeSlot, price)
        ▼
BookingSummaryScreen          ← POST /bookings (on confirm)
        │ (bookingConfirmation)
        ▼
BookingConfirmationScreen     ← terminal screen
```

Pass all accumulated booking parameters via route `extra` or a dedicated booking state object — do not use global mutable singletons.

---

## API Integration (ASP .NET Backend)

Use the existing `ApiService` / `DioClient`. Do **not** create a new HTTP client.

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/facilities/{id}/courts` | List courts for a facility, filtered by sport |
| `GET` | `/courts/{id}` | Court detail with photos |
| `GET` | `/courts/{id}/timeslots` | Available + booked slots for a date |
| `POST` | `/bookings` | Create a new booking |
| `GET` | `/bookings/{id}` | Fetch booking confirmation details |

### `POST /bookings` request body fields
| Field | Type | Notes |
|---|---|---|
| `courtId` | string/int | Selected court |
| `facilityId` | string/int | Parent facility |
| `sport` | string | Selected sport |
| `date` | string (ISO 8601) | Booking date |
| `timeSlotId` | string/int | Selected time slot |
| `paymentMethod` | string | `"OnSite"` or `"Online"` |
| `notes` | string (nullable) | Additional notes |

---

## State Management

Use the state management solution already in the project (Bloc, Provider, or Riverpod).

Maintain a single **BookingFlowState** that accumulates data across all screens:

### BookingFlowState fields
- `facilityId`, `facilityName`, `facilityAddress`
- `courtId`, `courtName`, `courtSurfaceType`, `courtIsIndoor`
- `sport`, `duration`, `maxPlayers`
- `selectedDate` — `DateTime`
- `selectedTimeSlot` — time slot object (use existing model)
- `paymentMethod` — enum `OnSite | Online`
- `notes` — string
- `totalPrice` — double
- `serviceFee` — double
- `isLoading` — bool
- `error` — nullable string
- `bookingConfirmation` — nullable confirmation object (use existing model)

---

## Color & Style Tokens

Use values from the existing `ThemeData`. Fall back to these only if not already defined:

| Token | Value | Usage |
|---|---|---|
| Primary green | `Color(0xFF4CAF50)` | Active chips, CTA buttons, checkmark |
| On-primary | `Colors.white` | Text/icons on green |
| Booked slot | `Color(0xFFE53935)` | Red chip for booked time slots |
| Surface | `Colors.white` | Card backgrounds |
| Muted text | `Color(0xFF757575)` | Labels, subtitles |
| Card radius | `12` | `BorderRadius.circular(12)` |
| Chip radius | `20` | Pill chips |

---

## Accessibility

- Court `Select` buttons must have `semanticLabel`: `"Select Court 1, 70 KM"`
- Time slot chips must announce state: `"9:00 to 10:00, available"` or `"9:00 to 10:00, booked, unavailable"`
- Calendar day cells must have `semanticLabel` including the full date
- The confirmation screen checkmark must have `semanticLabel: "Booking confirmed"`
- All `CachedNetworkImage` court photos must include a `semanticLabel`
- The "Proceed to Pay" CTA must announce total price: `"Proceed to pay, 72 KM"`

---

## Edge Cases & Rules

| Scenario | Behaviour |
|---|---|
| All slots booked for selected date | Show message: `"No available slots for this date"`, keep calendar active |
| Slot becomes booked between screen load and submission | API returns conflict error → show snackbar `"Slot no longer available, please select another"` |
| Facility closed on selected date | All slots disabled, show `"Facility closed on this date"` |
| Network error on booking submit | Show error dialog with `"Retry"` and `"Cancel"` options |
| Back pressed on confirmation screen | Navigate to Home, clear booking stack |
| Payment method = Online | Show placeholder for online payment integration; do not block booking creation |

---

## File Structure

follow the current one

## Notes for Copilot

- **Do not define new data models** — use models already in the codebase
- **Do not create a new HTTP client** — use the existing `ApiService` or `DioClient`
- **Do not introduce new packages** without checking `pubspec.yaml` first
- **Do not hardcode time slots, courts, or prices** — all data comes from the API
- Time slots must reflect the facility's working hours and existing reservations — this logic lives in the backend; the Flutter side only renders what the API returns
- The **service fee** is returned by the API, not computed on the client
- The booking flow is **linear** — the user cannot skip steps; validate that each required field is set before enabling the next CTA
- Use `PopScope` (Flutter 3.22+) or `WillPopScope` on the confirmation screen to redirect back presses to Home
- The `Download Ticket` button should call a `downloadTicket(bookingId)` method; stub it with a `TODO` if the PDF utility does not yet exist
