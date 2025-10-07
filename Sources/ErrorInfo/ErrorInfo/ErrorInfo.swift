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
  public static let empty: Self = Self()
  
  // TODO: should CollisionSource be stored in BackingStorage? mostly always CollisionSource is nil
  // may be BackingStorage should keep a separate dict for keeping CollisionSource instances
  // check memory consuption for both cases
  // Do it after all Slices will be comlpeted, askeeping collisionSource in separate dict need a way to somehow
  // store relation between values in slice and collision sources.
  internal typealias BackingStorage = OrderedMultiValueErrorInfoGeneric<String, any ValueType>
  public typealias ValueWrapper = ValueWithCollisionWrapper<any ValueType, CollisionSource>
  
  // FIXME: private(set)
  internal var _storage: BackingStorage
  
  fileprivate init(storage: BackingStorage) {
    _storage = storage
  }
  
  public init() {
    self.init(storage: BackingStorage())
  }
  
  public init(minimumCapacity: Int) {
    self.init(storage: BackingStorage(minimumCapacity: minimumCapacity))
  }
}

// TODO: check if there runtime issues with unavailable setter. If yes then make deprecated
// TODO: ? make subscript as a defualt imp in protocol, providing a way to override implementation at usage site
extension ErrorInfo {
  public subscript(key: Key, omitEqualValue: Bool = true) -> (any ValueType)? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get { allValues(forKey: key)?.first.value }
    set {
      let value: any ValueType = if let newValue {
        newValue
      } else {
        "nil"
      }
      _add(key: key, value: value, omitEqualValue: omitEqualValue, collisionSource: .onSubscript)
    }
  }
}

// MARK: All Values For Key

extension ErrorInfo {
  // public func allValuesSlice(forKey key: Key) -> (some Sequence<Value>)? {}
  
  public func allValues(forKey key: Key) -> ValuesForKey<ValueWrapper>? {
    _storage.allValues(forKey: key)
  }
  
  @discardableResult
  public mutating func removeAllValues(forKey key: Key) -> ValuesForKey<ValueWrapper>? {
    _storage.removeAllValues(forKey: key)
  }
}

// MARK: Append KeyValue

extension ErrorInfo {
  /// Append value resolving collisions if there is already a value for given key.
  public mutating func append(key: Key, value: any ValueType, omitEqualValue: Bool = true) {
    _add(key: key, value: value, omitEqualValue: omitEqualValue, collisionSource: .onAppend)
  }
  
  public mutating func append(_ newElement: (Key, any ValueType), omitEqualValue: Bool = true) {
    append(key: newElement.0,
           value: newElement.1,
           omitEqualValue: omitEqualValue)
  }
  
  public mutating func append(key: Key, optionalValue: (any ValueType)?, omitEqualValue: Bool, addTypeInfo: TypeInfoOptions_) {
    // FIXME: ? add dynamic type when needed
    
    let finalValue: any ValueType
    if let value = optionalValue {
      // TODO: check if it is an optional if someone conformed Optional to CustomStringConvertible
      finalValue = value
      // switch addTypeInfo {
      // case .always: // where should it be contained? might be in a separate dictionary, not BackingStorage
      // case .whenNil:
      // }
    } else {
//      switch addTypeInfo {
//      case .always: finalValue = prettyDescriptionOfOptional(any: optionalValue)
//      case .whenNil: finalValue = prettyDescriptionOfOptional(any: optionalValue)
//      }
    }
    
    _add(key: key, value: finalValue, omitEqualValue: omitEqualValue, collisionSource: .onAppend)
  }
  
  public mutating func append(key: Key, valueIfNotNil value: (any ValueType)?, omitEqualValue: Bool) {
    guard let value else { return }
    append(key: key, value: value, omitEqualValue: omitEqualValue)
  }
}

extension ErrorInfo {
  internal mutating func _add(key: Key,
                              value: any ValueType,
                              omitEqualValue: Bool,
                              collisionSource: @autoclosure () -> CollisionSource) {
    _storage.appendResolvingCollisions(key: key,
                                       value: value,
                                       omitEqualValue: omitEqualValue,
                                       collisionSource: collisionSource())
  }
}

extension ErrorInfo {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _storage.removeAll(keepingCapacity: keepCapacity)
  }
}
