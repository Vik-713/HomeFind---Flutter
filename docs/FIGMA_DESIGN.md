# HOMEFIND - Figma Design Specification
**Academic Project:** B.Tech Computer Science Engineering & AI (Semester V)  
**App Name:** HOMEFIND – Property Listing & Viewing Scheduler App  

---

## 1. Overview & UI System Architecture

This document provides the complete design specification for the **HOMEFIND** mobile and web application. It specifies artboard dimensions, grid layouts, color palettes, typography scale, component specs, micro-interactions, and screen-by-screen navigation journeys so the entire design can be faithfully created in Figma.

---

## 2. Design System Tokens & Styles

### A. Color Palette
* **Primary Brand Navy:** `#0F172A` (Slate 900) — Dominant header, primary buttons, structural hierarchy
* **Primary Royal Blue:** `#2563EB` (Blue 600) — Active state highlights, interactive links, primary actions
* **Secondary Emerald Accent:** `#059669` (Emerald 600) — Property price tags, availability badges, booking confirmation icons
* **Background Surface:** `#F8FAFC` (Slate 50) — Canvas background
* **Card Surface:** `#FFFFFF` — White cards with subtle border `#E2E8F0`
* **Text Main:** `#1E293B` (Slate 800) — High-contrast body & title text
* **Text Muted:** `#64748B` (Slate 500) — Captions, secondary metrics, icons
* **Error / Alert Red:** `#DC2626` — Form validation, booked status badges

### B. Typography Scale (Inter / Roboto Font Family)
* **Display Large:** 32px / SemiBold (Tracking -0.5px) — App Branding Title
* **Headline Medium:** 24px / Bold — Screen Titles, Section Headers
* **Title Large:** 18px / Bold — Property Card Titles, Main Dialog Headers
* **Title Medium:** 16px / SemiBold — Form Labels, Card Subtitles
* **Body Large:** 16px / Regular — Description Text
* **Body Medium:** 14px / Regular — Input Text, Dropdown Items
* **Body Small / Caption:** 12px / Medium — Badges, Footers, Helper Text

### C. Elevation & Spacing System
* **Grid:** 8-point spatial system (8px, 16px, 24px, 32px, 48px)
* **Corner Radius:**
  * Cards: 16px
  * Input Fields & Buttons: 12px
  * Badges & Chips: 20px / Pill
* **Shadows:**
  * Light Card Shadow: `0px 4px 12px rgba(15, 23, 42, 0.06)`
  * Dialog Shadow: `0px 12px 32px rgba(15, 23, 42, 0.15)`

---

## 3. Screen-by-Screen Specifications

### Screen 1: Splash & Gateway Screen (`Frame 1: 390x844 iPhone 14 / Web 1440x900`)
* **Purpose:** Initial splash & role selection screen.
* **Layout:** Centered column with branding logo icon (`Icons.home_work_rounded`, size 64px in a circle).
* **Elements:**
  * App Name: "HOMEFIND" (32px Bold)
  * Subtitle: "Property Listing & Viewing Scheduler" (14px Muted)
  * Card 1 (Buyer Flow): "Property Buyer" with Emerald search icon + "Browse Properties" primary button.
  * Card 2 (Agent Flow): "Property Agent" with Royal Blue agent icon + "Agent Login" secondary button.
* **Interactions:**
  * Tap "Browse Properties" → Navigate to **Screen 3 (Browse Properties)**.
  * Tap "Agent Login" → Navigate to **Screen 2 (Agent Login)**.

---

### Screen 2: Agent Login Screen (`Frame 2: 390x844`)
* **Purpose:** Email/password authentication for listing agents.
* **Header:** AppBar with "Agent Login".
* **Form Container:** Centered card (width: 100% on mobile, max 440px on web).
* **Input Fields:**
  * Email Field: Outlined text field (`Icons.email_outlined`), placeholder `agent@example.com`.
  * Password Field: Outlined text field (`Icons.lock_outline`) with show/hide eye toggle.
* **CTA Button:** "Sign In" (50px height, `#2563EB` fill, 12px radius).
* **Validation / Error Banner:** Soft red banner (`#FEF2F2`) with red warning icon for invalid credentials.
* **Interactions:**
  * Valid Submission → Firebase Authentication → Navigate to **Screen 3 (Agent Home / Listing Form)**.

---

