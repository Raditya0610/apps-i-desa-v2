#!/bin/sh
set -e

echo "=== Installing Flutter ==="
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git \
    --depth 1 -b stable flutter
fi

export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Getting dependencies ==="
flutter pub get

echo "=== Building web ==="
echo "Using BASE_URL: ${BASE_URL:-https://be-apps-i-desa.vercel.app}"
flutter build web --release \
  --dart-define=BASE_URL=${BASE_URL:-https://be-apps-i-desa.vercel.app}