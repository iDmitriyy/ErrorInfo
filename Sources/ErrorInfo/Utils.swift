//
//  Utils.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

/// https://forums.swift.org/t/runtime-casts-of-sendable-type-to-another-sendable-type-not-possible/82070/2
///
/// # WARNING
/// The code below will return non nil value, and nonSendable is succesfuly casted.
/// Use when value is known to be Sendable.
/// ```
/// let nonSendable = NonSendable()
///
/// if let nonSendable = conditionalCast(nonSendable, to: (any Sendable).self) {
///    print(nonSendable) // ! succesfully casted even nonSendable as non Sendable
/// }
/// ```
internal func __conditionalCast<T, U>(_ value: T, to _: U.Type) -> U? {
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
