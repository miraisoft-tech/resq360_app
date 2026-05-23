# resq360

The ResQ360 Mobile App

- FLUTTER / FVM
    - fvm use 3.38.4
    - fvm flutter pub get

- GENERATE ASSETS 
    - flutter pub global activate flutter_asset_generator
    - fgen -o 'lib/gen/assets.dart' -n AppAssets 

- ENV
    - request keys.json
    - build android:fvm flutter build apk --dart-define-from-file=keys.json || fvmflutter build aab --dart-define-from-file=keys.json
    - build ios: fvm flutter build aab --dart-define-from-file=keys.json

- ARCHITECTURE

    ResQ360 is a dual-persona on-demand service marketplace (Customer ↔ Provider) built with Flutter and BLoC state management.

    ```
    lib/
    ├── main.dart                  # App entry, Firebase init, global BLoC providers
    ├── core/
    │   ├── bloc/                  # Shared BLoCs (auth, booking, wallet, KYC,service catalog) 
    │   ├── models/                # Shared data models & API response wrappers
    │   ├── navigation/            # GoRouter-style navigator & deep-link handling
    │   ├── services/              # Dio BaseAPI, socket chat, push notifications, biometrics, uploads
    │   ├── theme/                 # Light/dark theming via ThemeCubit
    │   ├── extensions/            # Dart extension helpers
    │   └── utils/                 # Build config, env vars, general utilities
    ├── features/
    │   ├── customer/              # Customer-facing flows
    │   │   ├── authentication/    # Customer sign-up / sign-in BLoC + screens
    │   │   ├── dashboard/         # Home, providers list, promotions, ads, payments, service requests
    │   │   ├── bookings/          # Booking lifecycle (create → track → complete)
    │   │   └── services/          # Service browsing & details
    │   ├── provider/              # Provider-facing flows
    │   │   ├── authentication/    # Provider onboarding & auth
    │   │   ├── dashboard/         # Stats, ongoing jobs, earnings
    │   │   ├── bookings/          # Incoming & active service jobs
    │   │   └── open_pings/        # Real-time job broadcast listener
    │   ├── chat/                  # Socket-based messaging (shared)
    │   ├── settings/              # Profile, bank, gallery, ratings, notification prefs
    │   ├── intro/                 # Splash, onboarding, account-type selection
    │   └── widgets/               # Cross-feature reusable UI components
    ├── gen/                       # Generated asset constants (fgen)
    └── i18n/                      # Slang-based localization
    ```

    **Key patterns:**
    - Feature-first folder structure; each feature owns its BLoC, data layer, and UI.
    - Dio-based networking via `BaseAPI` with environment-aware base URLs (`keys.json` dart-defines).
    - Firebase for auth session, push notifications, and analytics.
    - Real-time chat over WebSocket (`chat_socket_service`).
    - Shared `AuthBloc` registered in a global `BlocRegistry` for cross-feature access.