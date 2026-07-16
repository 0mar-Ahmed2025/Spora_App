# Maya Core Mobile Application

This is the initial mobile application interface for the Maya platform using Flutter. It integrates with the existing Maya Core APIs and provides the main account-management features.

## Tech Stack

* **Flutter Version:** (3.41.9)
* **Dart Version:** (3.11.5)
* **State Management:** Bloc and Cubit
* **Main Dependencies:**
  * `flutter_bloc`
  * `flutter_screenutil`
  * `easy_localization`
  * `shared_preferences` / `flutter_secure_storage`
  * `dio`

## Project Structure

The project follows a feature-based architecture to ensure organization and scalability:

    lib/
    ├── app/
    │   ├── app.dart
    │   ├── router/
    │   └── theme/
    ├── core/
    │   ├── api/
    │   ├── errors/
    │   ├── storage/
    │   ├── widgets/
    │   └── utilities/
    ├── features/
    │   ├── authentication/
    │   ├── dashboard/
    │   ├── profile/
    │   ├── profile_image/
    │   ├── mfa/
    │   └── settings/
    └── main.dart

## Configuration and Setup

### API Base URL Configuration
The API base URL is environment-based and is not hard-coded inside screens or widgets. Configure the Base URL inside your environment variables (`.env` file) or directly within the centralized `ApiHelper` class located in `lib/core/api/`.

### How to Run the Project
1. Clone the repository to your local machine.
2. Navigate to the project directory and fetch dependencies:
   ```bash
   flutter pub get
3. Run the application on a connected device or emulator:
    flutter run

## Implemented Features and API Integration
- A reusable API layer was created for communication with Maya Core, handling authentication headers, token injection, and centralized error parsing. The following features are implemented:

- Authentication: Splash screen, Login with email/username and password, secure token storage, and session restoration.

- MFA Verification: Handling backend MFA challenges, verification code input, and returning to login on session expiry.

- Dashboard: Main authenticated screen displaying user greeting, profile image, account status summary, and quick access to settings.

- Profile Management: View and edit supported profile fields (Full name, Email, Phone number, Username), with backend validation.

- Profile Image: Display current image, pick from the device gallery, preview, and upload using the backend flow.

- Settings & Security: Edit personal info, change password, manage MFA status, UI Theme preference, Language selection, and Logout.

### Known Limitations and Backend Features
Local Preferences: Application settings that are not currently supported by the backend (such as Theme and Language preferences) are implemented as local UI preferences using local storage, strictly separated from server-side account settings.

MFA Simulation: The application does not simulate MFA locally or bypass verification; it strictly follows the existing backend responses.

Dashboard Scope: The dashboard is a simple entry point. Analytics, charts, booking information, and payment widgets are omitted in this version.

### Out of Scope
The following features and services are intentionally excluded from this implementation:

- Tours and Tour search

- Booking, Orders, and Payments

- Loyalty points and Gift cards

- CRM and CMS Admin panels

- Push notifications and Chat

- Advanced analytics