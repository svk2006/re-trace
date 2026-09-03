# RE:TRACE

RE:TRACE is a daily recovery pacing app built with Flutter and Node.js. It helps people recovering from concussions and cognitive fatigue track their energy, spot personal patterns, and structure their day without rigid timelines.

Most health trackers assume you are trying to maximize output or hit daily streaks. RE:TRACE does the opposite: it helps you notice when your fatigue is creeping up so you can pull back before symptoms flare.

> **Disclaimer:** RE:TRACE is a reflection and pacing tool, not a medical device. It does not diagnose head injuries, prescribe treatments, or clear anyone for sports or work.

---

## Why this exists

Recovering from a concussion or neurological fatigue is rarely linear. One day you feel fine reading for two hours; the next day, twenty minutes on a laptop triggers a headache. 

Standard calendar and task apps push you to push through. RE:TRACE helps you budget your cognitive load:
- You log how you feel across energy, focus, fatigue, and physical discomfort.
- The app evaluates your capacity based on your recent inputs.
- If your fatigue is high, it automatically offers to soften your afternoon plan (e.g. shortening focus windows, adding quiet pauses).
- You can chat with TRACE, an AI companion designed specifically around pacing language and cognitive rest.

---

## Core features

### Daily check-in
A slider-based check-in that takes under 30 seconds. You record your mood, energy, fatigue, cognitive load, discomfort, and specific symptoms like light sensitivity or brain fog. Your scores update your capacity ring and symptom overview in real time.

### Flexible day planning
Plan out your day by morning, afternoon, and evening blocks:
- Add custom routines, recovery sessions, and study blocks.
- Check off items as you go or delete tasks with a swipe.
- One-tap plan softener: adjusts demanding tasks into lighter alternatives when your energy dips.
- Reset to baseline anytime if your schedule changes.

### TRACE assistant
A dedicated pacing assistant powered by Gemini 1.5 Flash:
- Built with a clean chat interface and a swipe-up drawer for quick prompts and plan actions.
- Ephemeral on-screen chat for privacy and a clean slate each session.
- Secure local transcript memory passed to the AI in the background, so TRACE remembers your symptom context without cluttering your screen.
- Hardened system prompt that rejects medical diagnosis requests and steers users toward gentle rest or professional care.

### Local background reminders
Configurable daily push notifications to remind you to log your recovery. Built with native Android channels, timezone-aware duration math, and battery-optimization fallbacks.

### Accessibility and low-stimulation modes
- Dark, light, and system themes.
- Reduced motion toggle: replaces spring animations with gentle opacity fades.
- Low-stimulation mode: strips away high-contrast glows and pulsating elements for screen-sensitive days.
- Non-jarring haptic feedback toggles.

---

## Architecture

```
re-trace/
├── lib/
│   ├── app.dart                  # App shell, routing & theme coordination
│   ├── main.dart                 # App entry point & storage hydration
│   ├── screens/                  # Feature views (Home, Plan, Recovery, Trace, etc.)
│   ├── services/                 # Local notifications & device services
│   ├── state/                    # AppSessionController with SharedPreferences persistence
│   └── theme/                    # Color palette, dark mode & motion curves
├── app_core/                     # Shared Dart domain models & recovery intelligence rules
├── my-backend/                   # Serverless TypeScript backend (Vercel)
│   ├── api/index.ts              # Authenticated chat & check-in endpoints
│   └── test/api.test.ts          # Backend test suite
└── .github/workflows/ci.yml      # CI/CD pipeline (tests, analysis, APK artifact build)
```

---

## Tech stack

- **Frontend:** Flutter 3 (Dart 3)
- **Local persistence:** `shared_preferences`
- **Notifications:** `flutter_local_notifications` with `timezone`
- **Backend:** Node.js 20, Express, TypeScript running on Vercel Serverless
- **AI model:** Google Gemini 1.5 Flash via `@google/generative-ai`
- **CI/CD:** GitHub Actions building and signing release APKs

---

## Security and privacy choices

During development, the backend and client were audited for common mobile and serverless weaknesses:
- **Fail-closed authentication:** Backend routes verify an `X-Client-Secret` header using constant-time comparisons (`crypto.timingSafeEqual`) to prevent timing side-channel attacks.
- **Log hygiene:** Request headers and auth tokens are stripped from server logs. Each request gets a unique `crypto.randomUUID()` for tracing errors without leaking payloads.
- **On-device state:** Check-in history, user profile name, and chat transcripts stay on your device unless explicitly sent to the AI endpoint for context.
- **System prompt isolation:** System instructions are separated from user inputs in Gemini API calls to prevent prompt injection overrides.

---

## Getting started

### Prerequisites
- Flutter SDK (3.24.0 or newer recommended)
- Node.js 20+ and npm (for backend development)
- An Android device or emulator with API level 26+

### 1. Clone the repository
```bash
git clone https://github.com/svk2006/re-trace.git
cd re-trace
```

### 2. Run the Flutter app
```bash
flutter pub get
flutter run
```

### 3. Build release APK
To build a release APK locally:
```bash
flutter build apk --release --no-tree-shake-icons
```
The output file will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Running the backend locally

```bash
cd my-backend
npm install
npm test
```

To run the local development server:
```bash
export GEMINI_API_KEY="your-gemini-api-key"
export CLIENT_SECRET="re-trace-hackathon-2026"
npx ts-node api/index.ts
```

---

## Automated CI/CD

Every push to the `main` branch runs our automated GitHub Actions workflow:
1. Runs `flutter analyze` and unit/widget test suites.
2. Audits npm dependencies and runs backend TypeScript checks.
3. Compiles the release Android APK and uploads it as a downloadable zip artifact directly to the GitHub Actions run.
