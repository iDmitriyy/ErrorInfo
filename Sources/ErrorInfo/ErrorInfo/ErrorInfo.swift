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
  public static let empty: Self = Self()
  
  internal typealias BackingStorage = OrderedMultiValueErrorInfoGeneric<String, any ValueType>
  public typealias ValueWrapper = ValueWithCollisionWrapper<any ValueType, StringBasedCollisionSource>
  
  // FIXME: private(set)
  internal var _storage: BackingStorage
  
  fileprivate init(storage: BackingStorage) {
    self._storage = storage
  }
  
  public init() {
    self.init(storage: BackingStorage())
    // reserve capacity
    // init minimumCapacity
  }
}

extension ErrorInfo {
  public subscript(_: Key) -> (Value)? {
    get { fatalError() }
    set(maybeValue) {}
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
  mutating func appendResolvingCollisions(key: Key, value: any ValueType, omitEqualValue: Bool) {
    _storage.appendResolvingCollisions(key: key,
                                       value: value,
                                       omitEqualValue: omitEqualValue,
                                       collisionSource: .onSubscript)
  }
  
  mutating func appendResolvingCollisions(_ newElement: (Key, any ValueType), omitEqualValue: Bool) {
    appendResolvingCollisions(key: newElement.0,
                              value: newElement.1,
                              omitEqualValue: omitEqualValue)
  }
}

extension ErrorInfo {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _storage.removeAll(keepingCapacity: keepCapacity)
  }
}
