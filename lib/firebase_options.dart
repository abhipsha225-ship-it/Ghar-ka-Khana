import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDrxyo2AI-YyrwOHr4ztmwrtglkZjD198Y',
    appId: '1:439972950266:web:419238043f6be8ddd45943',
    messagingSenderId: '439972950266',
    projectId: 'cloud-hehe-app',
    authDomain: 'cloud-hehe-app.firebaseapp.com',
    storageBucket: 'cloud-hehe-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrxyo2AI-YyrwOHr4ztmwrtglkZjD198Y',
    appId: '1:439972950266:web:419238043f6be8ddd45943',
    messagingSenderId: '439972950266',
    projectId: 'cloud-hehe-app',
    storageBucket: 'cloud-hehe-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrxyo2AI-YyrwOHr4ztmwrtglkZjD198Y',
    appId: '1:439972950266:web:419238043f6be8ddd45943',
    messagingSenderId: '439972950266',
    projectId: 'cloud-hehe-app',
    storageBucket: 'cloud-hehe-app.firebasestorage.app',
  );
}