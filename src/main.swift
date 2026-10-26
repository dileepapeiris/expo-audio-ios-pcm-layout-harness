import AVStub
import ExpoStub

// expo/expo#52264, two cases on the iOS AudioStream.

func emittedFloats(_ stream: AudioStream) -> [Float]? {
  guard let (_, payload) = stream.events.last(where: { $0.0 == "audioStreamBuffer" }), let data = payload["data"] as? ArrayBuffer else { return nil }
  return data.floats()
}

// Case 1: non-interleaved Float32 stereo at 48 kHz; the app requests the same rate, channels and encoding.
var options = AudioStreamOptions()
options.sampleRate = 48000; options.channels = 2; options.encoding = .float32
let stereo = AudioStream(options: options)
AVAudioEngine.lastInstance = nil
var planarStereo = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 2, interleaved: false)!
AVAudioInputNode.nextHardwareFormat = planarStereo
try! stereo.start()
let node1 = AVAudioEngine.lastInstance!.inputNode
let buffer1 = AVAudioPCMBuffer(pcmFormat: planarStereo, frameCapacity: 2)!
buffer1.fillPlanar([[1, 2], [3, 4]])   // left [1, 2], right [3, 4]
node1.tapBlock!(buffer1, AVAudioTime(hostTime: 0))
let got1 = emittedFloats(stereo) ?? []
let case1Pass = got1 == [1, 3, 2, 4]
print("stereo-layout: emitted \(got1), expected [1.0, 3.0, 2.0, 4.0] -> \(case1Pass ? "PASS" : "FAIL")")
stereo.stop()

// Case 2: hardware Float32 mono, the app requests Int16, and no converter is available.
var options2 = AudioStreamOptions()
options2.sampleRate = 48000; options2.channels = 1; options2.encoding = .int16
let mono = AudioStream(options: options2)
AVAudioInputNode.nextHardwareFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 1, interleaved: true)!
AVAudioConverter.failInit = true
var startError: Error?
do { try mono.start() } catch { startError = error }
AVAudioConverter.failInit = false
var case2Pass = false
if let startError {
  print("converter-failure: start() rejected the request: \(startError) -> PASS")
  case2Pass = true
} else {
  let node2 = AVAudioEngine.lastInstance!.inputNode
  let buffer2 = AVAudioPCMBuffer(pcmFormat: node2.hardwareFormat, frameCapacity: 1)!
  buffer2.fillPlanar([[0.5]])
  node2.tapBlock!(buffer2, AVAudioTime(hostTime: 0))
  let payload = mono.events.last(where: { $0.0 == "audioStreamBuffer" })?.1 ?? [:]
  let byteCount = (payload["data"] as? ArrayBuffer)?.count ?? -1
  let reported = payload["encoding"] as? String
  let bytesPerSample = byteCount // one frame, one channel
  case2Pass = reported == "float32"
  print("converter-failure: start() succeeded, buffer has \(bytesPerSample) bytes per sample for an int16 request (int16 is 2), payload encoding=\(reported ?? "absent") -> \(case2Pass ? "PASS" : "FAIL")")
  mono.stop()
}

print((case1Pass && case2Pass) ? "PASS" : "FAIL")
exit((case1Pass && case2Pass) ? 0 : 1)
