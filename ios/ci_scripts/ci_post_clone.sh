#!/bin/sh
# Xcode Cloud runs this after cloning: it installs Flutter and the iOS
# dependencies that Xcode needs to build the Runner workspace.
set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

# The Flutter version the app is developed and tested with.
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.38.3 "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

# lib/firebase_options.dart is not in the repository; rebuild it from the
# Firebase config files that are.
python3 ios/ci_scripts/write_firebase_options.py

flutter precache --ios
flutter pub get

HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods
cd ios && pod install

exit 0
