#!/bin/bash
# Script for CI to generate Pull Request when Phrase updates

# exit on error
set -e
# show debug log
set -x

flutter analyze
flutter pub run dart_code_metrics:metrics analyze lib