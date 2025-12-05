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
  
  // TODO: should CollisionSource be stored in BackingStorage? mostly always CollisionSource is nil
  // may be BackingStorage should keep a separate dict for keeping CollisionSource instances
  // check memory consuption for both cases.
  // Do it after all Slices will be comlpeted, as keeping collisionSource in separate dict need a way to somehow
  // store relation between values in slice and collision sources.
  // Another one case is with TypeInfo. Simply type info can be stored as a Bool flag or Empty() instance.
  @usableFromInline internal typealias BackingStorage = OrderedMultiValueErrorInfoGeneric<String, _Entry>
  // public typealias ValueWrapper = CollisionTaggedValue<any ValueType, CollisionSource>
  
  // FIXME: private(set)
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
                                            insertIfEqual: Bool,
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
                                       insertIfEqual: insertIfEqual,
                                       collisionSource: collisionSource())
  }
  
  // SE-0352 Implicitly Opened Existentials
  // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md
  
  // SE-0375 Opening existential arguments to optional parameters
  
  internal mutating func _addExistentialNil(key: String,
                                            keyOrigin: KeyOrigin,
                                            preserveNilValues: Bool,
                                            insertIfEqual: Bool,
                                            collisionSource: @autoclosure () -> CollisionSource) {
    let optional: _Optional
    if preserveNilValues {
      optional = .nilInstance(typeOfWrapped: (any ErrorInfoValueType).self)
    } else {
      return
    }
    
    _storage.appendResolvingCollisions(key: key,
                                       value: _Entry(optional: optional, keyOrigin: keyOrigin),
                                       insertIfEqual: insertIfEqual,
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
    
    /// Skip equal values (default)
    public static let ignoreEqual = Self(insertIfEqual: false) // rejectEqual
    
    /// Store duplicates even when equal
    public static let keepEqual = Self(insertIfEqual: true) // allowEqual
    
    public static let `default` = ignoreEqual
    
    /// Keep duplicates only when collisionSource differs
    // case keepIfCollisionSourceDiffers
    // case keepIfKeyOriginsDiffers
    // default = keepIfCollisionSourceDiffers || keepIfKeyOriginsDiffers
    
    /// Custom decision logic
    // custom((_ existing: Entry, _ new: Entry) -> Bool)
    
    // updateByNew
    
    // seems to be out of scope of this options type. DuplicatePolicy for nil values should be the same as for values
    // and regulated by preserveNilValues
    // static let allowEqualNilValues  = Self(rawValue: 1 << 1)
  }
}
