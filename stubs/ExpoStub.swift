// Stand-ins for the ExpoModulesCore types AudioStream.swift uses.
import Foundation

open class SharedObject {
  public private(set) var events: [(String, [String: Any])] = []
  public init() {}
  public func emit(event: String, payload: [String: Any]) { events.append((event, payload)) }
}

