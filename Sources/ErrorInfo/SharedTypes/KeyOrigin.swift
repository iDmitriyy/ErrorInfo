//
//  KeyOrigin.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 28/11/2025.
//

/// `KeyOrigin` represents the various possible sources or types of keys, which may vary
/// depending on whether they are static, dynamically generated, or modified at runtime. This enum helps
/// track how keys are derived, allowing for better tracking, logging, and debugging within the system.
///
/// ## Cases:
/// - `literalConstant`: A key created from a compile-time known string literal.
/// - `combinedLiterals`: A key derived from a combination of multiple compile-time known literals.
/// - `dynamic`: A key generated at runtime, often through string interpolation or dynamic constructs.
/// - `keyPath`: A key representing a path to a specific property or value.
/// - `modified`: A key that has been modified from its original form by a predefined transformation provided by the library.
/// - `unverifiedMapped`: A key that has been modified from its original form by a custom transformation provided by library user.
///
/// ## Methods:
/// - `defaultInterpolation()`: Returns a default string representation for the `KeyOrigin` case.
/// - `shortSignInterpolation()`: Returns a shorter, abbreviated string for the `KeyOrigin` case, useful for compact representations.
public enum KeyOrigin: Sendable {
  // TODO: memory footprint : ?Int8 ?make as OptionSet
  // Optionset can be private to protect from incorrect usage, e.g. not allow to conaint all options, but allow only
  // valid combinations like literalConstant + modified
  
  case literalConstant
  
  /// When key is created from a compile time known string literal.
  /// literalA + literalB ,  literalA + "stringLiteral"
  case combinedLiterals
  
  /// When key is generated at runtime, typically through string interpolation, json or other dynamic constructs.
  case dynamic
  
  case keyPath
  
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
    case .literalConstant: "l"
    case .combinedLiterals: "cl"
    case .dynamic: "dyn"
    case .keyPath: "kp"
    case .modified(let original): "m_" + original.shortSignInterpolation()
    case .unverifiedMapped(let original): "um_" + original.shortSignInterpolation()
    }
  }
}
