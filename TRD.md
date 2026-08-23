# Jeevan (जीवन) — Technical Requirements Document

**Version:** 1.0 (Mock-Data UI Release)
**Companion to:** PRD.md
**Platform:** Flutter (Android, iOS, tablet-adaptive)

---

## 1. Objectives

Translate the PRD into a concrete, buildable Flutter architecture where:
- Every screen reads data through a repository interface, never from hardcoded widget constants.
- `MockRepository` implementations can be replaced by `FirebaseRepository` implementations later with **no UI changes** — only DI wiring changes.
- Loading, empty, and error states are first-class, reusable components, not per-screen one-offs.
- The design system (color, type, spacing) is centralized and consistently applied.

---

## 2. Tech Stack

| Concern | Choice | Rationale |
|---|---|---|
| Framework | Flutter (current stable channel) | Cross-platform requirement, single codebase for phone + tablet |
| Language | Dart (null-safe) | — |
| State management | **Riverpod** (`flutter_riverpod`, code-gen optional) | Testable, compile-safe DI, clean `AsyncValue` pattern maps directly onto loading/data/error states required by the PRD; avoids `BuildContext`-coupled state |
| Routing | **go_router** | Native support for a `StatefulShellRoute` bottom-nav pattern, deep-linkable zone/mission/chat routes, clean transition customization |
| Local/mock data | Plain Dart repository classes returning in-memory model objects, with simulated latency | Keeps data fully decoupled from UI; trivially swappable for Firebase later |
| Charts | `fl_chart` | Lightweight, fully custom-stylable, avoids "default chart library" look |
| Images | `cached_network_image` (usage pattern only, since sources are mock/asset for v1) + custom placeholder/skeleton widgets | Consistent loading treatment for future network images |
| Camera | `camera` plugin, wired to a mock capture → mock analysis pipeline | Keeps the real plugin integrated so Phase 2 ML wiring is additive |
| Connectivity | `connectivity_plus` | Backing for the global offline indicator |
| Shimmer/skeleton | Custom `SkeletonLoader` primitive (simple `AnimatedBuilder` gradient sweep) rather than a heavy third-party shimmer package, to keep exact control over shape/timing | Matches PRD's "skeletons must match final layout" requirement precisely |
| Icons | `flutter_svg` for custom line icons + Material Symbols only where no custom icon is warranted | Avoid generic icon-pack look |
| Linting | `flutter_lints` (or `very_good_analysis`) | Baseline code quality |
| Testing | `flutter_test` + `mocktail` for repository mocks | Unit + widget test coverage |

---

## 3. Architecture

Layered, unidirectional-dependency architecture:

```
Presentation (screens, widgets)
        ↓ reads/writes via
Application (Riverpod providers / controllers — loading, error, derived state)
        ↓ calls
Domain (abstract repository interfaces + models — pure Dart, no Flutter imports)
        ↓ implemented by
Data (MockXRepository now → FirebaseXRepository later)
```

**Dependency rule:** Presentation never imports Data directly. Presentation depends only on Application (providers), which depends only on Domain (interfaces + models). Data implementations are bound to interfaces exclusively at the DI root (`ProviderScope` overrides), so swapping Mock → Firebase is a one-file change.

```
UI Widget
   │  ref.watch(zoneListProvider)
   ▼
Riverpod Provider (AsyncNotifier<List<Zone>>)
   │  calls
   ▼
ZoneRepository (abstract interface, in domain/)
   │  implemented by
   ▼
MockZoneRepository   ──(Phase 2)──►   FirebaseZoneRepository
```

---

## 4. Project Structure

