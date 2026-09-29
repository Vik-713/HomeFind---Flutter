# HOMEFIND — Property Listing & Viewing Scheduler App

**Academic Project:** B.Tech Computer Science Engineering & AI — Semester V  
**Technology Stack:** Flutter, Dart, Material 3, Firebase Authentication, Cloud Firestore  
**Project Name:** HOMEFIND  

---

## 1. Project Overview & Problem Statement

HomeFind is a cross-platform mobile and web application designed for real estate agents to publish property listings with photos and pricing, and for property buyers to browse listings in real-time and book property viewing slots.

### Key Architectural Choices
* **Firebase Services Used:** Firebase Authentication (Email/Password), Cloud Firestore, Firebase Core.
* **Property Images:** Property images are bundled as local Flutter application assets (`assets/images/property1.jpg` through `property5.jpg`). **Firebase Cloud Storage is intentionally excluded** to prevent storage usage or cloud billing while demonstrating full real-time cloud data functionality.
* **Clean Real-Time Backend:** All listings, slots, and bookings are created and managed dynamically through Cloud Firestore.

---

## 2. Features & Key Functionalities

### Agent Portal
* **Agent Authentication:** Email/password login and registration using Firebase Authentication with formatted error handling.
* **Property Form Validation:** Client-side validation for title, description, price, area, location, bedroom/bathroom counts, and property type.
* **Local Asset Image Selector:** Agents select a bundled property photo asset (`assets/images/propertyX.jpg`) when creating a listing.
* **Firestore Listing Creation:** Writes complete property metadata with local asset image path to `properties/{propertyId}` in Cloud Firestore.
* **Slot Management:** Agents can view and create viewing slots for their listings in Cloud Firestore.

### Buyer Portal
* **Real-time Property Browsing:** Live update stream (`snapshots()`) from Cloud Firestore displayed in a responsive `GridView`.
* **Property Cards:** Every card displays photo, price (formatted in ₹), location, area (sq.ft), bedroom count, and bathroom count.
* **Search & Category Filter:** Client-side search bar and category filter chips (Apartment, Villa, Penthouse, Studio, Townhouse).
* **Property Details View:** Multi-image gallery carousel, full description, spec metrics, and direct booking action.
* **Viewing Scheduler & Safe Booking:** Real-time viewing slot selection powered by Firestore transactions (`runTransaction`) ensuring atomic double-booking prevention.
* **Booking Confirmation:** Modal dialog presenting complete viewing appointment details upon successful booking.

---

## 3. Technology Stack & Packages

* **Framework:** Flutter 3.47+ (Dart 3.13+)
* **UI & Theming:** Material 3 (Centralized `AppTheme`, `ColorScheme`, `TextTheme`, `CardThemeData`)
* **Backend Platform:** Firebase
* **Authentication:** `firebase_auth`
* **Database:** `cloud_firestore`
* **Asset Images:** `assets/images/`
* **Formatting:** `intl`

---

## 4. Project Folder Structure

```
lib/
├── main.dart                      # App entry point & Firebase initialization
├── app.dart                       # MaterialApp root widget & AppTheme binding
├── firebase_options.dart          # Configured Firebase options (homefind-app)
│
├── theme/
│   └── app_theme.dart             # Centralized Material 3 design system & colors
│
├── models/
│   ├── app_user.dart              # User profile model (users collection)
│   ├── property.dart              # Property listing model (properties collection)
│   ├── viewing_slot.dart          # Viewing slot model (viewingSlots collection)
│   └── booking.dart               # Viewing booking model (bookings collection)
│
├── services/
│   ├── auth_service.dart          # Firebase Auth & User profile handling
│   ├── asset_image_service.dart   # Local asset image helper service
│   ├── property_service.dart      # Cloud Firestore property CRUD & stream operations
│   ├── viewing_slot_service.dart  # Cloud Firestore viewing slot queries & generation
│   └── booking_service.dart       # Atomic Firestore transaction slot booking logic
│
├── screens/
│   ├── common/
│   │   └── splash_screen.dart     # Role gateway & auth state listener
│   ├── auth/
│   │   └── login_screen.dart      # Agent login & registration screen
│   ├── agent/
│   │   ├── agent_home_screen.dart # Agent dashboard & listing management
│   │   ├── add_property_screen.dart# Property listing form with asset image picker
│   │   └── manage_slots_screen.dart# Viewing slot manager for property
│   └── buyer/
│       ├── browse_properties_screen.dart # Responsive grid of live properties
│       ├── property_details_screen.dart  # Property details & photo carousel
│       ├── viewing_scheduler_screen.dart # Slot selection & buyer form
│       └── booking_confirmation_dialog.dart # Confirmed booking dialog
│
├── widgets/
│   ├── property_card.dart         # Card showing photo, price, area, location, beds
│   ├── property_image_picker.dart # Local property asset image selector
│   ├── loading_widget.dart        # Styled progress loading widget
│   └── empty_state.dart          # Empty state component with action button
│
└── utils/
    ├── validators.dart            # Form input validators
    └── error_handler.dart         # User-friendly Firebase exception converter
```

---

## 5. Database Architecture

### Cloud Firestore Collections

#### 1. `users/{uid}`
```json
{
  "uid": "firebase-agent-uid",
  "name": "Jane Agent",
  "email": "agent@example.com",
  "role": "agent",
  "createdAt": "Timestamp"
}
```

