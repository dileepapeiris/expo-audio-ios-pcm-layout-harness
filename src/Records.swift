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

struct AudioStreamFileRecordingResult: Record {
  @Field var uri: String = ""
  @Field var duration: Double = 0.0
  @Field var size: Int = 0
  @Field var sampleRate: Int = 0
  @Field var channels: Int = 0
  @Field var encoding: AudioStreamEncoding = .int16
}

internal final class AudioStreamFileException: GenericException<String> {
  override var reason: String { param }
}
