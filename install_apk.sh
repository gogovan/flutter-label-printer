#!/bin/sh
set -ex

cd example
flutter clean
flutter build apk --target=lib/main.dart --debug
adb -d push build/app/outputs/apk/debug/app-debug.apk /storage/self/primary/Download/label-printer-example-dev.apk
# adb -d install build/app/outputs/apk/dev/debug/app-debug.apk