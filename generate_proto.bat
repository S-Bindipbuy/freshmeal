@echo off
setlocal

set ROOT=%~dp0

echo === Generating Rust protobuf code ===
cd /d "%ROOT%backend"
cargo build

echo === Generating Dart protobuf code ===
where protoc-gen-dart >nul 2>&1
if %ERRORLEVEL% neq 0 (
  echo protoc-gen-dart not found, installing...
  call dart pub global activate protoc_plugin
)
set "PATH=%PATH%;%USERPROFILE%\.pub-cache\bin"
cd /d "%ROOT%frontend"
call flutter pub get
protoc --dart_out="%ROOT%frontend\lib" -I "%ROOT%schema" "%ROOT%schema\freshmeal.proto"

echo === Done ===
endlocal
