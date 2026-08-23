# Jeevan (जीवन) — Product Requirements Document

**Version:** 1.0 (Mock-Data UI Release)
**Owner:** Product
**Status:** Draft for build
**Platform:** Flutter — Android, iOS (tablet-adaptive)

---

## 1. Overview

### 1.1 What is Jeevan
Jeevan is a mobile application that sits between a farmer, an autonomous agricultural rover, the physical field, and the sensor data the rover collects. The rover scans farmland, measures soil and environmental conditions zone by zone, and Jeevan turns those readings into clear, actionable guidance: where to irrigate, how much water to use, whether crops show signs of stress, and whether the rover itself needs attention.

### 1.2 Vision
*"A farmer should be able to open Jeevan, glance at the screen, and know exactly what needs attention today — without reading a single raw sensor value if they don't want to."*

### 1.3 Problem Statement
Precision-agriculture tooling today tends to be built for agronomists and IoT engineers — dense dashboards, raw telemetry, charts without interpretation. Farmers and field operators need a *decision-making tool*, not a monitoring console. Jeevan's job is to interpret rover and sensor data into recommendations a working farmer can act on in seconds, in bright outdoor light, often with unreliable connectivity.

### 1.4 Release Scope
This release ships the **complete application UI and interaction model on mock/hardcoded data**. No physical rover, live sensors, ML model, or backend exists yet. The product must look and feel finished — not a prototype — and the codebase must be structured so real hardware, Firebase, and an ML model can be plugged in later without UI rework (see TRD).

---

## 2. Goals & Non-Goals

### 2.1 Product Goals
| # | Goal |
|---|------|
| G1 | A user can identify "what needs attention right now" within seconds of opening the app. |
| G2 | Every irrigation and health recommendation is explainable — the user can always see *why*. |
| G3 | The app reads as a considered, professional agriculture product — not a generic AI/admin dashboard. |
| G4 | The codebase cleanly separates UI from data, so swapping mock data for Firebase/live telemetry requires no UI rewrite. |
| G5 | The app remains usable and honest about state when offline or when data is missing/erroring. |

### 2.2 Success Criteria for This Release (v1, mock data)
Since there are no live users yet, "success" is measured as a design/engineering bar rather than an analytics metric:
- Every one of the 21 screens in §6 is implemented, navigable, and uses only data from the repository layer (never inline widget constants).
- Every data-loading screen has a purpose-built skeleton state (no bare spinners) — see §8.1.
- Every screen has a defined empty state and error state where applicable.
- The app is fully navigable and internally consistent on a small phone, a large phone, and a tablet.
- A reviewer unfamiliar with the spec should not be able to tell this is "AI-generated" — visual language should feel deliberate, restrained, and agriculture-specific.

### 2.3 Non-Goals for v1
- No real backend, authentication, or persistence (Firebase is deferred — architecture must anticipate it, see TRD §17).
- No real rover hardware, GPS, or LoRa/GSM connectivity.
- No functioning ML crop-disease model (UI and states only).
- No functioning Jeevan Assistant backend (UI and canned/mock responses only).
- No live weather API.
- No multi-farm or multi-user role management — single farm, single user context for v1.
- No payments, subscriptions, or account tiers.

---

## 3. Target Users

### 3.1 Primary Persona — "The Field Operator"
A farmer or farm employee who is physically present on the land, checking the app between tasks, often in direct sunlight, sometimes with poor signal. They want fast, confident answers, not analysis. They may not be highly technical.

**Needs:** glanceable status, clear next action, large touch targets, outdoor-readable contrast, minimal reading.

### 3.2 Secondary Persona — "The Farm Manager / Agronomist"
Oversees multiple zones or a larger operation, more comfortable digging into trends, water-usage history, and crop-health patterns. Uses Insights and historical filtering more than Home.

**Needs:** trend visibility, comparison across zones/time, defensible recommendations (why irrigate, why flagged).

---

## 4. Brand & Product Principles

**Name treatment:** जीवन / Jeevan — treated as a meaningful word ("life") anchoring an agriculture/life brand, not styled as a tech-startup wordmark.

