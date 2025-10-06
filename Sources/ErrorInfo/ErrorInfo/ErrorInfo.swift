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
  
  // FIXME: private(set)
  internal var _storage: BackingStorage
  
  fileprivate init(storage: BackingStorage) {
    self._storage = storage
  }
  
  public init() {
    self.init(storage: BackingStorage())
  }
}

// MARK: Get / Set

extension ErrorInfo {  
  public subscript(_: Key) -> (Value)? {
    get { fatalError() }
    set(maybeValue) {}
  }
  
  func _getUnderlyingValue(forKey _: Key) -> (any ValueType)? {
    _storage.keyValuesView(shouldOmitEqualValue: true)
    return nil
  }
  
  mutating func _addResolvingCollisions(key: Key, value: any ValueType, omitEqualValue: Bool) {
    // Here values are added by ErrorInfo subscript, so use subroutine of root merge-function to put value into storage, which
    // adds a random suffix if collision occurs
    // Pass unmodified key
    // shouldOmitEqualValue = true, in ccomparison to addKeyPrefix function.
//    ErrorInfoDictFuncs.Merge
//      ._putResolvingWithRandomSuffix(value,
//                                     assumeModifiedKey: key,
//                                     shouldOmitEqualValue: true, // TODO: explain why
//                                     suffixFirstChar: ErrorInfoMerge.suffixBeginningForSubcriptScalar,
//                                     to: &_storage)
    _storage.appendResolvingCollisions(key: key,
                                       value: value,
                                       omitEqualValue: omitEqualValue,
                                       collisionSource: .onSubscript)
  }
}

extension ErrorInfo {
  @discardableResult
  mutating func removeAllValues(forKey key: Key) -> Value? {
    nil
  }
}
