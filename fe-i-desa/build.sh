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
echo "Using SIMPOI_URL: ${SIMPOI_URL:-https://shinnwlfrd.github.io/simpoi/}"
# --no-web-resources-cdn: serve CanvasKit from our own origin instead of
# gstatic.com. The service worker only precaches same-origin assets, so with the
# CDN default the installed PWA cannot fetch its renderer offline and fails to
# boot — which would defeat the point of installing it at the desa office.
flutter build web --release \
  --no-web-resources-cdn \
  --dart-define=BASE_URL=${BASE_URL:-https://be-apps-i-desa.vercel.app} \
  --dart-define=SIMPOI_URL=${SIMPOI_URL:-https://shinnwlfrd.github.io/simpoi/}