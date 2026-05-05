#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$ROOT_DIR/.build/NotchSpark.app"
CONTENTS_PATH="$APP_PATH/Contents"
MACOS_PATH="$CONTENTS_PATH/MacOS"
RESOURCES_PATH="$CONTENTS_PATH/Resources"

cd "$ROOT_DIR"
swift build -c release

rm -rf "$APP_PATH"
mkdir -p "$MACOS_PATH" "$RESOURCES_PATH"
cp "$ROOT_DIR/.build/release/NotchSpark" "$MACOS_PATH/NotchSpark"
cp "$ROOT_DIR/Packaging/Info.plist" "$CONTENTS_PATH/Info.plist"
chmod +x "$MACOS_PATH/NotchSpark"

if command -v codesign >/dev/null 2>&1; then
    codesign --force --sign - "$APP_PATH" >/dev/null
fi

echo "Built $APP_PATH"
