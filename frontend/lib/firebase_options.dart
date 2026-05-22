import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default Firebase options for this app.
///
/// This project currently includes Firebase configuration for Android
/// (`android/app/google-services.json`). Desktop platforms like Windows require
/// passing explicit options to `Firebase.initializeApp()`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase options have not been configured for web in this project.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase options have not been configured for this platform.',
        );
    }
  }

  // Values sourced from android/app/google-services.json.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDHczC6Jb3uzuuQmIeaIuUU1UtGe79ClM',
    appId: '1:320744151591:android:5ef128b141259572ad4c02',
    messagingSenderId: '320744151591',
    projectId: 'matcha-recipes',
    storageBucket: 'matcha-recipes.firebasestorage.app',
  );

  // Desktop builds require explicit options; using the same Firebase project.
  // If you later run `flutterfire configure` with Windows enabled, you can
  // replace this with the generated Windows app configuration.
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCDHczC6Jb3uzuuQmIeaIuUU1UtGe79ClM',
    appId: '1:320744151591:android:5ef128b141259572ad4c02',
    messagingSenderId: '320744151591',
    projectId: 'matcha-recipes',
    storageBucket: 'matcha-recipes.firebasestorage.app',
  );
}
