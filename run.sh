#!/bin/zsh
# Usage: ./run.sh <path to AudioStream.swift>
# Compiles expo-audio's iOS AudioStream.swift against stubs of AVFoundation and ExpoModulesCore and
# checks the stereo PCM layout and the converter-failure fallback (expo/expo#52264).
# Needs Xcode's swiftc.
set -e
cd "$(dirname "$0")"
rm -rf out && mkdir -p out
sed -e 's/^import AVFoundation$/import AVStub/' -e 's/^import ExpoModulesCore$/import ExpoStub/' "$1" > out/AudioStream.swift
swiftc -emit-library -emit-module -module-name AVStub -o out/libAVStub.dylib -emit-module-path out/AVStub.swiftmodule stubs/AVStub.swift
swiftc -emit-library -emit-module -module-name ExpoStub -o out/libExpoStub.dylib -emit-module-path out/ExpoStub.swiftmodule stubs/ExpoStub.swift
swiftc -suppress-warnings -I out -L out -lAVStub -lExpoStub -o out/repro src/Records.swift src/AudioStreamFileWriter.swift out/AudioStream.swift src/main.swift
DYLD_LIBRARY_PATH=out out/repro
