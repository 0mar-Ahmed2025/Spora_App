# Maya Core Mobile Application

Flutter mobile app for the Maya platform. It integrates with Maya Core APIs and covers authentication, MFA, dashboard, profile, settings, and Android device capabilities.

## Tech Stack

- **Flutter:** 3.41.9
- **Dart:** 3.11.5
- **State management:** Bloc / Cubit
- **Networking:** Dio
- **Navigation:** GoRouter
- **Storage:** flutter_secure_storage, shared_preferences, sqflite
- **Localization:** easy_localization
- **UI:** flutter_screenutil

## Project Structure

```text
lib/
├── core/
│   ├── cache/
│   ├── config/
│   ├── network/
│   └── routing/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── device_capabilities/
│   ├── profile/
│   ├── reports/
│   ├── settings/
│   └── splash/
└── main.dart
```

## Setup

### 1. Environment Variables

Copy the example file and adjust values if needed:

```bash
cp .env.example .env
```

| Variable | Description |
|----------|-------------|
| `BASE_URL` | Maya API base URL, must end with `/` |
| `MFA_RESEND_ENABLED` | Set to `true` when backend supports `auth/mfa/resend` |
| `REGISTER_ENABLED` | Set to `true` when backend supports registration |

`.env` is gitignored. Do not commit secrets or production tokens.

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run The App

```bash
flutter run
```

### 4. Verify Locally

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Implemented Features

- **Authentication:** Login, MFA verification, logout, session restore
- **Reset password:** Forgot-password API integration via `auth/password/forgot`
- **Dashboard:** Profile summary, account status, quick actions, and Device Capabilities section
- **Profile:** View/update profile fields and upload profile image
- **Settings & Security:** Change password, MFA setup/disable, theme, language, logout
- **Localization:** English, Arabic, and Persian
- **Device Capabilities:** Camera, gallery, location, external map, file picker, and audio recording

## Device Capabilities

The dashboard includes a separate Device Capabilities section with six actions:

- Open Camera
- Select from Gallery
- Get Current Location
- Open External Map
- Pick a File
- Record Audio

### Packages Added

- **`permission_handler`**: Runtime permission checks, permission requests, and app settings redirection.
- **`image_picker`**: Single-image capture from camera and single-image selection from gallery.
- **`geolocator`**: Location service checks and current location retrieval with timeout handling.
- **`url_launcher`**: Opening current coordinates in an external map app or web fallback.
- **`file_picker`**: Single-file selection for PDF, text, and common image formats.
- **`record`**: Audio recording with start, stop, cancel, and elapsed-time handling.
- **`path_provider`**: App-accessible temporary directory for recorded audio files.
- **`equatable`**: Value equality for Cubit states.
- **`bloc_test`** and **`mocktail`**: Unit tests for Cubit behavior and mocked native-service wrappers.

### Android Permissions

Configured in `android/app/src/main/AndroidManifest.xml`:

