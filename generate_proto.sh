#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "=== Generating Rust protobuf code ==="
cd "$ROOT/backend"
cargo build

echo "=== Generating Dart protobuf code ==="
if ! command -v protoc-gen-dart &>/dev/null; then
  echo "protoc-gen-dart not found, installing..."
  dart pub global activate protoc_plugin
fi
export PATH="$PATH":"$HOME/.pub-cache/bin"
cd "$ROOT/frontend"
flutter pub get
protoc --dart_out="$ROOT/frontend/lib" -I "$ROOT/schema" "$ROOT/schema/freshmeal.proto"

echo "=== Done ==="
