//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

import struct OrderedCollections.OrderedDictionary

// TODO: - add tests for elements ordering stability
// TODO: - add overloads for Sendable AnyObjects & actors

public struct ErrorInfo: Sendable { // ErrorInfoCollection
  public typealias Element = (key: String, value: any ValueType)
  
  public typealias ValueType = ErrorInfoValueType
  
  @usableFromInline internal typealias BackingStorage = OrderedMultiValueErrorInfoGeneric<String, _Entry>
  
  // TODO: private(set)
  @usableFromInline internal var _storage: BackingStorage
  
  private init(storage: BackingStorage) {
    _storage = storage
  }
  
  public init() {
    self.init(storage: BackingStorage())
  }
  
  public init(minimumCapacity: Int) {
    self.init(storage: BackingStorage(minimumCapacity: minimumCapacity))
  }
  
  public static let empty: Self = Self()
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append KeyValue with all arguments passed explicitly

extension ErrorInfo {
  /// The root appending function for public API imps. The term "_add" is chosen to visually / syntatically differentiate from family of public `append()`functions.
  internal mutating func _add<V: ValueType>(key: String,
                                            keyOrigin: KeyOrigin,
                                            value newValue: V?,
                                            preserveNilValues: Bool,
                                            duplicatePolicy: ValueDuplicatePolicy,
                                            collisionSource: @autoclosure () -> CollisionSource) {
    // TODO: put type TypeInfo
    let optional: _Optional
    if let newValue {
      optional = .value(newValue)
    } else if preserveNilValues {
      optional = .nilInstance(typeOfWrapped: V.self)
    } else {
      return
    }
    
    _storage.appendResolvingCollisions(key: key,
                                       value: _Entry(optional: optional, keyOrigin: keyOrigin),
                                       insertIfEqual: duplicatePolicy.insertIfEqual,
                                       collisionSource: collisionSource())
  }
  
  // SE-0352 Implicitly Opened Existentials
  // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md
  
  // SE-0375 Opening existential arguments to optional parameters
  
  internal mutating func _addExistentialNil(key: String,
                                            keyOrigin: KeyOrigin,
                                            preserveNilValues: Bool,
                                            duplicatePolicy: ValueDuplicatePolicy,
                                            collisionSource: @autoclosure () -> CollisionSource) {
    let optional: _Optional
    if preserveNilValues {
      optional = .nilInstance(typeOfWrapped: (any ErrorInfoValueType).self)
    } else {
      return
    }
    
    _storage.appendResolvingCollisions(key: key,
                                       value: _Entry(optional: optional, keyOrigin: keyOrigin),
                                       insertIfEqual: duplicatePolicy.insertIfEqual,
                                       collisionSource: collisionSource())
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Value Duplicate Policy

/*
 insertIfEqual: Bool
 
 Useful to when:
 - equal values represent different events. e.g. when the fact of having 2 equal values by itself is a useful
 knowledge / signal.
 - need to count occurrences of specific codes
 
 Gener:
 - repeated identical events
 - equal payloads from different origins
 
 info["message"] = "Timeout" // from database
 ...
 info["message"] = "Timeout" // from network
 
 Replacements / alternative design thoughts / policy:
 - equal but different collision sources
 - equal but from different keyOrigins
 
 - nil instance with different generic type
 */
extension ErrorInfo {
  public struct ValueDuplicatePolicy: Sendable {
    internal let insertIfEqual: Bool
    
    private init(insertIfEqual: Bool) {
      self.insertIfEqual = insertIfEqual
    }
    
    public static let defaultForAppending = rejectEqual
    
    /// Skip equal values
    public static let rejectEqual = Self(insertIfEqual: false)
    
    /// Store duplicates even when equal
    public static let allowEqual = Self(insertIfEqual: true)
    
    // updateByNew
    
    /// Keep duplicates only when collisionSource differs
    // case keepIfCollisionSourceDiffers
    
    // case keepIfKeyOriginsDiffers
    
    // default = keepIfCollisionSourceDiffers || keepIfKeyOriginsDiffers
    
    /// Custom decision logic
    // custom((_ existing: Entry, _ new: Entry) -> Bool)
    
    // DuplicatePolicy for nil values should be the same as for values and regulated by preserveNilValues
  }
}
