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
/// ```swift
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

extension String {
  // TODO: - write perfomance tests to measure that it is faster than usin + operator severaal times ("a" + "b" + "c")
  // check is it faster than using String instead of `some StringProtocol` instances, is for StringProtocol
  // append(contentsOf:) is used, which can be slower.
  // compare to `.joined()`
  // https://github.com/swiftlang/swift/blob/3dcd9bb011ce21376ca1a8e4656fdc4c11cd9f13/stdlib/public/core/String.swift#L908
  // internal static func _concat<each D>(_ strings: repeat each D) -> Self where repeat each D: StringProtocol {
  //   var capacity: Int = 0
  //   for string in repeat each strings {
  //     capacity += string.utf8.count
  //   }
  //
  //   var result = String(minimumCapacity: capacity)
  //
  //   for string in repeat each strings {
  //     result.append(contentsOf: string)
  //   }
  //
  //   return result
  // }
  
  internal static func concat(_ a: consuming String, _ b: consuming String) -> Self {
    let capacity = a.utf8.count + b.utf8.count
    
    var result = String(minimumCapacity: capacity)
    
    result.append(a)
    result.append(b)
    
    return result
  }
  
  internal static func concat(_ a: consuming String, _ b: consuming String, _ c: consuming String) -> Self {
    let capacity = a.utf8.count + b.utf8.count + c.utf8.count
    
    var result = String(minimumCapacity: capacity)
    
    result.append(a)
    result.append(b)
    result.append(c)
    
    return result
  }
  
  internal static func concat(_ a: consuming String, _ b: consuming String, _ c: consuming String, _ d: consuming String) -> Self {
    let capacity = a.utf8.count + b.utf8.count + c.utf8.count + d.utf8.count
    
    var result = String(minimumCapacity: capacity)
    
    result.append(a)
    result.append(b)
    result.append(c)
    result.append(d)
    
    return result
  }
  
  internal static func concat(_ a: consuming String,
                              _ b: consuming String,
                              _ c: consuming String,
                              _ d: consuming String,
                              _ e: consuming String) -> Self {
    let capacity = a.utf8.count + b.utf8.count + c.utf8.count + d.utf8.count + e.utf8.count
    
    var result = String(minimumCapacity: capacity)
    
    result.append(a)
    result.append(b)
    result.append(c)
    result.append(d)
    result.append(e)
    
    return result
  }
  
  internal static func concat(_ a: consuming String,
                              _ b: consuming String,
                              _ c: consuming String,
                              _ d: consuming String,
                              _ e: consuming String,
                              _ f: consuming String) -> Self {
    let capacity = a.utf8.count + b.utf8.count + c.utf8.count + d.utf8.count + e.utf8.count + f.utf8.count
    
    var result = String(minimumCapacity: capacity)
    
    result.append(a)
    result.append(b)
    result.append(c)
    result.append(d)
    result.append(e)
    result.append(f)
    
    return result
  }
}
