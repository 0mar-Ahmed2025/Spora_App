# Maya Core Mobile Application

Flutter mobile app for the Maya platform. It integrates with Maya Core APIs and covers authentication, MFA, dashboard, profile, and settings.

## Tech Stack

- **Flutter:** 3.41.9
- **Dart:** 3.11.5
- **State management:** Bloc / Cubit
- **Networking:** Dio
- **Navigation:** GoRouter
- **Storage:** flutter_secure_storage, shared_preferences
- **UI:** flutter_screenutil, easy_localization

## Project Structure

```
lib/
├── core/
│   ├── cache/
│   ├── config/
│   ├── network/
│   └── routing/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── profile/
│   ├── settings/
│   └── splash/
└── main.dart
```

## Setup

### 1. Environment variables

Copy the example file and adjust values if needed:

```bash
cp .env.example .env
```

| Variable | Description |
|----------|-------------|
| `BASE_URL` | Maya API base URL (must end with `/`) |
| `MFA_RESEND_ENABLED` | Set to `true` when backend supports `auth/mfa/resend` |
| `REGISTER_ENABLED` | Set to `true` when backend supports registration |

> **Note:** `.env` is gitignored. Never commit secrets or production tokens.

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

### 4. Run tests

```bash
flutter test
```

Tests cover auth redirect rules (Login → MFA without access token), login/MFA/logout session handling, reset password, and model parsing.

## Implemented Features

- **Authentication:** Login, MFA verification, logout, session restore
- **Reset password:** Forgot-password API integration (`auth/password/forgot`)
- **Dashboard:** Profile summary and quick actions
- **Profile:** View/update profile fields and upload profile image (upload-url → upload → commit)
- **Settings & Security:** Change password, MFA setup/disable, theme, language, logout

## Backend Limitations

Some endpoints are prepared in the app but disabled until the backend enables them:

| Feature | Status | How to enable |
|---------|--------|---------------|
| **Register** | Removed from UI | Set `REGISTER_ENABLED=true` and re-add register flow when API is ready |
| **Resend MFA OTP** | UI hidden; API wired | Set `MFA_RESEND_ENABLED=true` in `.env` |

When resend is disabled, the MFA screen shows: *"Resend code is not available yet."*

## Auth Flow

```
Splash → Login
           ├─ MFA required → MFA Screen → Dashboard
           └─ Direct login ──────────────→ Dashboard
Dashboard → Logout → Login
```

The router treats Login, Splash, MFA, and Reset Password as public routes so MFA works before an access token exists.

## Out of Scope

- Tours, bookings, payments, loyalty
- Push notifications and chat
- Admin panels and analytics widgets
