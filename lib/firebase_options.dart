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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA9HnhQ8CGqBJoeW2ITt18hlr6E1H2rwOo',
    appId: '1:752448966296:web:b348617f02bf66ce060aed',
    messagingSenderId: '752448966296',
    projectId: 'rideshared-8e7be',
    authDomain: 'rideshared-8e7be.firebaseapp.com',
    storageBucket: 'rideshared-8e7be.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVgpFI90VjmtFYXO_BG14vg-BwyzCVWok',
    appId: '1:752448966296:android:e8b9d9336d14b920060aed',
    messagingSenderId: '752448966296',
    projectId: 'rideshared-8e7be',
    storageBucket: 'rideshared-8e7be.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDNB2UkfCXMrDfUVZizTPVjlCxEd6uLuU',
    appId: '1:752448966296:ios:01e780604dc7497a060aed',
    messagingSenderId: '752448966296',
    projectId: 'rideshared-8e7be',
    storageBucket: 'rideshared-8e7be.firebasestorage.app',
    iosBundleId: 'com.example.rideApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBDNB2UkfCXMrDfUVZizTPVjlCxEd6uLuU',
    appId: '1:752448966296:ios:01e780604dc7497a060aed',
    messagingSenderId: '752448966296',
    projectId: 'rideshared-8e7be',
    storageBucket: 'rideshared-8e7be.firebasestorage.app',
    iosBundleId: 'com.example.rideApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA9HnhQ8CGqBJoeW2ITt18hlr6E1H2rwOo',
    appId: '1:752448966296:web:66f3cea6f67411a4060aed',
    messagingSenderId: '752448966296',
    projectId: 'rideshared-8e7be',
    authDomain: 'rideshared-8e7be.firebaseapp.com',
    storageBucket: 'rideshared-8e7be.firebasestorage.app',
  );

}