import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCsFbf_qcSoYETa2w5xHG9oCjPermyjLrE',
    appId: '1:690610011940:web:315606c0601b6dea413db1',
    messagingSenderId: '690610011940',
    projectId: 'public-issue-reporting-f7fe9',
    authDomain: 'public-issue-reporting-f7fe9.firebaseapp.com',
    storageBucket: 'public-issue-reporting-f7fe9.firebasestorage.app',
    measurementId: 'G-Z8027SGKLG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCsFbf_qcSoYETa2w5xHG9oCjPermyjLrE',
    appId: '1:690610011940:web:315606c0601b6dea413db1',
    messagingSenderId: '690610011940',
    projectId: 'public-issue-reporting-f7fe9',
    storageBucket: 'public-issue-reporting-f7fe9.firebasestorage.app',
  );
}