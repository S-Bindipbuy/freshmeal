$ErrorActionPreference = "Stop"

$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Generating Rust protobuf code ==="
$cargo = Get-Command cargo -ErrorAction SilentlyContinue

if ($cargo) {
    Set-Location "$ROOT\backend"
    cargo build
}

Write-Host "=== Generating Dart protobuf code ==="

$protocGenDart = Get-Command protoc-gen-dart -ErrorAction SilentlyContinue

if (-not $protocGenDart) {
    $dart = Get-Command dart -ErrorAction SilentlyContinue

    if ($dart) {
        Write-Host "protoc-gen-dart not found, installing..."
        dart pub global activate protoc_plugin

        $pubCache = Join-Path $env:USERPROFILE ".pub-cache\bin"
        if ($env:PATH -notlike "*$pubCache*") {
            $env:PATH += ";$pubCache"
        }

        $protocGenDart = Get-Command "$pubCache\protoc-gen-dart.bat" -ErrorAction SilentlyContinue
    }
}

if ($protocGenDart) {
    Set-Location "$ROOT\frontend"
    flutter pub get

    $outDir = "$ROOT\frontend\lib"
    if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

    protoc `
        --dart_out="$outDir" `
        -I "$ROOT\schema" `
        "$ROOT\schema\freshmeal.proto"
}

Set-Location $ROOT
Write-Host "=== Done ==="
