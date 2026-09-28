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

## 7. Deliverables Compliance Checklist

| University Requirement | Status | Implementation Details |
| :--- | :---: | :--- |
| **DELIVERABLE 1: Figma Design** | ✅ COMPLETED | Detailed design specification document created in `docs/FIGMA_DESIGN.md` covering all 6 screens, 8-pt spatial grid, typography, colors, and user journeys. |
| **DELIVERABLE 2: UI / Widgets** | ✅ COMPLETED | Built using Form, TextFormField, GridView, Card, Image, Date/Time widgets, Dropdown, AppBar, Loading Indicators, Error Banners, SnackBars, and Responsive Layouts. |
| **DELIVERABLE 3: Styling / Theming** | ✅ COMPLETED | Centralized Material 3 `AppTheme` with `ColorScheme`, `TextTheme`, `CardThemeData`, `InputDecorationTheme`, and consistent border radii. |
| **DELIVERABLE 4: Dart Logic & Async** | ✅ COMPLETED | Clean `async/await`, `Future`, and `Stream` operations for Auth, Firestore read/writes, and atomic transaction slot booking. |
| **DELIVERABLE 5: Firebase Integration** | ✅ COMPLETED | Full integration of Firebase Auth (Email/Password) and Cloud Firestore (4 collections). Property images handled via local assets (`assets/images/`). |
| **DELIVERABLE 6: Responsive Prototype** | ✅ COMPLETED | Adaptive GridView (1 col mobile, 2 col tablet, 3-4 col desktop/web) tested with no layout overflows. |
