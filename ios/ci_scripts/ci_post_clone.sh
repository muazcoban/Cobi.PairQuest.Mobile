#!/bin/sh
# Xcode Cloud runs this after cloning: it installs Flutter and the iOS
# dependencies that Xcode needs to build the Runner workspace.
set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

# The Flutter version the app is developed and tested with.
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.38.3 "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

# lib/firebase_options.dart is not in the public repository. The workflow
# keeps it, base64-encoded, in the FIREBASE_OPTIONS_BASE64 secret.
if [ -z "$FIREBASE_OPTIONS_BASE64" ]; then
  echo "error: FIREBASE_OPTIONS_BASE64 is not set in the Xcode Cloud workflow" >&2
  exit 1
fi
echo "$FIREBASE_OPTIONS_BASE64" | base64 --decode > lib/firebase_options.dart

flutter precache --ios
flutter pub get

HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods
cd ios && pod install

exit 0
