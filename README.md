# AutoCare — Automobile Maintenance & Services App (Phase 1 GUI)

AutoCare is a premium mobile application tailored specifically for Pakistani car and motorcycle owners to effortlessly track vehicle maintenance, component checklists, servicing logs, and repair expenses in Pakistani Rupees (PKR).

---

## 🚗 Features Implemented in Phase 1 (Frontend GUI)

### 1. Garage & Vehicles
- **Dual Category Support**: Distinct workflows for Cars (Suzuki Alto, Toyota Corolla) and Motorcycles (Honda CD 70).
- **Vehicles List & Filters**: Instant filtering between All, Car, and Motorcycle.
- **Add / Edit Vehicle**: Forms with validation for Make, Model, Year, Fuel Type (Petrol, Diesel, Hybrid, EV, CNG), Odometer, and Pakistani registration numbers (e.g., `KHI-7821`, `LHE-5490`).
- **Vehicle Dashboard**: Hero vehicle statistics, odometer metrics, component status, and maintenance action shortcuts.
- **Destructive Action Safety**: Confirmation dialogs before vehicle removal.

### 2. Vehicle-Specific Maintenance Categories
- **Motorcycle Categories**:
  - Engine Oil (4T 20W-50 / 10W-40)
  - Brakes (Drum shoes & lever free-play)
  - Chain & Sprocket (Slack adjustment 15-25mm, cleaning & lube)
  - Spark Plug (Electrode cleaning & gap)
  - Air Filter (Foam washing & oiling)
  - Clutch & Transmission
  - Tires & Wheels (Spoke inspection & pressure)
  - Battery & Electrical
  - General Inspection
  - Cleaning & Wash
- **Car Categories**:
  - Engine Oil & Genuine Filters
  - Spark Plugs & Fuel Injector / Throttle Cleaning
  - Brakes & Fluid (Pads, disc rotors & DOT fluid)
  - Cooling System & Radiator (Cap & coolant level)
  - Tires, Alignment & Wheel Camber
  - Battery & Alternator Output
  - Belts & Serpentine Hoses
  - Transmission & Clutch
  - Suspension & Steering Bushes
  - Air Conditioning (Cabin pollen filter & condenser)
  - Cleaning & Underbody Detailing

### 3. Interactive Multi-State Service Checklists
- **Checklist Scenarios**:
  - Routine Motorcycle Service (11 realistic inspection tasks)
  - Complete Multi-Point Car Tuning (12 inspection & cleaning tasks)
- **5-State Task Management**:
  - `Not Started`
  - `Done`
  - `Not Required`
  - `Needs Repair/Adjustment`
  - `Needs Replacement`
- **Interactive Notes & Progress Bar**: Add custom notes to tasks, filter by status, and export directly into a new Service Record.

### 4. Service Records & Maintenance History
- **PKR Financials**: Calculates parts cost, labor cost, and total invoice automatically (e.g. `Rs. 8,000`).
- **Dual History Filters**: Filter by vehicle and by service type.
- **Detailed Invoice Modal**: Shows work performed, parts replaced, and future due dates/mileages.

### 5. Reminders & Alerts
- **Dual Trigger Modes**: Date-based (`Due in 15 days`) and mileage-based (`Due at 12,500 km`).
- **Separated Tabs**: Upcoming, Overdue, and Completed.

### 6. Expense Analytics
- **PKR Lifetime Spending Tracker**: Real-time aggregation of local mock data.
- **Parts vs. Labor Ratio**: Visual bar chart showing hardware vs workshop labor percentage.
- **Spending by Vehicle & Category**: Progress bar breakdown for each vehicle.

### 7. Searchable Maintenance Guides
- Comprehensive step-by-step DIY inspection procedures:
  - Checking Engine Oil Level & Quality
  - Inspecting Motorcycle Drive Chain Tension (15-25mm rule)
  - Tire Pressure & Tread Wear
  - Identifying Worn Brake Components
  - Inspecting & Washing Air Filters
  - Recognizing Battery & Charging Faults
