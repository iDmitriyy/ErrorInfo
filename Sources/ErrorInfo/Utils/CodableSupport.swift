//
//  CodableSupport.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 10/12/2025.
//

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

/// For single primitive value.
public struct AnyEncodableSingleValue: Encodable, Sendable {
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

// public struct AnyDecodableSingleValue: Encodable, Sendable {} // for tests only

// public init(from decoder: any Decoder) throws {
//   let container = try decoder.singleValueContainer()
// }