#### 2. `properties/{propertyId}`
```json
{
  "title": "Modern 2 BHK Apartment",
  "description": "Spacious apartment with modern amenities...",
  "price": 8500000,
  "area": 1250,
  "location": "Navi Mumbai",
  "bedrooms": 2,
  "bathrooms": 2,
  "propertyType": "Apartment",
  "image": "assets/images/property1.jpg",
  "imageUrls": ["assets/images/property1.jpg"],
  "agentId": "firebase-agent-uid",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

#### 3. `viewingSlots/{slotId}`
```json
{
  "propertyId": "property123",
  "date": "Timestamp",
  "startTime": "10:00 AM",
  "endTime": "11:00 AM",
  "isAvailable": true
}
```

#### 4. `bookings/{bookingId}`
```json
{
  "propertyId": "property123",
  "slotId": "slot123",
  "propertyTitle": "Modern 2 BHK Apartment",
  "buyerName": "John Buyer",
  "buyerEmail": "buyer@example.com",
  "date": "Timestamp",
  "startTime": "10:00 AM",
  "endTime": "11:00 AM",
  "status": "confirmed",
  "createdAt": "Timestamp"
}
```

---

## 6. How to Run the Application

1. Get dependencies:
   ```bash
   flutter pub get
   ```
2. Run on target device or browser:
   ```bash
   # Run on Chrome Web
   flutter run -d chrome

   # Run on connected Android / iOS device or Simulator
   flutter run
   ```

---

## 7. Cloud Firestore Security Rules

To ensure strict data privacy and access control, security rules enforce authentication and role isolation:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create, update: if isOwner(userId);
      allow delete: if false;
    }

    match /properties/{propertyId} {
      allow read: if true;
      allow create: if isAuthenticated()
                    && request.resource.data.agentId == request.auth.uid;
      allow update, delete: if isAuthenticated()
                            && resource.data.agentId == request.auth.uid;
    }

    match /viewingSlots/{slotId} {
      allow read: if true;
      allow create, update: if true;
      allow delete: if isAuthenticated();
    }

    match /bookings/{bookingId} {
      allow create: if true;
      allow read: if true;
      allow update, delete: if isAuthenticated();
    }
  }
}
```

---

## 8. Atomic Double-Booking Prevention & Cancellation

### Transactional Booking (`runTransaction`)
When a buyer books a property viewing slot, `BookingService` executes an atomic Firestore transaction:
1. Reads the target `viewingSlots/{slotId}` document within the transaction.
2. Asserts that `isAvailable == true`. If already reserved by another user concurrently, the transaction aborts and throws an exception (`Slot already booked`).
3. Updates `isAvailable` to `false` and creates a new `bookings` document atomically.

### Booking Cancellation & Slot Cleanup
- Buyers can view their scheduled visits timeline in the **Scheduled Visits** screen.
- Tapping any scheduled visit card prompts a confirmation dialog and provides a direct trash icon action to cancel the visit.
- `BookingService.cancelBooking(bookingId, slotId)` atomically deletes the `bookings/{bookingId}` record and sets `isAvailable = true` on `viewingSlots/{slotId}`, freeing up the slot for future bookings.

---

## 9. Navigation & Portal Features

### Buyer Portal Navigation
1. **Explore & Search (`SearchExploreScreen`)**: Responsive grid with search bar, filter chips, property cards, and instant details navigation.
2. **Scheduled Visits (`ScheduledTimelineScreen`)**: Timeline view of upcoming viewing appointments with agent details, address, date/time, and one-tap cancellation.
3. **Saved Listings / Favorites**: Quick access to saved properties.
4. **Buyer Account (`BuyerAccountScreen`)**: Budget preferences, notification toggles, saved search alerts, and portal switch gateway.

### Agent Portal Navigation
1. **Property Dashboard (`AgentHomeScreen`)**: Agent-isolated property listing cards displaying photo, location, price, and active slots.
2. **Scheduled Visits (`AgentScheduledVisitsScreen`)**: Agent-isolated view of upcoming property viewing appointments booked by buyers (includes buyer name, contact email, property photo, date, and time slot).
3. **Slot Manager (`ManageSlotsScreen`)**: Tool for agents to add, enable, or inspect viewing slots for their specific properties.

---

## 10. Responsive Design System & Layout Safeguards

- **Theme System (`AppTheme`)**: High-contrast, ultra-sleek dark theme with curated hex tokens (`0xFF121212` background, `0xFF181818` card surface, `0xFF2E2E2E` borders).
- **Dynamic Breakpoints (`GridView`)**:
  - Smartphone (< 550px): 1 column, aspect ratio `0.86` (prevents bottom button overflow and eliminates blank space).
  - Tablet / Medium (550px - 899px): 2 columns, aspect ratio `0.80`.
  - Desktop / Large (>= 900px): 3 or 4 columns, aspect ratio `0.81`.
- **Seamless Pill Search Inputs**: Decorated with `clipBehavior: Clip.antiAlias`, `filled: false`, and `BorderRadius.circular(30)` to eliminate rectangular background outline artifacts.

---

## 11. Project Verification & Status

- `flutter analyze`: **0 issues / clean analysis pass**.
- `flutter test`: **All unit and widget tests passing**.

 