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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA8v5gthSBoSNPa_GZ1hZlYWY7vpZCDCbA',
    appId: '1:250405337714:web:b9a1f854d98417d067e0eb',
    messagingSenderId: '250405337714',
    projectId: 'tugas-akhir-3c0d9',
    authDomain: 'tugas-akhir-3c0d9.firebaseapp.com',
    databaseURL:
        'https://tugas-akhir-3c0d9-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-akhir-3c0d9.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9cMliTs9G41vgRLcjS2VacvtMWWR1doQ',
    appId: '1:250405337714:android:4f62a7076344f74367e0eb',
    messagingSenderId: '250405337714',
    projectId: 'tugas-akhir-3c0d9',
    databaseURL:
        'https://tugas-akhir-3c0d9-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-akhir-3c0d9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBCWj9mSPTC_XvKr9oFlbdw_nC5Ggbid0M',
    appId: '1:250405337714:ios:2c5c20a15663e29667e0eb',
    messagingSenderId: '250405337714',
    projectId: 'tugas-akhir-3c0d9',
    databaseURL:
        'https://tugas-akhir-3c0d9-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-akhir-3c0d9.appspot.com',
    iosBundleId: 'com.example.tugasAkhir',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBCWj9mSPTC_XvKr9oFlbdw_nC5Ggbid0M',
    appId: '1:250405337714:ios:b3a8d0ab7987a4ff67e0eb',
    messagingSenderId: '250405337714',
    projectId: 'tugas-akhir-3c0d9',
    databaseURL:
        'https://tugas-akhir-3c0d9-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-akhir-3c0d9.appspot.com',
    iosBundleId: 'com.example.tugasAkhir.RunnerTests',
  );
}
