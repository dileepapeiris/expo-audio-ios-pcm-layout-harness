#!/bin/zsh
# Usage: ./run.sh <path to AudioStream.swift>
# Compiles expo-audio's iOS AudioStream.swift against stubs of AVFoundation and ExpoModulesCore and
# checks the stereo PCM layout and the converter-failure fallback (expo/expo#52264).
# Needs Xcode's swiftc.
set -e
cd "$(dirname "$0")"
