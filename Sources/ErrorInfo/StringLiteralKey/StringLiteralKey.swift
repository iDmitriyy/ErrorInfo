//
//  StringLiteralKey.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

/// `StringLiteralKey` is designed to be used primarily for subscripting and appending values to `error-info` instances.
/// It can be constructed from static string literals known at compile-time.
/// In context of using ErrorInfo, such design helps do differentiate between copile-time knowm literals and dynamically created String keys.
///
/// ## Combining Keys:
/// StringLiteralKey supports the `+` operator to combine multiple keys, allowing creation of composite keys.
/// ```swift
/// errorInfo[.invalid + .index] = elementIndex
/// ```
///
/// ## Benefits & Goals:
/// - **Name safety:** prevents typos and inconsistent key names
/// - **Autocomplete:** easy to find using autocomplete with  no pollution of `String` namespace.
/// - **Predefined Keys:**
///   - common keys for typical error contexts, network, state information, and more.
///   - reduced hardcoding and string duplication.
/// - **Consistency:** centralizes key definitions, ensuring the same key is used across different parts of the code.
/// - **Improved Refactoring:** renaming user-defined keys is easy and automatically reflected throughout the codebase.
///
/// ## Predefined Keys:
/// Predefined keys and prefixes cover common use cases:
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
/// info[.httpStatusCode] = 404
/// info[.response + .message] = "Page Not Found"
/// ```
///
/// - Note:
/// By default names are given with `snake_case`, which can be transformed to `camelCase`,
/// `kebab-case `or `PascalCase` formats when logging.
///
/// ## See Also:
/// ``ErrorInfoFuncs.fromAnyStyleToCamelCased(string:)``
/// ``ErrorInfoFuncs.fromAnyStyleToPascalCased(string:)``
/// ``ErrorInfoFuncs.fromAnyStyleToKebabCased(string:)``
/// ``ErrorInfoFuncs.fromAnyStyleToSnakeCased(string:)``
///
/// The following categories of keys are intentionally not added:
/// - memory_usage, cpu_usage, free_disk_space, frame_rate, is_debugger_attached ...
/// - device_orientation, screen_brightness, has_camera ...
/// - locale, language, timezone ...
/// - platform, device_type, is_simulator, cpu_architecture ...
///
/// Such params are:
/// - Provided out of the box by common services like Sentry, or Firebase.
/// - Typically not added to common errors created by programmers of a team. They are narrowly used in specific contexts.
///
/// If someone need project or domain-specific default keys, they are free to add their own in an extension to `StringLiteralKey`.
public struct StringLiteralKey: Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  /// A new instance initialized with `rawValue` will be equivalent to this instance.
  @usableFromInline
  internal let rawValue: String
  
  public var description: String { rawValue }
    
  public var debugDescription: String {
    switch keyOrigin {
    case .literalConstant: #"StringLiteralKey(literal: "\#(rawValue)")"#
    case .combinedLiterals: #"StringLiteralKey(combined: "\#(rawValue)")"#
    default: #"StringLiteralKey(\#(keyOrigin): "\#(rawValue)")"#
    }
  }
  
  @usableFromInline
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
  
  public init(stringLiteral value: StaticString) {
    rawValue = String(value)
    keyOrigin = .literalConstant
  } // inlining has no effect on perfomance
  
  // StaticString completely closes the hole when ErronInfoKey can be initialized with dynamically formed string or interpolation.
  // Improvement: use @const instead of static let (check binary size(reduce swift_once) and perfomance on first access)
}

extension StringLiteralKey {
//  public subscript(dynamicMember keyPath: KeyPath<StringLiteralKey.Type, StringLiteralKey>) -> StringLiteralKey {
//    let keyToAppend = StringLiteralKey.self[keyPath: keyPath]
//    return self + keyToAppend
//  }
    
  public static func + (lhs: Self, rhs: Self) -> Self {
    Self(_combinedLiteralsString: lhs.rawValue + "_" + rhs.rawValue)
  } // inlining has no effect on perfomance
}