```
lib/
├── main.dart
├── app.dart                         # MaterialApp.router + theme + providerScope wiring
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   └── app_theme.dart           # ThemeData assembly
│   ├── routing/
│   │   ├── app_router.dart          # go_router config, StatefulShellRoute
│   │   └── route_paths.dart
│   ├── constants/
│   │   └── mock_latency.dart        # simulated network delay constants
│   └── utils/
│       ├── result.dart              # lightweight Result/Either type
│       └── formatters.dart          # unit/date formatting helpers
│
├── domain/
│   ├── models/
│   │   ├── farm.dart
│   │   ├── zone.dart
│   │   ├── sensor_reading.dart
│   │   ├── rover.dart
│   │   ├── rover_mission.dart
│   │   ├── crop_scan.dart
│   │   ├── irrigation_event.dart
│   │   ├── notification_item.dart
│   │   ├── chat_message.dart
│   │   └── app_user.dart
│   └── repositories/                # abstract interfaces only
│       ├── farm_repository.dart
│       ├── zone_repository.dart
│       ├── sensor_repository.dart
│       ├── rover_repository.dart
│       ├── crop_scan_repository.dart
│       ├── irrigation_repository.dart
│       ├── notification_repository.dart
│       ├── auth_repository.dart
│       └── chat_repository.dart
│
├── data/
│   └── mock/
│       ├── mock_farm_repository.dart
│       ├── mock_zone_repository.dart
│       ├── mock_sensor_repository.dart
│       ├── mock_rover_repository.dart
│       ├── mock_crop_scan_repository.dart
│       ├── mock_irrigation_repository.dart
│       ├── mock_notification_repository.dart
│       ├── mock_auth_repository.dart
│       ├── mock_chat_repository.dart
│       └── seed/
│           └── mock_seed_data.dart  # canonical Zone A–D values, farm identity, etc.
│   # future: data/firebase/*.dart implementing the same interfaces
│
├── application/                     # Riverpod providers/controllers, one folder per feature
│   ├── auth/
│   ├── home/
│   ├── field/
│   ├── zone_detail/
│   ├── rover/
│   ├── irrigation/
│   ├── insights/
│   ├── notifications/
│   ├── chat/
│   └── connectivity/
│
├── features/                        # screens, grouped by nav destination
│   ├── splash/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── otp_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── field/
│   │   ├── field_map_screen.dart
│   │   └── zone_detail_screen.dart
│   ├── crop_health/
│   │   ├── crop_analysis_screen.dart
│   │   └── scan_crop_screen.dart
│   ├── rover/
│   │   ├── rover_overview_screen.dart
│   │   └── rover_mission_screen.dart
│   ├── irrigation/
│   │   ├── irrigation_control_screen.dart
│   │   └── water_usage_screen.dart
│   ├── insights/
│   │   └── insights_screen.dart
│   ├── notifications/
│   │   └── notifications_screen.dart
│   ├── assistant/
│   │   └── jeevan_assistant_screen.dart
│   └── profile/
│       └── profile_screen.dart
│
└── widgets/                          # shared, reusable component library (see §9)
    ├── app_bar/jeevan_app_bar.dart
    ├── metrics/metric_row.dart
    ├── metrics/sensor_metric.dart
    ├── status/status_badge.dart
    ├── alerts/alert_banner.dart
    ├── field/zone_tile.dart
    ├── field/zone_map.dart
    ├── field/rover_marker.dart
    ├── field/moisture_legend.dart
    ├── skeleton/skeleton_loader.dart
    ├── skeleton/skeleton_card.dart
    ├── layout/section_header.dart
    ├── states/empty_state.dart
    ├── states/error_state.dart
    ├── sheets/app_bottom_sheet.dart
    ├── crop/crop_health_card.dart
    ├── irrigation/irrigation_recommendation.dart
    ├── chat/chat_bubble.dart
    └── buttons/primary_button.dart / secondary_button.dart
```

---

## 5. Data Models

Pure Dart, immutable (e.g., via manual `copyWith` or `freezed` if code-gen is acceptable to the team). No Flutter/UI imports in `domain/`.

**Farm**
`id, name, location, areaAcres, zoneCount, roverConnected, createdAt`

**Zone**
`id, farmId, name, boundaryPoints (List<Offset|LatLngLike>), cropType, currentMoisturePercent, moistureCategory (enum: veryLow/low/medium/high), status (enum: irrigationRecommended/monitor/noIrrigation)`

**SensorReading**
`zoneId, soilMoisture, soilTemperature, airTemperature, humidity, rainDetected, lightIntensity, waterLevel, ph, ec, flowRate, timestamp`

**Rover**
`id, batteryPercent, latitude, longitude, status (enum: idle/scanning/paused/returning/charging/offline), currentZoneId, connectionStatus (enum: strong/weak/offline), lastSync`

**RoverMission**
`id, name, status (enum: running/paused/completed), startedAt, coveragePercent, zoneSequence (List<String>), currentZoneId, activityLog (List<MissionActivityEntry {timestamp, label}>)`

**CropScan**
`id, zoneId, imageUrl, diagnosis, confidencePercent, severity (enum: low/moderate/high), observedInPercent, indicators (List<String>), timestamp`

**IrrigationEvent**
`id, zoneId, durationMinutes, waterUsedLiters, timestamp, triggeredBy (enum: manual/automatic)`

**NotificationItem**
`id, category (enum: irrigation/roverScan/cropHealth/rain/system), title, body, isRead, timestamp`

