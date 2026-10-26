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

## Expected

- stereo-layout: the emitted buffer is interleaved `[1, 3, 2, 4]`.
- converter-failure: `start()` rejects the request, or the buffer event says which encoding it
  carries.

## Result on 10/26/26 with the expo-audio 58.0.10 sources from `main`

```
stereo-layout: emitted [1.0, 2.0, 99.0, 99.0], expected [1.0, 3.0, 2.0, 4.0] -> FAIL
converter-failure: start() succeeded, buffer has 4 bytes per sample for an int16 request (int16 is 2), payload encoding=absent -> FAIL
FAIL
```

The conversion check compares sample rate, channel count and sample format but not the layout, so a
planar stereo input is passed through as if it were interleaved and only the first channel's plane
is copied. When no converter can be made, the stream falls back to the hardware format and emits
Float32 bytes for an Int16 request without saying so.
