# Swift harness for expo/expo#52264

Checks two things in expo-audio's iOS `AudioStream`. Compiles the real `AudioStream.swift` and
`AudioStreamFileWriter.swift` against small stubs of the AVFoundation and ExpoModulesCore types
they use. The PCM buffer stub has real planar storage with the sentinel `99` after the samples, the
input node stub hands the tap block to the harness, and the converter stub can refuse to initialize.

- **stereo-layout:** the hardware delivers non-interleaved Float32 stereo at 48 kHz and the app
  requests the same rate, channels and encoding. Left is `[1, 2]`, right is `[3, 4]`.
- **converter-failure:** the hardware delivers Float32 mono, the app requests Int16, and no
  converter is available.

## Run

Needs Xcode's `swiftc`.

```sh
./run.sh ../expo/packages/expo-audio/ios/AudioStream.swift
```

