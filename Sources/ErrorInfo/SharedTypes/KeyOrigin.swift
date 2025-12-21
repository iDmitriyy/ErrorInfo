//
//  KeyOrigin.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 28/11/2025.
//

/// Represents the origin of a key in a key-value store, providing metadata about how the key was created or transformed.
/// Useful for tracking key sources (e.g., static literal, dynamic, keyPath) and track how keys are derived, allowing for
/// better tracking, logging, and debugging within the system.
///
/// ## Benefits:
/// - **Faster Debugging**: Quickly determine if a key is static, dynamic, or modified, improving the speed of identifying issues.
/// - **Transparency in Key Transformations**: Understand how keys evolve over time, reducing ambiguity in complex data flows.
/// - **Clearer Logs**: Error logs provide detailed context, showing where and how keys were generated or changed.
/// - **Collision Resolution**: Track key origins to resolve conflicts caused by dynamic generation or key modifications.
///
/// ## Cases:
/// - `literalConstant`: A key created from a compile-time known string literal.
/// - `combinedLiterals`: A key derived from a combination of multiple compile-time known literals.
/// - `dynamic`: A key generated at runtime, often through string interpolation or dynamic constructs.
/// - `keyPath`: A key representing a path to a specific property or value.
/// - `fromCollection`: A key derived from a collection of key-value pair
/// - `modified`: A key that has been modified from its original form by a predefined transformation provided by the library.
/// - `unverifiedMapped`: A key that has been modified from its original form by a custom transformation provided by user.
///
/// ## Methods:
/// - `defaultInterpolation()`: Returns a default string representation for the `KeyOrigin` case.
/// - `shortSignInterpolation()`: Returns a shorter, abbreviated string for the `KeyOrigin` case, useful for compact representations.
public enum KeyOrigin: Sendable, Equatable, CustomDebugStringConvertible {
  // TBD: memory footprint : ?Int8 ?make as OptionSet
  // Optionset can be private to protect from incorrect usage, e.g. not allow to conaint all options, but allow only
  // valid combinations like literalConstant + modified
  
  case literalConstant
  
  /// When key is created from a compile time known string literal.
  /// literalA + literalB ,  literalA + "stringLiteral"
  case combinedLiterals
  
  /// When key is generated at runtime, typically through string interpolation, json or other dynamic constructs.
  case dynamic
  
  case keyPath
  
  case fromCollection
  
  indirect case modified(original: Self)
  
  indirect case unverifiedMapped(original: Self)
  
  /// Returns a default string representation for the key origin.
  ///
  /// # Example:
  /// ```swift
  /// let origin = KeyOrigin.literalConstant
  /// print(origin.defaultInterpolation()) // "literal"
  /// ```
  public func defaultInterpolation() -> String {
    switch self {
    case .literalConstant: "literal"
    case .combinedLiterals: "combinedLiterals"
    case .dynamic: "dynamic"
    case .keyPath: "keyPath"
    case .fromCollection: "fromCollection"
    case .modified(let original): "modified_\(original)"
    case .unverifiedMapped(let original): "unverifiedMapped_\(original)"
    }
  }
  
  /// Returns a shortened, abbreviated string representation for the key origin.
  ///
  /// # Example:
  /// ```swift
  /// let origin = KeyOrigin.modified(original: .literalConstant)
  /// print(origin.shortSignInterpolation()) // "m_l"
  /// ```
  public func shortSignInterpolation() -> String {
    switch self {
    case .literalConstant: "li"
    case .combinedLiterals: "cl"
    case .dynamic: "dyn"
    case .keyPath: "kp"
    case .fromCollection: "fc"
    case .modified(let original): "mod_" + original.shortSignInterpolation()
    case .unverifiedMapped(let original): "um_" + original.shortSignInterpolation()
    }
  }
  
  public var debugDescription: String { defaultInterpolation() }
}