### Screen 3: Property Listing Upload Screen (`Frame 3: 390x844 / Web 1440x900`)
* **Purpose:** Allows authenticated agent to create a property record with photos.
* **Header:** "Add Property Listing" with back navigation.
* **Components & Layout:**
  * **Photo Picker Box:** Interactive dropzone (Height 140px, dotted border `#E2E8F0`, `#F1F5F9` background). Shows horizontal thumbnail preview bar with remove (`X`) buttons when photos are selected.
  * **Title Input:** Text field "Property Title *" (e.g. "Modern 2 BHK Luxury Apartment").
  * **Description Input:** Multi-line text field (3 lines height).
  * **Metrics Grid (2 Columns):**
    * Price Field (₹)
    * Area Field (sq.ft)
  * **Location Input:** Text field with location pin icon.
  * **Specs Row (3 Fields):** Bedrooms dropdown/input, Bathrooms input, Property Type dropdown (Apartment, Villa, Penthouse, Studio, Townhouse).
  * **Upload Progress Indicator:** Linear progress bar with status text ("Uploading images to Firebase Storage...").
  * **Submit Button:** "Publish Property Listing" (52px height, `#2563EB` fill).
* **Interactions:**
  * Submit → Firebase Storage Image Upload → Firestore Document Creation → Return to Agent Dashboard with Success SnackBar.

---

### Screen 4: Browse Properties Screen (`Frame 4: 390x844 / Web 1440x900 Grid`)
* **Purpose:** Responsive grid displaying real-time Firestore property listings.
* **Header:** "HOMEFIND" branding title + "Agent Login" button + "Seed Demo Data" action button.
* **Search & Filter Bar:**
  * Search field ("Search title, location, or price...").
  * Horizontal filter chips: `All`, `Apartment`, `Villa`, `Penthouse`, `Studio`, `Townhouse`.
* **Responsive Property Cards Grid:**
  * Mobile: 1 Column
  * Tablet: 2 Columns
  * Desktop: 3-4 Columns
* **Card Specs (Every Card displays all 5 mandatory items):**
  1. **Photo:** 16:10 aspect ratio image with Property Type chip badge in top-left corner.
  2. **Price:** Bold `#059669` (Emerald) price string (e.g. `₹85,00,000`).
  3. **Title:** Single-line truncated title (16px Bold).
  4. **Location:** Location pin icon + location name (e.g. `📍 Navi Mumbai`).
  5. **Bedroom & Area Specs:** Bed count (`🛏 2 Beds`), Bath count (`🛁 2 Baths`), Area (`📐 1,250 sq.ft`).
  6. **CTA Button:** "Book Viewing" button (42px height).
* **Empty State:** Clean illustration/icon + "No Properties Available Yet" + "Load Sample Properties" button.
* **Interactions:**
  * Tap Card → Navigate to **Screen 5 (Property Details)**.
  * Tap "Book Viewing" → Navigate to **Screen 6 (Viewing Scheduler)**.

---

### Screen 5: Property Details Screen (`Frame 5: 390x844`)
* **Purpose:** Detailed presentation of selected property.
* **Header:** Photo carousel with dot pagination indicator.
* **Content:**
  * Price & Property Type chip.
  * Full Title & Location.
  * Spec Box: 3 metric icons for Beds, Baths, sq.ft Area.
  * Description paragraph.
  * Full-width Floating CTA: "Schedule Property Viewing" (`#2563EB` fill, 54px height).

---

### Screen 6: Viewing Scheduler & Booking Confirmation (`Frame 6: 390x844`)
* **Purpose:** Allows buyer to select an available slot and book an appointment.
* **Sections:**
  1. **Property Summary Banner:** Compact banner displaying property image thumbnail, title, price, and location.
  2. **Buyer Form:** "Your Full Name *" and "Your Email Address *".
  3. **Viewing Slots List (Firestore Stream):**
     * Cards showing slot date (e.g. `Thu, Oct 1, 2026`), time window (e.g. `10:00 AM - 11:00 AM`), and badge (`AVAILABLE` in green vs `BOOKED` in red).
     * Radio selection dot indicating active selection.
  4. **Submit CTA Button:** "Confirm & Book Viewing Slot" (52px height).
* **Booking Confirmation Dialog Overlay:**
  * Modal with green checkmark badge.
  * Title: "Viewing Booked Successfully!"
  * Details table showing Property Title, Date, Time Slot, Buyer Name, Buyer Email.
  * Action button: "Back to Browse Properties".

---

## 4. Complete User Journey Diagram

```
[Splash Screen]
      │
      ├─── (Agent Path) ───► [Agent Login] ───► [Listing Upload Form]
      │                                                │ (Upload Photos & Save Firestore)
      │                                                ▼
      └─── (Buyer Path) ───► [Browse Properties Grid] (Real-Time Firestore Stream)
                                     │
                                     ├───► [Property Details]
                                     │            │
                                     ▼            ▼
                               [Viewing Scheduler Screen]
                                           │ (Select Slot & Submit Form)
                                           ▼
                                [Firestore Transaction]
                                           │ (Mark Slot Booked & Create Booking)
                                           ▼
                            [Booking Confirmation Dialog]
```

---

## 5. Design Checklist & Compliance
- [x] All 6 screens defined with exact layouts and component specs
- [x] 8-pt grid and Material 3 theme alignment
- [x] Clear typographic hierarchy and color contrasts
- [x] Fully specifies the end-to-end Agent & Buyer journey for university project defense.
 