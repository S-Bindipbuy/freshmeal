#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "=== Generating Rust protobuf code ==="
if command -v cargo >/dev/null 2>&2; then
    cd "$ROOT/backend"
    cargo build
fi

echo "=== Generating Dart protobuf code ==="

if ! command -v protoc-gen-dart >/dev/null 2>&1; then
    if command -v dart >/dev/null 2>&1; then
        echo "protoc-gen-dart not found, installing..."
        dart pub global activate protoc_plugin
        export PATH="$PATH:$HOME/.pub-cache/bin"
    else
        echo "Dart SDK not found. Skipping Dart protobuf generation."
    fi
fi

if command -v protoc-gen-dart >/dev/null 2>&1; then
    cd "$ROOT/frontend"
    flutter pub get

    protoc \
        --dart_out="$ROOT/frontend/lib" \
        -I "$ROOT/schema" \
        "$ROOT/schema/freshmeal.proto"
fi

echo "=== Done ==="
