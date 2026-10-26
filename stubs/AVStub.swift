// Stand-ins for the AVFoundation types AudioStream.swift uses. The engine can be told to throw from start().
@_exported import Foundation

public typealias AVAudioFrameCount = UInt32
public typealias AVAudioChannelCount = UInt32
public typealias AVAudioPacketCount = UInt32

public enum AVAudioCommonFormat { case pcmFormatFloat32, pcmFormatInt16, otherFormat }

public final class AVAudioFormat {
  public let sampleRate: Double
  public let channelCount: AVAudioChannelCount
  public let commonFormat: AVAudioCommonFormat
  public let isInterleaved: Bool
  public init?(commonFormat: AVAudioCommonFormat, sampleRate: Double, channels: AVAudioChannelCount, interleaved: Bool) {
    self.commonFormat = commonFormat; self.sampleRate = sampleRate; self.channelCount = channels; self.isInterleaved = interleaved
  }
}

public final class AVAudioTime { public let hostTime: UInt64; public init(hostTime: UInt64) { self.hostTime = hostTime } }

/** PCM buffer with real planar storage. Unused capacity is filled with the sentinel 99 so an overread shows up. */
public final class AVAudioPCMBuffer {
  public static let sentinel: Float = 99
  public let format: AVAudioFormat
  public let frameCapacity: AVAudioFrameCount
  public var frameLength: AVAudioFrameCount = 0
  private let floatPlanes: UnsafeMutablePointer<UnsafeMutablePointer<Float>>
  private let int16Planes: UnsafeMutablePointer<UnsafeMutablePointer<Int16>>
  private let planeCount: Int
  public var int16ChannelData: UnsafePointer<UnsafeMutablePointer<Int16>>? { format.commonFormat == .pcmFormatInt16 ? UnsafePointer(int16Planes) : nil }
  public var floatChannelData: UnsafePointer<UnsafeMutablePointer<Float>>? { format.commonFormat == .pcmFormatFloat32 ? UnsafePointer(floatPlanes) : nil }
  public init?(pcmFormat: AVAudioFormat, frameCapacity: AVAudioFrameCount) {
    format = pcmFormat; self.frameCapacity = frameCapacity
    // Interleaved formats keep one plane holding channels*frames samples; planar formats keep one plane per channel.
    planeCount = pcmFormat.isInterleaved ? 1 : Int(pcmFormat.channelCount)
    // Extra slack after the real samples, so a copy that reads past one plane lands on the sentinel.
    let samplesPerPlane = Int(frameCapacity) * (pcmFormat.isInterleaved ? Int(pcmFormat.channelCount) : 1) + 16
    floatPlanes = .allocate(capacity: planeCount); int16Planes = .allocate(capacity: planeCount)
    for i in 0..<planeCount {
      let f = UnsafeMutablePointer<Float>.allocate(capacity: samplesPerPlane); f.initialize(repeating: AVAudioPCMBuffer.sentinel, count: samplesPerPlane); floatPlanes[i] = f
      let n = UnsafeMutablePointer<Int16>.allocate(capacity: samplesPerPlane); n.initialize(repeating: Int16(AVAudioPCMBuffer.sentinel), count: samplesPerPlane); int16Planes[i] = n
    }
  }
  /** Fills planar float channels: `channels[c][frame]`. */
  public func fillPlanar(_ channels: [[Float]]) {
    frameLength = AVAudioFrameCount(channels[0].count)
    for (c, samples) in channels.enumerated() { for (i, v) in samples.enumerated() { floatPlanes[c][i] = v } }
  }
}

public enum AVAudioConverterInputStatus { case haveData, noDataNow, endOfStream }
public enum AVAudioConverterOutputStatus { case haveData, inputRanDry, endOfStream, error }
public final class AVAudioConverter {
  /** When true, init returns nil, like AVFoundation does for an unsupported conversion. */
  public static var failInit = false
  public init?(from: AVAudioFormat, to: AVAudioFormat) { if AVAudioConverter.failInit { return nil } }
  public func convert(to: AVAudioPCMBuffer, error: NSErrorPointer,
                      withInputFrom block: (AVAudioPacketCount, UnsafeMutablePointer<AVAudioConverterInputStatus>) -> AVAudioPCMBuffer?) -> AVAudioConverterOutputStatus { .endOfStream }
}

