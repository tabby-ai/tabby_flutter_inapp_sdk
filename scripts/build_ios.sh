#!/usr/bin/env bash

echo "Building iOS 🛠️"

fvm use
make pg

cd example

# fvm flutter build ipa --release

echo "✅ Build finished"

# It sets IPA_PATH variable
export IPA_PATH="$(pwd)/build/ios/ipa/tabby_flutter.ipa"
echo "👉 IPA_PATH path: $IPA_PATH"

# Set AppStore key path
export APPSTORE_API_KEY="$(pwd)/../.secure_files/AuthKey_6WK27WDACV.p8"
echo "🔑 APPSTORE_API_KEY path: $APPSTORE_API_KEY"

cd ..
echo "👉 Currently in dir: $(pwd)"

# Prepare version
fvm dart run scripts/prepare_version.dart

eval "$(
  cat ./scripts/.env_version | awk '!/^\s*#/' | awk '!/^\s*$/' | while IFS='' read -r line; do
    key=$(echo "$line" | cut -d '=' -f 1)
    value=$(echo "$line" | cut -d '=' -f 2-)
    echo "export $key=\"$value\""
  done
)"

echo "📦 got version $TABBY_APP_VERSION+$TABBY_APP_BUILD_NUMBER"

# It uploads IPA to TestFlight
cd example/ios
fastlane init
fastlane upload_testflight build_number:"$TABBY_APP_BUILD_NUMBER" app_version:"$TABBY_APP_VERSION"
cd ..
