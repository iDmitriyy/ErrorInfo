//
//  KeyOrigin.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 28/11/2025.
//

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
  
  indirect case unverifiedMapped(original: Self)
  
  indirect case modified(original: Self)
  
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

//extension StringLiteralKey {
//  internal var asKeyWithOrigin: KeyWithOrigin {
//    KeyWithOrigin(string: rawValue, origin: keyOrigin)
//  }
//}
