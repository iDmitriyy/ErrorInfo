//
//  Utils.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

/// https://forums.swift.org/t/runtime-casts-of-sendable-type-to-another-sendable-type-not-possible/82070/2
internal func conditionalCast<T, U>(_ value: T, to _: U.Type) -> U? {
  value as? U
}

extension Optional {
  internal static func typeOfWrapped() -> Wrapped.Type { Wrapped.self }

  internal func typeOfWrapped() -> Wrapped.Type { Wrapped.self }
}

internal struct DictionaryCodingKey: CodingKey {
  internal let stringValue: String
  internal let intValue: Int?

  internal init(stringValue: String) {
    self.stringValue = stringValue
    intValue = Int(stringValue)
  }

  internal init(intValue: Int) {
    stringValue = "\(intValue)"
    self.intValue = intValue
  }
}

public struct AnySendableEncodable: Encodable & Sendable {
  private let encodable: any Encodable & Sendable

  public init(_ encodable: any Encodable & Sendable) {
    self.encodable = encodable
  }

  public func encode(to encoder: any Encoder) throws {
    // see https://forums.swift.org/t/how-to-encode-objects-of-unknown-type/12253/6
    // + https://forums.swift.org/t/how-to-encode-objects-of-unknown-type/12253/5
    var container = encoder.singleValueContainer()
    try container.encode(encodable)
  }
}
