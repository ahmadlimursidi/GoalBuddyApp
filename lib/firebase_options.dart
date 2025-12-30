import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
  
    apiKey: "AIzaSyCU4pbNSLQLH4glCkoIBrxT4NuF2g1_6Ag",
    authDomain: "lkcpcoachcompanion.firebaseapp.com",
    projectId: "lkcpcoachcompanion",
    storageBucket: "lkcpcoachcompanion.firebasestorage.app",
    messagingSenderId: "1004686709332",
    appId: "1:1004686709332:web:1dc9d17fe95f104ea193c1",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "YOUR_API_KEY",
    appId: "YOUR_APP_ID",
    messagingSenderId: "YOUR_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
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