**ChatMessage**
`id, sender (enum: user/assistant), text, attachedData (nullable structured payload — e.g. zone summary), timestamp`

**AppUser**
`id, name, phone, email, farmName, location`

All enums back a matching **display model** (label + severity color token) resolved in the presentation layer only — domain models never contain `Color` or other Flutter types.

---

## 6. Repository Interfaces

One interface per domain area, each returning `Future`/`Stream` wrapped for async-safe consumption by Riverpod `AsyncNotifier`s. Example shape:

```dart
abstract class ZoneRepository {
  Future<List<Zone>> getZones(String farmId);
  Future<Zone> getZone(String zoneId);
  Future<SensorReading> getLatestReading(String zoneId);
  Future<void> triggerIrrigation(String zoneId, {required int durationMinutes});
}
```

Repositories required: `FarmRepository`, `ZoneRepository`, `SensorRepository`, `RoverRepository`, `CropScanRepository`, `IrrigationRepository`, `NotificationRepository`, `AuthRepository`, `ChatRepository`.

**Mock implementations** (`data/mock/`):
- Return data from `mock_seed_data.dart` (canonical Zone A–D values per PRD §7).
- Simulate latency (`Future.delayed`, ~400–900ms, centrally configurable in `core/constants/mock_latency.dart`) so skeleton states are visibly exercised during development.
- Are mutable in memory where the PRD implies state change (e.g., `triggerIrrigation` updates the in-memory zone's moisture/status so the UI reflects the simulated action).

**Binding:** all repositories are exposed as Riverpod `Provider<T>` overrides at the composition root. Swapping to Firebase later means writing `FirebaseZoneRepository implements ZoneRepository` and changing one override — no screen, widget, or controller changes.

---

## 7. State Management Pattern

- Each feature exposes one or more `AsyncNotifier`/`AsyncNotifierProvider` (Riverpod 2.x) wrapping repository calls, so consuming widgets get a uniform `AsyncValue<T>` with three cases: `loading`, `data`, `error`.
- **Binding rule:** `AsyncValue.loading()` → render the feature's Skeleton widget. `AsyncValue.error()` → render the shared `ErrorState` widget with a retry callback that calls `ref.invalidate(provider)`. `AsyncValue.data(value)` where the value is empty → render the shared `EmptyState` widget. This mapping is implemented once per screen type, not duplicated ad hoc.
- Local/ephemeral UI state (form fields, toggle states, selected map layer) uses plain `StateProvider`/`StateNotifier`, kept separate from repository-backed async state.
- Simulated real-time behavior (e.g., rover moving along its scan path, sensor values drifting slightly) is implemented with a `Timer.periodic` inside a controller — this gives reviewers a "live" feeling without needing sockets, and the same controller shape will later host a Firestore stream listener.

---

## 8. Navigation & Routing

`go_router` with a `StatefulShellRoute` for the four bottom-nav branches (Home, Field, Rover, Insights), preserving each tab's navigation stack independently. Auth flow (`splash → login/signup → otp → forgot-password`) sits outside the shell. Modal/full-screen flows (Zone Detail, Crop Analysis, Scan Crop, Irrigation Control, Water Usage, Notifications, Jeevan Assistant, Profile) are pushed routes reachable from within the relevant tab, deep-linkable by ID where relevant (e.g. `/field/zone/:zoneId`).

Route transitions use a short (≈200ms), restrained custom transition (shared-axis or fade-through) — not the platform default abrupt push — per PRD §8.3.

---

## 9. Design System

### 9.1 Color tokens (`app_colors.dart`)
| Token | Purpose |
|---|---|
| `charcoalSoil` | Primary text, deep soil/charcoal |
| `paperBackground` | Warm off-white agricultural-paper background |
| `accentGreen` | Primary accent — controlled, muted, not neon |
| `warningAmber` | Warning severity |
| `criticalRed` | Critical severity (soft, not saturated alarm red) |
| `waterBlue` | Water-related information |
| Neutral scale | Borders, dividers, disabled states, skeleton base/highlight |

All color pairs validated for outdoor-readable contrast (see §14.2).

### 9.2 Typography (`app_typography.dart`)
A single named scale (e.g., `display`, `headline`, `title`, `body`, `label`, `caption`) mapped onto Flutter's `TextTheme`, one legible typeface family, consistent weights. No ad hoc `TextStyle(fontSize: ...)` calls in screens — always reference the scale.

### 9.3 Spacing & radius (`app_spacing.dart`, `app_radius.dart`)
4/8pt spacing scale (`xs=4, sm=8, md=16, lg=24, xl=32...`) and a restrained radius scale (small for inputs/badges, medium for surfaces — deliberately avoiding the "everything is a giant rounded card" look flagged in the PRD).

### 9.4 Theming
`app_theme.dart` assembles a single `ThemeData` (Material 3 base, heavily customized `ColorScheme`, `TextTheme`, component themes for buttons/inputs/app bars) so widgets pull from `Theme.of(context)` rather than hardcoding style values.

---

## 10. Skeleton / Loading System

- `SkeletonLoader`: base primitive — a bounded box with a looping gradient-sweep animation (`AnimationController` + `LinearGradient` + `ShaderMask`, ~1.2s loop, respects `prefersReducedMotion` where available).
- `SkeletonCard`, and per-feature composites (`ZoneTileSkeleton`, `RoverStatusSkeleton`, `ChartSkeleton`, `ZoneMapSkeleton`, `ActivityTimelineSkeleton`, `NotificationSkeleton`, `ProfileSkeleton`, `CropHealthSkeleton`) are built by composing `SkeletonLoader` shapes into the **exact layout** of their real counterpart widget, so there is no layout jump on data arrival (PRD §8.1 requirement).
- Screens implement: `if (asyncValue.isLoading) return const XSkeleton();` as the first branch of their build method — enforced by convention/lint review, not framework magic.
- Initial app load: a lightweight branded splash-to-skeleton sequence (not a second, separate spinner screen).
- Pull-to-refresh: wrap scrollable screens in `RefreshIndicator`; on refresh, prefer re-fetching into a secondary "refreshing" flag that dims/holds existing content rather than remounting the skeleton, wherever the data shape allows it.

---

## 11. Motion Guidelines

| Interaction | Treatment |
|---|---|
| Skeleton shimmer | ~1.2s linear loop, subtle opacity/gradient sweep |
| Screen transitions | ~200–250ms, `easeOutCubic`, shared-axis/fade-through |
| Map zone selection | Scale/elevate selected zone ~150ms |
| Rover movement | Position `Tween` animated along path points, ~2–4s per segment, `easeInOut` |
| Sensor value change | Animated number/tween transition, ~300ms |
| Chat message appearance | Slide+fade in, ~200ms, staggered if multiple |
| Scan processing stages | Cross-fade between stage labels, ~400ms each |

No infinite/ambient animation outside of active loading or live-status indicators — the app must read as calm at rest (PRD §8.3).

---

## 12. Field Map Implementation

- Rendered via `CustomPainter` over a `Canvas`, driven by a `FieldMapData` model containing: field boundary polygon (`List<Offset>`), per-zone boundary polygons, scan-point coordinates, and the rover's path polyline — all currently sourced from mock data but shaped identically to how real GPS-derived polygons/paths would arrive later.
- Moisture heat-map achieved by filling each zone polygon with a color interpolated from the moisture-category token (not a raw gradient across the whole field).
- `InteractiveViewer` wraps the painter for pan/zoom; a "reset view" control resets its `TransformationController`.
- Zone tap-hit-testing via `Path.contains()` against each zone polygon.
- Rover marker: a distinctly-shaped custom marker (not a generic map pin) animated along the path polyline using an `AnimationController`-driven `Tween<Offset>`.
- Layer toggles are local `StateProvider<Set<MapLayer>>` controlling which optional canvas layers paint (path, scan points, crop-health overlay, coverage shading) — the boundary/zone layer is always on.

---

## 13. Camera / ML Analysis Flow (stubbed for v1)

- `camera` plugin wired for real preview + capture; captured image handed to a `CropAnalysisController`.
- Controller runs a fake staged pipeline via sequential `Future.delayed` steps mapped to PRD §6.7's five stages, updating an enum `AnalysisStage` that the UI observes to update the "Analyzing crop…" label/progress.
- Final stage resolves to a mocked `CropScan` result (drawn from seed data, not randomly generated per PRD §31's "realistic, not random placeholder" requirement) and navigates to the Crop Analysis screen.
- This shape is intentionally identical to what a real on-device/cloud ML call will look like later — only the internals of the final stage change (fake delay+seed-result → real inference call).

---

## 14. Cross-Cutting Technical Requirements

### 14.1 Offline & Connectivity
- `connectivity_plus` feeds a `connectivityStatusProvider` (`StreamProvider<ConnectivityResult>`).
- A single global, non-blocking banner widget (mounted once above the shell route) reads this provider and shows "Offline — showing latest synced data" or "Synced just now" (auto-dismissing/quiet when synced). It never intercepts touch input to underlying content.
- A `lastSyncedAt` timestamp is tracked per major data domain to back the "synced just now" copy realistically.

### 14.2 Accessibility
- All interactive targets ≥ 48×48dp.
- Color contrast validated against WCAG AA at minimum for text/background pairs, with extra headroom for outdoor glare scenarios.
- `Semantics` labels on icon-only controls, map zones, and status badges.
- Severity/status always rendered with an explicit text label alongside color (enforced at the `StatusBadge`/`AlertBanner` component level so it can't be omitted screen-by-screen).

### 14.3 Responsive Design
- No fixed pixel dimensions for layout containers; use `LayoutBuilder`, `Flexible`/`Expanded`, and responsive breakpoints (compact/phone vs. medium/tablet) centralized in a `core/utils/breakpoints.dart` helper.
- Field map and charts must reflow (not just scale) at tablet widths — e.g., master-detail layout for Field + Zone Detail on wide screens is an acceptable enhancement, not required for v1 but the layout should not visually break if attempted.

### 14.4 Error Handling
- Repository calls that fail (simulated via an injectable failure flag in mock repositories for testing) surface as `AsyncValue.error`.
- The shared `ErrorState` widget standardizes copy pattern: short headline + one-line explanation + retry action — never a raw exception string or stack trace shown to the user.

---

## 15. Testing Strategy

- **Unit tests:** mock repositories (`mocktail`) verifying controllers correctly map repository results into `AsyncValue` states, including simulated failure paths.
- **Widget tests:** key shared components (`AlertBanner`, `StatusBadge`, `SkeletonLoader`, `EmptyState`, `ErrorState`, `ZoneMap` hit-testing) render and interact correctly in isolation.
- **Golden tests (optional, recommended):** Home, Field Map, and Zone Detail screens, to guard the visual system against regressions given how central "not looking AI-generated" is to this product's bar.

---

## 16. Dependencies (indicative `pubspec.yaml` additions)

```yaml
dependencies:
  flutter_riverpod: ^2.x
  go_router: ^14.x
  fl_chart: ^0.x
  camera: ^0.x
  connectivity_plus: ^6.x
  flutter_svg: ^2.x
  intl: ^0.x

dev_dependencies:
  flutter_lints: ^4.x
  mocktail: ^1.x
  golden_toolkit: ^0.x   # optional
```//placeholder — pin exact versions at implementation time against current pub.dev releases.

---

## 17. Firebase Migration Plan (future phase, not built now)

1. Implement `FirebaseXRepository` classes in a new `data/firebase/` directory, one per existing interface — no interface changes required if domain models were kept backend-agnostic (§5–6).
2. Suggested Firestore collection shape mirrors the domain models directly: `farms/{farmId}`, `farms/{farmId}/zones/{zoneId}`, `farms/{farmId}/zones/{zoneId}/readings/{readingId}`, `rovers/{roverId}`, `rovers/{roverId}/missions/{missionId}`, `zones/{zoneId}/cropScans/{scanId}`, `irrigationEvents/{eventId}`, `notifications/{userId}/items/{id}`.
3. Replace `AsyncNotifier` one-shot fetches with `StreamProvider`s backed by Firestore snapshots where live-updating data is desired (rover status, sensor readings) — the `AsyncValue` consumption pattern in the UI does not change.
4. Replace `MockAuthRepository` with `FirebaseAuthRepository`; OTP screen swaps mock verification for `PhoneAuthProvider` flow; UI unchanged.
5. Swap DI overrides at the composition root (`app.dart` / `ProviderScope`) — this is the only place that should need to change to complete the migration for a given repository.
6. Add Firebase Storage-backed image upload for crop scans, replacing the mock local asset path in `CropScan.imageUrl`.

---

## 18. Build & Environment

- Flutter stable channel, targeting current Android/iOS minimum SDKs at time of implementation.
- Lint: `flutter_lints`, zero-warning baseline before merge.
- No platform-specific hardcoded dimensions; test on at least one small phone, one large phone, and one tablet simulator/emulator profile before sign-off.

## 19. Naming Conventions
- Files: `snake_case.dart`. Classes: `UpperCamelCase`. Providers: `camelCaseProvider`. Mock repositories prefixed `Mock`; interfaces have no prefix/suffix (`ZoneRepository`, not `IZoneRepository`).
- Widgets in `widgets/` must have zero dependency on any specific screen — if a widget needs screen-specific logic, it belongs in `features/`, not `widgets/`.