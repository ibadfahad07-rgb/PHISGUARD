# Local setup

Use Flutter with Dart 3.13.1 or later, matching `pubspec.yaml`, and the Android SDK required by `android/app/build.gradle.kts`.

1. Run `flutter pub get` to install dependencies and regenerate local Flutter files.
2. Configure your own Firebase project with FlutterFire (`flutterfire configure`). This app requires `lib/firebase_options.dart`, `android/app/google-services.json`, and, for iOS, `ios/Runner/GoogleService-Info.plist`. These files are intentionally ignored.
3. Enable Google sign-in in Firebase Authentication and register your local signing certificate fingerprints. Configure the iOS Google sign-in URL scheme for your own Firebase app if targeting iOS.
4. Create a Cloud Firestore database. Restrict access to each user's own documents in the `scans` collection using the `userId` field; a client-side query is not an access control rule. The history query may require a composite index on `userId` and `timestamp`.
5. Run `flutter run` with a connected device or emulator.

Android release signing uses a local `android/key.properties` file with `storeFile`, `storePassword`, `keyAlias`, and `keyPassword`. Supply your own keystore for release builds. Keep all signing files and passwords private.

The source uses local heuristics to flag suspicious links and email text; results are not a guarantee that content is safe. Firebase configuration, database rules, signing material, and generated build files are not included. iOS and a clean build from this source have not been verified.
