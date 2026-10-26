import ExpoStub

enum AudioStreamEncoding: String, Enumerable {
  case float32
  case int16
}

struct AudioStreamOptions: Record {
  @Field var sampleRate: Double = 48000
  @Field var channels: Int = 1
  @Field var encoding: AudioStreamEncoding = .float32
}

enum AudioStreamFileFormat: String, Enumerable {
  case wav
  case pcm

  var fileExtension: String { rawValue }
}

