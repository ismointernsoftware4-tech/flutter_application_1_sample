// File generated using FlutterFire CLI or manually configured
// To generate this file automatically, run: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyBilMLMqANdLCWuBZbdWK1qX_Bz2FW0ssE',
    appId: '1:133896252036:web:dc2d16e2c6410ec47370d1',
    messagingSenderId: '133896252036',
    projectId: 'inventory-3aeaf',
    authDomain: 'inventory-3aeaf.firebaseapp.com',
    storageBucket: 'inventory-3aeaf.firebasestorage.app',
    measurementId: 'G-0W55K46J1Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC3KRT0FUnRJGsPbNjKpa-hBA0wRO8ESok',
    appId: '1:133896252036:android:d5fc7b261e95a5ba7370d1',
    messagingSenderId: '133896252036',
    projectId: 'inventory-3aeaf',
    storageBucket: 'inventory-3aeaf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCeEnsvErgo0zHy9OUKpZ8ui06Flne8ksE',
    appId: '1:133896252036:ios:a0643036c7cd691c7370d1',
    messagingSenderId: '133896252036',
    projectId: 'inventory-3aeaf',
    storageBucket: 'inventory-3aeaf.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1Sample',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCeEnsvErgo0zHy9OUKpZ8ui06Flne8ksE',
    appId: '1:133896252036:ios:a0643036c7cd691c7370d1',
    messagingSenderId: '133896252036',
    projectId: 'inventory-3aeaf',
    storageBucket: 'inventory-3aeaf.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1Sample',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBilMLMqANdLCWuBZbdWK1qX_Bz2FW0ssE',
    appId: '1:133896252036:web:d73b085f2ab714657370d1',
    messagingSenderId: '133896252036',
    projectId: 'inventory-3aeaf',
    authDomain: 'inventory-3aeaf.firebaseapp.com',
    storageBucket: 'inventory-3aeaf.firebasestorage.app',
    measurementId: 'G-K4CG4JE75C',
  );

}

