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
