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
  public typealias ValueType = ErrorInfoValueType
  public typealias CollisionSource = StringBasedCollisionSource
  
  // TODO: should CollisionSource be stored in BackingStorage? mostly always CollisionSource is nil
  // may be BackingStorage should keep a separate dict for keeping CollisionSource instances
  // check memory consuption for both cases.
  // Do it after all Slices will be comlpeted, as keeping collisionSource in separate dict need a way to somehow
  // store relation between values in slice and collision sources.
  // Another one case is with TypeInfo. Simply type info can be stored as a Bool flag or Empty() instance.
  internal typealias BackingStorage = OrderedMultiValueErrorInfoGeneric<String, _ValueVariant>
  public typealias ValueWrapper = ValueWithCollisionWrapper<any ValueType, CollisionSource>
  
  // FIXME: private(set)
  internal var _storage: BackingStorage
  
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
  internal mutating func _add<V: ValueType>(key: Key,
                                            value newValue: V?,
                                            preserveNilValues: Bool,
                                            insertIfEqual: Bool,
                                            addTypeInfo _: TypeInfoOptions,
                                            collisionSource: @autoclosure () -> CollisionSource) {
    // TODO: put type TypeInfo
    let valueVariant: _ValueVariant
    if let newValue {
      valueVariant = .value(newValue)
    } else if preserveNilValues {
      valueVariant = .nilInstance(typeOfWrapped: V.self)
    } else {
      return
    }
    
    _storage.appendResolvingCollisions(key: key,
                                       value: valueVariant,
                                       insertIfEqual: insertIfEqual,
                                       collisionSource: collisionSource())
  }
  
  // SE-0352 Implicitly Opened Existentials
  // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md
  
  // SE-0375 Opening existential arguments to optional parameters
  
  internal mutating func _addExistentialNil(key: Key,
                                            preserveNilValues: Bool,
                                            insertIfEqual: Bool,
                                            collisionSource: @autoclosure () -> CollisionSource) {
    // TODO: put type TypeInfo
    let valueVariant: _ValueVariant
    if preserveNilValues {
      valueVariant = .nilInstance(typeOfWrapped: (any ErrorInfoValueType).self)
    } else {
      return
    }
    
    _storage.appendResolvingCollisions(key: key,
                                       value: valueVariant,
                                       insertIfEqual: insertIfEqual,
                                       collisionSource: collisionSource())
  }
}
