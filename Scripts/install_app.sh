#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEST_DIR="${HOME}/Applications"

if [[ "${1:-}" == "--system" ]]; then
    DEST_DIR="/Applications"
fi

cd "$ROOT_DIR"
Scripts/build_app.sh

mkdir -p "$DEST_DIR"
rm -rf "$DEST_DIR/NotchSpark.app"
cp -R "$ROOT_DIR/.build/NotchSpark.app" "$DEST_DIR/NotchSpark.app"
open "$DEST_DIR/NotchSpark.app"

echo "Installed NotchSpark to $DEST_DIR/NotchSpark.app"
