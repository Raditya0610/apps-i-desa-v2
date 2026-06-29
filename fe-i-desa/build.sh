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
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=API_BASE_URL=${API_BASE_URL:-http://localhost:8080}