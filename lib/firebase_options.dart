import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'config/api_keys.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: ApiKeys.firebaseWebApiKey,
    authDomain: "${ApiKeys.projectId}.firebaseapp.com",
    projectId: ApiKeys.projectId,
    storageBucket: ApiKeys.storageBucket,
    messagingSenderId: ApiKeys.messagingSenderId,
    appId: ApiKeys.appId,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: ApiKeys.firebaseAndroidApiKey,
    appId: ApiKeys.androidAppId,
    messagingSenderId: ApiKeys.messagingSenderId,
    projectId: ApiKeys.projectId,
    storageBucket: ApiKeys.storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YOUR_API_KEY",
    appId: "YOUR_APP_ID",
    messagingSenderId: "YOUR_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    iosBundleId: "com.example.yourApp", // change this
  );
}