**Design principles (binding constraints):**
1. Clarity and hierarchy beat decoration. If a card, gradient, icon, or shadow doesn't serve the workflow, cut it.
2. Calm by default, urgent when necessary. The app should feel quiet when the farm is healthy and immediately legible when something needs attention — severity should never rely on color alone (see §8.4, Accessibility).
3. Interpretation over raw telemetry. Every sensor value shown should be accompanied by what it means (e.g., "Very Low — 22%", not just "22%").
4. One idea per screen region. Avoid turning every metric into an identical card; use typography, dividers, and compact tiles to create a real information hierarchy.
5. Explicitly forbidden aesthetic: purple/blue AI gradients, glassmorphism, oversized rounded cards everywhere, neon green, heavy shadows, emoji overuse, generic admin-dashboard grids, redundant floating action buttons, decorative charts, hero illustrations, sci-fi styling.

**The four questions the UI must always be able to answer at a glance:**
- What needs attention?
- Which zone needs water, and why?
- How much water, and is rain coming?
- Is the rover working, and is there a crop-health problem?

---

## 5. Information Architecture

**Primary navigation — bottom tab bar, four destinations:**
1. **Home** — current farm state and priority actions.
2. **Field** — interactive 2D map of the scanned farmland.
3. **Rover** — rover status, mission, battery, connectivity.
4. **Insights** — historical trends and agricultural intelligence.

**Persistent secondary entry points:**
- **Ask Jeevan** — contextual entry to the Jeevan Assistant chat (not a floating button on every screen; placed deliberately, e.g. in the app bar or as a single contextual affordance on Home).
- **Profile/Settings** — top-right avatar on primary screens.

Navigation transitions should feel intentional (subtle, directional) rather than default platform fades — see TRD §11 for motion spec.

---

## 6. Feature Requirements by Screen

Each entry below states the user-facing requirement. Implementation detail lives in the TRD.

### 6.1 Splash
- Displays **जीवन / Jeevan** and tagline **"Smart agriculture, one field at a time."**
- Subtle, soil/agriculture-inspired motion; not a heavy animation sequence.
- Transitions into the authentication flow (or Home, if a mock session exists).

### 6.2 Authentication
**Login:** phone/email field, password field, "remember me," login action, "forgot password," "continue with phone," subtle Jeevan branding and background treatment.
**Sign Up:** name, phone, email, password, farm name, location.
**OTP Verification:** six-digit input, countdown timer, resend action, error state (wrong code), loading state (verifying).
**Forgot / Reset Password:** production-quality flow, mocked outcome.
All authentication screens must feel finished even though the backend is mocked — no "TODO" placeholders visible to the user.

### 6.3 Home
Answers "what's happening in my field right now?"
- Personalized greeting (time-of-day aware) and a one-line farm status summary (e.g., "Your farm is looking stable today.").
- Compact farm identity block: farm name, acreage, active zone count, rover connection state.
- Field Status section: soil moisture, water availability, rain probability, rover status — presented as an integrated status read, not four identical cards.
- **Alerts** section (P0): irrigation-needed, rain-expected (delay irrigation), rover-needs-charging, crop-health-issue. Each alert carries a severity, a short explanation, and a direct action (e.g., "View field"). See §6.16 for severity model.
- Farm Overview: acreage, zone count, average soil moisture, water used today — mixed typography/dividers/tiles, not a card grid.

### 6.4 Field Map (core feature)
An interactive 2D representation of the farm as scanned by the rover — not a real GIS map.
- Irregular field boundary and internal zone boundaries that read as real farmland geometry, not rectangles.
- Zones (A–D for v1) each communicate soil moisture via a heat-map treatment plus an explicit label (e.g., "Zone A · Very Low · 22%") — never color alone.
- Shows rover scan path, current rover location, and sensor scan points.
- Legend: Dry / Moderate / Healthy / Wet.
- Interactions: pan, zoom, tap-to-open zone detail, reset view, toggle layers.
- **Layer selector:** Soil Moisture, Rover Path, Water Zones, Crop Health, Scan Coverage.

### 6.5 Zone Details
Opened by tapping a zone on the map.
- Headline status (e.g., "Very Low Soil Moisture — 22%") and a plain-language recommendation.
- Full sensor reading list: soil moisture, soil temperature, air temperature, humidity, rain, light intensity, water level, pH, EC, flow rate — shown as an elegant list/hierarchy, not one card per reading.
- **Irrigation recommendation block:** current vs. preferred moisture range, rain outlook, water availability, estimated irrigation duration, and an **Irrigate Zone** action (simulates and updates local mock state — no real pump control).
- **Crop Health summary:** latest scan thumbnail, date/time, health status, disease probability, confidence, "View analysis" link into §6.6.

