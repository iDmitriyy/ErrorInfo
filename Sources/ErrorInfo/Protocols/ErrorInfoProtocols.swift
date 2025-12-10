//
//  ErrorInfoProtocols.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

// import IndependentDeclarations

// MARK: - Error Info

/// This approach addresses several important concerns:
/// - Thread Safety: The Sendable requirement is essential to prevent data races and ensure safe concurrent access.
/// - String Representation: Requiring CustomStringConvertible forces developers to provide meaningful string representations for stored values, which is invaluable for debugging and logging. It also prevents unexpected results when converting values to strings.
/// - Collision Resolution: The Equatable requirement allows to detect and potentially resolve collisions if different values are associated with the same key. This adds a layer of robustness.
public typealias ErrorInfoValueType = CustomStringConvertible & Equatable & Sendable

public protocol NonSendableErrorInfoProtocol<ValueType> {
  associatedtype ValueType
}

public protocol ErrorInfoRequirement {
  associatedtype Key
  associatedtype ValueType

  // MARK: Add value
  
  func _getUnderlyingValue(forKey key: Key) -> ValueType?
  
  mutating func _addResolvingCollisions(value: ValueType, forKey key: Key)
  
//  func getUnderlyingStorage() -> some DictionaryUnifyingProtocol<String, ValueType>
  
  // MARK: Merge
  
  mutating func merge<each D>(_ donators: repeat each D) where repeat each D: ErrorInfoRequirement
  
  // MARK: Prefix & Suffix
  
  // FIXME: keyPrefix is String and incompatible with generic Key.
  // mutating func addKeyPrefix(_ keyPrefix: String, transform: PrefixTransformFunc)
}

extension ErrorInfoRequirement where ValueType == any Sendable {}

extension ErrorInfoRequirement { // MARK: Merge

  public consuming func merging<each D>(_ donators: repeat each D) -> Self
    where repeat each D: ErrorInfoRequirement {
      merge(repeat each donators)
      return self
    }
}

extension ErrorInfoRequirement { // MARK: Prefix & Suffix

//  toKeysOf dict: inout Dict,
//  transform: PrefixTransformFunc
  
  // public consuming func addingKeyPrefix(_ keyPrefix: String, transform: PrefixTransformFunc) -> Self {
  //   addKeyPrefix(keyPrefix, transform: transform)
  //   return self
  // }
}

extension ErrorInfoRequirement {
  public init(legacyUserInfo _: [String: Any],
              valueInterpolation _: @Sendable (Any) -> String = { prettyDescriptionOfOptional(any: $0) }) {
//    self.init()
//    legacyUserInfo.forEach { key, value in storage[key] = valueInterpolation(value) }
    fatalError()
  }
  
  public func asStringDict() -> [String: String] {
    fatalError()
  }
}

/// Default functions implementations for ErrorInfo types
// internal protocol ErrorInfoInternalDefaultFuncs {
//  associatedtype Storage: DictionaryProtocol
//
//  var storage: Storage { get }
// }
