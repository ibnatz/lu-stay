import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'services/firebase_config_service.dart';

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

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: FirebaseConfigService.apiKey,
    appId: FirebaseConfigService.androidAppId,
    messagingSenderId: FirebaseConfigService.messagingSenderId,
    projectId: FirebaseConfigService.projectId,
    authDomain: FirebaseConfigService.authDomain,
    storageBucket: FirebaseConfigService.storageBucket,
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: FirebaseConfigService.apiKey,
    appId: FirebaseConfigService.androidAppId,
    messagingSenderId: FirebaseConfigService.messagingSenderId,
    projectId: FirebaseConfigService.projectId,
    storageBucket: FirebaseConfigService.storageBucket,
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: FirebaseConfigService.apiKey,
    appId: FirebaseConfigService.iosAppId,
    messagingSenderId: FirebaseConfigService.messagingSenderId,
    projectId: FirebaseConfigService.projectId,
    storageBucket: FirebaseConfigService.storageBucket,
    iosBundleId: 'com.example.accom_project',
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: FirebaseConfigService.apiKey,
    appId: FirebaseConfigService.iosAppId,
    messagingSenderId: FirebaseConfigService.messagingSenderId,
    projectId: FirebaseConfigService.projectId,
    storageBucket: FirebaseConfigService.storageBucket,
    iosBundleId: 'com.example.accom_project',
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: FirebaseConfigService.apiKey,
    appId: FirebaseConfigService.androidAppId,
    messagingSenderId: FirebaseConfigService.messagingSenderId,
    projectId: FirebaseConfigService.projectId,
    authDomain: FirebaseConfigService.authDomain,
    storageBucket: FirebaseConfigService.storageBucket,
  );
}