### 6.6 Crop Health Analysis
- Large crop image with optional overlaid detection regions.
- AI/ML analysis panel using hedged, non-absolute language only ("Possible," "Detected," "Likely," "Confidence," "Requires inspection" — never a bare diagnosis presented as fact).
- Indicator list (e.g., leaf discoloration, brown lesions, uneven growth) and a recommended action.
- "Scan again" action, entering the camera flow (§6.7).

### 6.7 Camera / Scan Crop
- Camera preview with capture, gallery-import, flash toggle, cancel.
- Post-capture **"Analyzing crop…"** processing state with a staged sequence (image captured → identifying plant region → examining leaves → comparing visual patterns → generating report) rather than a spinner.
- Resolves into the Crop Health Analysis screen (§6.6) with mock results.

### 6.8 Rover Overview
- Rover identity and live status (e.g., "Scanning").
- Battery, connection, GPS, current zone, current mission, scan coverage %, last sync time, irrigation-system status.
- Simple geometric rover status illustration (no cartoon/mascot art).
- Mission controls: Start Scan, Pause, Return to Base, Resume — destructive/important actions require confirmation.

### 6.9 Rover Mission
- Named mission (e.g., "Morning Field Scan"), status, start time, coverage %.
- Zone sequence (A → B → C → D) with current position highlighted.
- Progress visualization (linear or stepped).
- Chronological activity timeline (e.g., "07:42 Mission started," "07:51 Zone A scanned").

### 6.10 Irrigation Control
- Lists zones needing water now vs. zones already adequately wet.
- Per-zone estimated duration and volume (e.g., "Zone A · 14 min · ~420 L").
- Aggregate total estimate.
- **Start recommended irrigation** action, gated by a confirmation sheet before execution (simulated).

### 6.11 Water Usage
- Water used today / this week / this month, estimated savings, irrigation event log.
- Clean daily bar/line chart (e.g., Mon–Fri volumes) with no decorative chart-junk.

### 6.12 Insights
Organized by theme: **Soil, Water, Crop Health, Rover, Weather.**
- Each section surfaces a small number of genuinely useful, explained insights rather than a wall of charts — e.g., "Zone A is drying faster than the rest of the field," with a one-line explanation ("moisture has fallen 14% faster than neighboring zones over 3 days").

### 6.13 Historical Data
- Date-range filter: Today / 7 days / 30 days.
- Trend views for soil moisture, water usage, temperature, rainfall, and crop-health events, using realistic (not random) mock data.

### 6.14 Notifications
- Chronological list, read/unread state.
- Categories mirror the app's alert types: irrigation needed, scan completed, disease detected, rain detected/auto-pause, rover status.

### 6.15 Jeevan Assistant
- Entry point: a single, deliberate "Ask Jeevan" affordance (not a floating button repeated across every screen).
- Chat header: "Jeevan Assistant" / "Ask about your field."
- Suggested prompts specific to farm context (e.g., "Which zones need water?", "Why is Zone A dry?").
- Responses render as native chat bubbles that can embed structured farm data (e.g., a mini zone-moisture summary plus a "Review irrigation" action) — not a generic chatbot transcript.
- Backend is mocked with canned, context-aware responses for v1.

### 6.16 Alerts & Severity Model
All alerts (Home banners and Notifications) share one severity taxonomy so the system is predictable:
| Severity | Example | Visual + text treatment |
|---|---|---|
| Critical | Crop disease detected, rover offline during active mission | Soft red, explicit label, primary action required |
| Warning | Irrigation recommended, battery low | Muted amber, explicit label, suggested action |
| Informational | Rain expected, scan completed | Muted blue/neutral, no action required |

Severity must always be paired with an explicit text label (e.g., "Very Low," "Critical") — never conveyed by color alone (accessibility requirement, §8.4).

### 6.17 Profile / Settings
- Farm identity, user identity, basic preferences (units, notification toggles).
- Accessed via top-right avatar; not part of the bottom nav.

### 6.18 Empty States
Required for: no crop scans yet, no irrigation history, no rover connected, no notifications, no disease detections, no historical data. Each must explain the next concrete action, not just state absence.

### 6.19 Error States
Required for at least: rover offline ("hasn't synced in 8 minutes" + Retry), field data failed to load (+ Try again). No generic/raw exception text is ever shown to the user.

