"""Writes lib/firebase_options.dart for CI builds.

The file is not in the repository. Every value in it also appears in
ios/Runner/GoogleService-Info.plist and android/app/google-services.json,
which are, so CI rebuilds it from those two files.

Run from the repository root: python3 ios/ci_scripts/write_firebase_options.py
"""
import json
import plistlib

with open('ios/Runner/GoogleService-Info.plist', 'rb') as f:
    ios = plistlib.load(f)
with open('android/app/google-services.json') as f:
    google = json.load(f)
project = google['project_info']
client = google['client'][0]

TEMPLATE = """// Generated in CI by ios/ci_scripts/write_firebase_options.py
// Project: {project_id}

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {{
  static FirebaseOptions get currentPlatform {{
    if (kIsWeb) {{
      throw UnsupportedError('DefaultFirebaseOptions are not configured for web.');
    }}
    switch (defaultTargetPlatform) {{
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }}
  }}

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '{android_api_key}',
    appId: '{android_app_id}',
    messagingSenderId: '{sender_id}',
    projectId: '{project_id}',
    storageBucket: '{storage_bucket}',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '{ios_api_key}',
    appId: '{ios_app_id}',
    messagingSenderId: '{ios_sender_id}',
    projectId: '{ios_project_id}',
    storageBucket: '{ios_storage_bucket}',
    iosBundleId: '{ios_bundle_id}',
    iosClientId: '{ios_client_id}',
  );
}}
"""

with open('lib/firebase_options.dart', 'w') as f:
    f.write(TEMPLATE.format(
        project_id=project['project_id'],
        sender_id=project['project_number'],
        storage_bucket=project['storage_bucket'],
        android_api_key=client['api_key'][0]['current_key'],
        android_app_id=client['client_info']['mobilesdk_app_id'],
        ios_api_key=ios['API_KEY'],
        ios_app_id=ios['GOOGLE_APP_ID'],
        ios_sender_id=ios['GCM_SENDER_ID'],
        ios_project_id=ios['PROJECT_ID'],
        ios_storage_bucket=ios['STORAGE_BUCKET'],
        ios_bundle_id=ios['BUNDLE_ID'],
        ios_client_id=ios['CLIENT_ID'],
    ))