- Safety warnings (e.g. Never inspect chain with engine running, never open hot pressurized radiators).

---

## 🛠️ Project Structure

```
lib/
├── main.dart                                    # Main entry point with DevicePreview
├── app.dart                                     # AutoCareApp wrapper & AppStateScope
├── core/
│   ├── theme/app_theme.dart                    # AutoCare Material 3 theme & color tokens
│   ├── constants/app_constants.dart             # Brand constants, vehicle & service types
│   └── utils/formatters.dart                   # PKR currency, mileage, and date formatting
├── models/
│   ├── vehicle.dart                            # Vehicle entity
│   ├── maintenance_item.dart                   # Maintenance category & status
│   ├── service_record.dart                     # Service invoice entity with PKR costs
│   ├── checklist_item.dart                     # 5-state checklist task entity
│   ├── reminder.dart                           # Date and mileage reminder entity
│   └── guide.dart                              # DIY guide with safety warnings
├── data/
│   └── mock_data.dart                          # Pakistani vehicles (CD 70, Alto, Corolla) & guides
├── state/
│   └── app_state.dart                          # Reactive in-memory ChangeNotifier & InheritedNotifier
├── navigation/
│   └── app_scaffold.dart                       # Persistent 5-destination bottom navigation bar
├── shared/
│   └── widgets/
│       ├── custom_card.dart                    # Rounded card with subtle borders & elevation
│       ├── status_badge.dart                   # Visual status badges
│       ├── metric_tile.dart                    # Dashboard statistics tile
│       └── empty_state.dart                    # Clean empty state placeholder
└── features/
    ├── splash/splash_screen.dart               # Automotive emblem & tagline splash
    ├── home/home_screen.dart                   # "Your Garage" dashboard & quick actions
    ├── vehicles/
    │   ├── vehicles_screen.dart                # Car & bike list with filters
    │   ├── add_edit_vehicle_screen.dart        # Vehicle registration form with validation
    │   └── vehicle_detail_screen.dart          # Vehicle hero stats & category status
    ├── maintenance/
    │   ├── maintenance_categories_screen.dart  # Tailored car/bike category grid
    │   └── checklist_screen.dart               # 5-state interactive checklist with progress
    ├── service_records/
    │   └── add_service_record_screen.dart      # Service entry logger with auto-calculated total
    ├── history/
    │   ├── history_screen.dart                 # Filterable service history timeline
    │   └── service_record_detail_screen.dart   # Detailed invoice breakdown
    ├── reminders/
    │   ├── reminders_screen.dart               # Upcoming & overdue maintenance tabs
    │   └── add_reminder_screen.dart            # Date & mileage reminder form
    ├── expenses/
    │   └── expenses_screen.dart                # Spending analytics in PKR with ratio charts
    ├── guides/
    │   ├── guides_screen.dart                  # Searchable DIY inspection guide cards
    │   └── guide_detail_screen.dart            # Step-by-step procedures & safety warnings
    └── profile/
        └── profile_screen.dart                 # Mock user profile, currency & preferences
```

---

## 🚀 Running the Application

### Option A: Mobile Phone Preview (Recommended for rapid testing)
Runs in Chrome with realistic mobile phone hardware skins (Pixel 9, iPhone 16) and instant Hot Reload:

```powershell
cd C:\Users\user\.gemini\antigravity-ide\scratch\flutter_mobile_app
flutter run -d chrome
```

*(Or double-click `run_mobile_preview.bat`)*

### Option B: Native Android Virtual Device (AVD)
Launch the pre-provisioned Android phone emulator:

```powershell
android emulator start medium_phone
flutter run
```

*(Or double-click `start_android_emulator.bat`)*

---

## 🧪 Quality Assurance & Analysis

- `flutter analyze`: **0 issues found**
- `flutter test`: **All tests passed**
- `flutter build web`: **Compilation succeeded**