### 6.20 Offline / Connectivity State
A subtle, persistent (non-dominant) global indicator: "Offline — showing latest synced data" vs. "Synced just now." Must never block interaction with already-loaded content.

---

## 7. Data & Content Requirements

Mock data must be realistic and internally consistent (not random-per-load), and reused consistently across every screen that references it. Canonical v1 zone data:

| Zone | Moisture | Temp | Humidity | Water level | Rain | Status |
|---|---|---|---|---|---|---|
| A | 22% (Very Low) | 28.4°C | 54% | 74% | None | Irrigation recommended |
| B | 48% (Medium) | 27.2°C | 60% | 74% | None | Monitor |
| C | 81% (High) | 26.9°C | 71% | 74% | Detected earlier | No irrigation |
| D | 19% (Very Low) | 29.1°C | 49% | 74% | None | Irrigation recommended |

Farm identity: **Green Valley Farm**, 12.4 acres, 4 active zones, rover **R-01** connected.

---

## 8. Cross-Cutting Requirements

### 8.1 Loading & Skeletons (mandatory, non-negotiable)
No screen may show a bare centered spinner as its primary loading state. Every data-bearing region needs a skeleton that approximately matches its final layout (metric rows, cards, charts, map, rover status, crop-health result, zone details, notifications, profile, activity timeline). Additionally required:
- Branded initial app-loading experience.
- Pull-to-refresh with skeleton or progressive refresh (not a full-screen block).
- Subtle cross-section navigation transitions.
- Partial/progressive refresh over full-screen blocking, wherever feasible.
- Real image placeholders/skeletons (never a broken-image icon while loading).
- A dedicated ML "scanning/analyzing" state (see §6.7) instead of a generic spinner.

### 8.2 Responsiveness
Must work on small and large Android phones, iPhones, and tablets, using flexible/adaptive layout primitives rather than fixed dimensions.

### 8.3 Motion
Subtle and purposeful only: skeleton shimmer, screen transitions, map zone selection, rover movement, sensor-value changes, progress indicators, chat message appearance, scan processing. The app should feel calm, not constantly animated.

### 8.4 Accessibility
- Sufficient contrast for outdoor use.
- Minimum comfortable touch target sizes.
- Semantic labels on interactive and status elements.
- Icons paired with text wherever meaning could be ambiguous.
- Status/severity never communicated by color alone — always paired with explicit text (e.g., "Very Low — 19%," "Healthy — 63%").

---

## 9. Explicit Out-of-Scope (v1)
- Firebase / any real backend or persistence.
- Real rover hardware, GPS, LoRa/Wi-Fi/GSM connectivity.
- Real ML crop-disease inference.
- Real Jeevan Assistant backend/LLM connection.
- Live weather API integration.
- Multi-farm, multi-role, or team-account support.
- Push notification delivery (UI/state only).
- Billing/subscriptions.

---

## 10. Future Roadmap (Phase 2+)
1. Firebase integration behind the existing repository interfaces (see TRD §17) — Auth, Firestore, Storage.
2. Live rover telemetry: GPS, battery, connection status, real scan paths replacing mock coordinates.
3. Real-time sensor streams replacing static `SensorReading` mocks.
4. On-device or cloud ML model for crop-disease detection, replacing the mocked analysis pipeline.
5. Jeevan Assistant backend (LLM + farm-data context/RAG).
6. Weather API integration for rain probability and forecasts.
7. Push notifications.
8. Multi-farm / multi-user support, if the business model requires it.

---

## 11. Assumptions & Constraints
- Single farm, single user, single rover for v1.
- All data is mock/hardcoded but must flow through a repository abstraction (never hardcoded directly into widgets) so later phases are additive, not a rewrite.
- Design must hold up under direct sunlight / outdoor viewing conditions.
- No assumption of constant connectivity.

## 12. Risks
| Risk | Mitigation |
|---|---|
| UI reads as a generic AI-generated dashboard despite instructions | Strict adherence to §4 design principles; design review against the "forbidden aesthetic" list before sign-off |
| Mock data hardcoded into widgets, complicating future Firebase swap | Enforce repository-only data access in code review (see TRD §6) |
| Skeleton states treated as an afterthought | Skeleton system is a first-class deliverable per screen (§8.1), not a polish pass |
| Severity/alerts becoming color-only | Accessibility requirement in §8.4 is binding, not optional |