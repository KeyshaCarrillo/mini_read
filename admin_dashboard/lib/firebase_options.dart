// File generated from the Mini Read Firebase project configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase is configured for web only here.');
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_RjWf8krvaQVQJrIRnemltD4pXimgPrE',
    appId: '1:404429072054:web:33337a33443edef5076817',
    messagingSenderId: '404429072054',
    projectId: 'readlevelproject-6e5d3',
    authDomain: 'readlevelproject-6e5d3.firebaseapp.com',
    storageBucket: 'readlevelproject-6e5d3.firebasestorage.app',
  );

}