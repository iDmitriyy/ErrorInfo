//
//  KeyWithOrigin.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 28/11/2025.
//

/// `kind` not participate in hashing / equality
@usableFromInline internal struct KeyWithOrigin: Hashable, Sendable {
  @usableFromInline let string: String
  let origin: KeyOrigin
  // TODO: - tests
  @usableFromInline func hash(into hasher: inout Hasher) { hasher.combine(string) }
  
  @usableFromInline static func == (lhs: Self, rhs: Self) -> Bool { lhs.string == rhs.string }
}

public enum KeyOrigin: Sendable {
  // TODO: memory footprint : ?Int8 ?make as OptionSet
  // Optionset can be private to protect from incorrect usage, e.g. not allow to conaint all options, but allow only
  // valid combinations like literalConstant + modified
  
  case literalConstant
  
  /// When key is created from a compile time known string literal.
  ///literalA + literalB ,  literalA + "stringLiteral"
  case combinedLiterals
  
  /// When key is generated at runtime, typically through string interpolation, json or other dynamic constructs.
  case dynamic
  
  case keyPath
  
  indirect case unverifiedMapped(original: Self)
  
  indirect case modified(original: Self)
  
  public func defaultStringInterpolation() -> String {
    switch self {
    case .literalConstant: "literal"
    case .combinedLiterals: "combinedLiterals"
    case .dynamic: "dynamic"
    case .keyPath: "keyPath"
    case .modified(let original): "modified_\(original)"
    case .unverifiedMapped(let original): "uverifiedMapped_\(original)"
    }
  }
  
  public func shortSign() -> String {
    switch self {
    case .literalConstant: "sl"
    case .combinedLiterals: "csl"
    case .dynamic: "dyn"
    case .keyPath: "kp"
    case .modified(let original): "m_" + original.shortSign()
    case .unverifiedMapped(let original): "um_" + original.shortSign()
    }
  }
}
