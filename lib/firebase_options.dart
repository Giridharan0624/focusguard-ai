// ┌──────────────────────────────────────────────────────────────────┐
// │  PLACEHOLDER — replace with FlutterFire generated config.      │
// │                                                                │
// │  Run the following to generate the real file:                  │
// │    dart pub global activate flutterfire_cli                    │
// │    flutterfire configure                                       │
// └──────────────────────────────────────────────────────────────────┘

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for ${defaultTargetPlatform.name}',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8Iz5OaK0kkQyQZvvg5Q4Npk2TCRUfbOg',
    appId: '1:379452324930:android:c0ae252416361a312f01db',
    messagingSenderId: '379452324930',
    projectId: 'focusguard-ai-eb6e2',
    storageBucket: 'focusguard-ai-eb6e2.firebasestorage.app',
  );

  // TODO: Replace these with your actual Firebase project values

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-API-KEY',
    appId: 'YOUR-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosBundleId: 'com.focusguard.focusguardAi',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR-API-KEY',
    appId: 'YOUR-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    authDomain: 'YOUR-AUTH-DOMAIN',
  );
}