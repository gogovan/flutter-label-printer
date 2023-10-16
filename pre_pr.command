#!/bin/bash
# Script for CI to generate Pull Request when Phrase updates

# exit on error
set -e
# show debug log
set -x

dart format lib
dart format test
flutter analyze --fatal-infos --fatal-warnings

exit 0