- `android.permission.CAMERA`
- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.ACCESS_COARSE_LOCATION`
- `android.permission.RECORD_AUDIO`
- `android.permission.READ_EXTERNAL_STORAGE` with `maxSdkVersion="32"`
- `android.permission.WRITE_EXTERNAL_STORAGE` with `maxSdkVersion="28"`
- `android.permission.READ_MEDIA_IMAGES`
- `android.permission.READ_MEDIA_AUDIO`

The manifest also declares `geo:` and `https:` queries for external map launching.

### Architecture

- Device logic is isolated under `lib/features/device_capabilities/`.
- UI widgets render state and forward user actions.
- `DeviceCapabilitiesCubit` manages loading, success, cancellation, permission-denied, permanently-denied, service-disabled, and error states.
- Native plugin calls are wrapped in services so Cubit behavior can be tested without invoking platform APIs.
- Camera/gallery/file/audio results share a media preview bottom sheet.
- Location results use a dedicated bottom sheet.
- User-visible text is localized across English, Arabic, and Persian.

### Tests

Run:

```bash
flutter test
```

The automated tests cover:

- Permission denied state
- Permission permanently denied state
- Successful location result
- Location service disabled
- Camera cancellation
- File picker cancellation
- Audio recording state transitions
- Error message mapping
- Translation-key parity across English, Arabic, and Persian

### Manual Android Test Checklist

All required manual tests have been performed and verified on a physical device:

- [x] Camera permission request, capture, cancellation, preview, and file metadata.
- [x] Gallery selection, cancellation, preview, and file metadata.
- [x] Location service disabled handling.
- [x] Location permission denied and permanently denied handling.
- [x] Current latitude, longitude, accuracy, and retrieval time display.
- [x] External map opens after a successful location result.
- [x] A clear message appears when opening map before retrieving location.
- [x] PDF, text, and image file selection displays metadata safely.
- [x] Audio recording can start, stop, cancel, and display elapsed time.
- [x] Returning from camera, gallery, settings, file picker, and map keeps the dashboard usable.
- [x] No layout overflow on the tested screen size.

| Item | Value |
|------|-------|
| Flutter | 3.41.9 |
| Dart | 3.11.5 |
| Android compileSdk / targetSdk | 35 / 35 |
| Android minSdk | 21 |
| Tested device / emulator | Poco X3 Pro (M2102J20SG) |
| Tested Android version / API | Android 13 (API 33) |
| Analyze verification | PASSED (`flutter analyze`) |
| Test verification | PASSED (`flutter test`) |
| Build verification | PASSED (`flutter build apk --debug`) |

Screenshots and screen recording are included with the submission.

## Report Queue

A local-first reporting feature. Reports are saved to an on-device SQLite database before any server interaction, so a report is never lost even when the network is down.

### Workflow

1. The user fills the report form (title, description, category, priority, optional image and location) and taps **Save Report** or **Save as Draft**.
2. The report is persisted locally first. A non-draft report is then submitted to the fake remote service.
3. Submission outcome is stored back to the local database:
   - `submitted`: server accepted the report and returned a `serverId`.
   - `failed`: the request failed (offline, timeout, server error, validation error, or missing image file). The report stays in the queue with a retry count.
   - `sending`: transient state while a submission is in flight.
4. The queue screen lists all local reports, lets the user retry failed reports, edit validation-failed reports, delete drafts, and re-sync everything.

### Why SQLite

The feature must work offline-first and survive app restarts. A dedicated SQLite table (`reports`) in `lib/core/database/database_helper.dart` persists every report locally, which:

- keeps reports across app restarts (restored on the next launch);
- prevents data loss on network failure;
- tracks retry counts and last errors per report.

`shelf`/server memory or `shared_preferences` are not used because a structured, queryable, restart-safe store is required.

### Fake Service Modes

The "fake server" is implemented in `fake_report_remote_data_source.dart`. From the queue screen's dropdown you can switch the behaviour of the next submission:

| Mode | Behaviour |
|------|-----------|
| `success` | Returns a synthetic `serverId` |
| `offline` | Throws a network-unavailable failure |
| `timeout` | Waits, then throws a timeout failure |
| `serverError` | Throws a server error failure |
| `validationError` | Throws a validation failure (only retryable after editing) |

Validation failures are deliberately **not** auto-retried by the sync-all action; the user must edit the report first.

### Architecture

- UI: `report_queue_page.dart`, `create_report_page.dart`, `report_details_page.dart`, `edit_report_page.dart`
- State: `report_queue`, `create_report`, `edit_report` cubits
- Domain: `ReportRepositoryImpl` handles save-first, idempotent submission, retry, and duplicate-submission prevention
- Data: `LocalReportDataSourceImpl` (SQLite) + `FakeReportRemoteDataSourceImpl` (fake server modes)
- Localization: all report strings exist in English, Arabic, and Persian

### Report Tests

Run:

```bash
flutter test
```

The report tests live in `test/fakes/features/reports/` and cover:

- Saving a valid report locally and keeping it queued when the server is unreachable
- Restoring reports after repository reinitialization
- Successful submission (server id stored, `submitted` status)
- Network failure → `failed` status with retry count increment
- Retry across repeated submissions
- Duplicate simultaneous submissions are prevented
- Missing image file is handled safely
- Validation failures are not auto-retried by sync
- Sync submits only eligible queued/retryable reports
- Drafts are never auto-submitted
- Queue screen renders reports and exposes a retry action for failed reports
- Translation-key parity for every report feature key in English, Arabic, and Persian

## Known Limitations

- Audio recordings are stored in the app temporary directory and may be cleaned by the OS.
- The latest successful capability result is not persisted after app restart.
- External map opening uses Android intents/URLs and falls back to Google Maps web URL when no `geo:` handler is available.
- Audio playback is not implemented.
- Multi-image gallery selection, image compression, map preview, and diagnostics screen are not implemented.
- * **File Picker & Modern Android Storage**: On Android 13+ (API 33+), file selection uses the system-native Storage Access Framework (SAF). As per Google's official privacy guidelines, implicit read permission is granted upon user selection without requiring legacy runtime `READ_EXTERNAL_STORAGE` dialogs.

## Backend Limitations

Some endpoints are prepared in the app but disabled until the backend enables them:

| Feature | Status | How to enable |
|---------|--------|---------------|
| Register | Removed from UI | Set `REGISTER_ENABLED=true` and re-add register flow when API is ready |
| Resend MFA OTP | UI hidden; API wired | Set `MFA_RESEND_ENABLED=true` in `.env` |

When resend is disabled, the MFA screen shows: `Resend code is not available yet.`

## Auth Flow

```text
Splash -> Login
           ├─ MFA required -> MFA Screen -> Dashboard
           └─ Direct login ---------------> Dashboard
Dashboard -> Logout -> Login
```

The router treats Login, Splash, MFA, and Reset Password as public routes so MFA works before an access token exists.

## Out Of Scope

- Tours, bookings, payments, loyalty
- Push notifications and chat
- Admin panels and analytics widgets
