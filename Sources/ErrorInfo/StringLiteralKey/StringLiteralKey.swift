//
//  ErronInfoLiteralKey.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

/// `StringLiteralKey` is designed to be used primarily for subscripting and appending values to `error-info` instances.
/// It can be constructed from static keys known at compile-time.
/// In context of using ErrorInfo, such design helps do differentiate between copile-time knowm literals and dynamically created String keys.
///
/// Combining Keys:
/// StringLiteralKey supports the `+` operator to combine multiple keys, allowing creation of composite keys.
/// ```swift
/// errorInfo[.invalid + .index] = index
/// ```
///
/// Benefits & Goals:
/// - Name safety: prevents typos and inconsistent key names
/// - Autocomplete: easy to find using autocomplete with  no pollution of String namespace.
/// - Predefined Keys:
///   - common keys for typical error contexts, network, state information, and more.
///   - reduced hardcoding and string duplication.
/// - Consistency: centralizes key definitions, ensuring the same key is used across different parts of the code.
/// - Improved Refactoring: renaming user-defined keys is easy and automatically reflected throughout the codebase.
///
/// Predefined Keys:
/// StringLiteralKey includes a number of predefined keys and prefixes that cover common use cases:
/// - Commonly used prefixes (e.g. `.invalid`, `.unexpected`)
/// - Error Contexts
/// - Network
/// - App State
/// - Basic Information
///
/// # Example:
/// ```swift
/// var info = ErrorInfo()
///
/// errorInfo[.httpStatusCode] = 404
/// errorInfo[.response + .message] = "Page Not Found"
/// ```
public struct StringLiteralKey: Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  /// A new instance initialized with `rawValue` will be equivalent to this instance.
  internal let rawValue: String
  
  public var description: String { rawValue }
  
  public var debugDescription: String { rawValue } // TODO: ? rawValue.debugDescription
  
  internal let keyOrigin: KeyOrigin
  
  private init(_combinedLiteralsString: String) {
    rawValue = _combinedLiteralsString
    keyOrigin = .combinedLiterals
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(rawValue)
  }
  
  public static func == (lhs: StringLiteralKey, rhs: StringLiteralKey) -> Bool {
    lhs.rawValue == rhs.rawValue
  }
}

extension StringLiteralKey: ExpressibleByStringLiteral { // Improvement: try to make it zero-cost abstraction
  public typealias StringLiteralType = StaticString
  // TODO: Check if there any costs for using StaticString instead of String as literal type.
  // StaticString completely closes the hole when ErronInfoKey can be initialized with dynamically formed string or interpolation.
  // use @const instead of static let (check binary size(reduce swift_once) and perfomance on first access)
  public init(stringLiteral value: StaticString) {
    rawValue = String.init(value)
    keyOrigin = .literalConstant
  }
}

extension StringLiteralKey {
  // Improvement: perfomance: borrowing | consuming(copying), @const
  
  public static func + (lhs: Self, rhs: Self) -> Self {
    Self(_combinedLiteralsString: lhs.rawValue + "_" + rhs.rawValue)
  }
}
