//
//  CollisionSource.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 03/10/2025.
//

// TODO: make as struct with static functions

public enum CollisionSource: Sendable {
  case onSubscript(keyKind: KeyKind)
  case onAppend(keyKind: KeyKind)
  
  case onMerge(origin: MergeOrigin)
  
  case onAddPrefix(prefix: String)
  case onAddSuffix(suffix: String)
  case onKeysMapping(original: String, mapped: String)
  
  case onDictionaryConsumption(origin: MergeOrigin)
  case onCreateWithDictionaryLiteral // (firstKey: String)
  
  public func defaultStringInterpolation() -> String {
    let head = "!*!"
    let tail: String
    switch self {
    case .onSubscript(let keyKind): tail = "onSubscript(keyKind: \(keyKind.defaultStringInterpolation()))"
    case .onAppend(let keyKind): tail = "onAppend(keyKind: \(keyKind.defaultStringInterpolation()))"
    case let .onMerge(origin): return origin.defaultStringInterpolation(sourceString: "onMerge")
    case let .onAddPrefix(prefix): tail = "onAddPrefix(\"\(prefix)\")"
    case let .onAddSuffix(suffix): tail = "onAddSuffix(\"\(suffix)\")"
    case let .onKeysMapping(original, mapped): tail = "onKeyMapping(original: \"\(original)\", mapped: \"\(mapped)\")"
    case let .onDictionaryConsumption(origin): return origin.defaultStringInterpolation(sourceString: "onDictionaryConsumption")
    case .onCreateWithDictionaryLiteral: tail = "onCreateWithDictionaryLiteral"
    }
    return head + tail
  }
}

extension CollisionSource {
  public enum MergeOrigin: Sendable, ExpressibleByStringLiteral {
    case fileLine(file: StaticString = #fileID, line: UInt = #line)
    case function(function: String = #function)
    case custom(origin: String)
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral origin: String) {
      self = .custom(origin: origin)
    }
    
    /// `  @#@    >X<    !*!  >collision*`
    fileprivate func defaultStringInterpolation(sourceString: String) -> String {
      let head = "!*!" + sourceString
      let tail: String = switch self {
      case let .fileLine(file, line): "(" + "at: \(file):\(line)" + ")"
      case let .function(function): "(" + "inFunction: \(function)" + ")"
      case let .custom(origin): "(" + "origin: \(origin)" + ")"
      }
      return head + tail
    }
  }
  
  public enum KeyKind: Sendable {
    case literalConstant
    /// when key is passed as a string interpolation of value or String that created at runtime
    case dynamic
    
    public func defaultStringInterpolation() -> String {
      switch self {
      case .literalConstant: "literal"
      case .dynamic: "dynamic"
      }
    }
  }
}

// MARK: - Value + Collision Wrapper

public struct ValueWithCollisionWrapper<Value, CollisionSource> {
  public let value: Value
  public let collisionSource: CollisionSource?
  
  @inlinable
  internal init(value: Value, collisionSource: CollisionSource?) {
    self.value = value
    self.collisionSource = collisionSource
  }
  
  @inlinable
  internal static func value(_ value: Value) -> Self { Self(value: value, collisionSource: nil) }
  
  @inlinable
  internal static func collidedValue(_ value: Value, collisionSource: CollisionSource) -> Self {
    Self(value: value, collisionSource: collisionSource)
  }
}

extension ValueWithCollisionWrapper: Sendable where Value: Sendable, CollisionSource: Sendable {}

public enum KeyOrigin: Sendable {
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
    case .literalConstant: "l"
    case .combinedLiterals: "cl"
    case .dynamic: "d"
    case .keyPath: "kp"
    case .modified(let original): "m_" + original.shortSign()
    case .unverifiedMapped(let original): "um_" + original.shortSign()
    }
  }
}

/// `kind` not participate in hashing / equality
internal struct KeyWithOrigin: Hashable, Sendable {
  let string: String
  let origin: KeyOrigin
  // TODO: - tests
  func hash(into hasher: inout Hasher) { hasher.combine(string) }
  
  static func == (lhs: Self, rhs: Self) -> Bool { lhs.string == rhs.string }
}

// fileprivate enum ValueWithCollisionWrapper<Value, Source> {
//  case value(Value)
//  case collidedValue(Value, collisionSource: CollSource)
//
//  var value: Value {
//    switch self {
//    case .value(let value): value
//    case .collidedValue(let value, _): value
//    }
//  }
// }
