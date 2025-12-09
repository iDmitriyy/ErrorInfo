//
//  AnyEncodable.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 09/12/2025.
//

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
