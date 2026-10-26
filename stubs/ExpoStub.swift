// Stand-ins for the ExpoModulesCore types AudioStream.swift uses.
import Foundation

open class SharedObject {
  public private(set) var events: [(String, [String: Any])] = []
  public init() {}
  public func emit(event: String, payload: [String: Any]) { events.append((event, payload)) }
}

open class GenericException<Param>: Error, CustomStringConvertible {
  public let param: Param
  public init(_ param: Param) { self.param = param }
  open var reason: String { "\(param)" }
  public var description: String { reason }
}

public final class ArrayBuffer {
  public let bytes: Data
  public var count: Int { bytes.count }
  private init(bytes: Data) { self.bytes = bytes }
  public static func copy(of pointer: UnsafeRawPointer, count: Int) -> ArrayBuffer { ArrayBuffer(bytes: Data(bytes: pointer, count: count)) }
  public func floats() -> [Float] { bytes.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) } }
}

