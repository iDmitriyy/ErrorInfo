//
//  OrderedMultipleValuesForKeyStorage.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 05/10/2025.
//

internal import enum SwiftyKit.Either
private import struct OrderedCollections.OrderedDictionary

/// The main purpose of this type is reducing the overhead which `OrderedMultiValueDictionary` has.
///
/// Almost all time Error info instances has 1 value for each key. Until first collision happens, `OrderedDictionary` is used.
/// When first collision happens, `OrderedDictionary` is replaced by `OrderedMultiValueDictionary`.
@usableFromInline
internal struct OrderedMultipleValuesForKeyStorage<Key: Hashable, Value, CollisionSource> {
  @inlinable internal var _variant: Variant { _muatbleVariant._variant }
  
  // FIXME: private set
  @usableFromInline internal var _muatbleVariant: _Variant
  
  internal init() {
    _muatbleVariant = _Variant(.left(OrderedDictionary()))
  }
}

extension OrderedMultipleValuesForKeyStorage: Sendable where Key: Sendable, Value: Sendable, CollisionSource: Sendable {}

extension OrderedMultipleValuesForKeyStorage {
  internal func hasValue(forKey key: Key) -> Bool {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.hasValue(forKey: key)
    case .right(let multiValueForKeyDict): multiValueForKeyDict.hasValue(forKey: key)
    }
  }
}

// MARK: All Values For Key

extension OrderedMultipleValuesForKeyStorage {
  // TODO: perfomance test allValues vs allValuesSlice
  internal func allValuesSlice(forKey key: Key) -> (some Sequence<WrappedValue>)? { // & ~Escapable
    ValuesForKeySlice(_variant: _variant, key: key)
  }
  
  internal func allValues(forKey key: Key) -> ValuesForKey<WrappedValue>? {
    switch _variant {
    case .left(let singleValueForKeyDict):
      if let valueForKey = singleValueForKeyDict[key] {
        ValuesForKey(element: WrappedValue.value(valueForKey))
      } else {
        nil
      }
    case .right(let multiValueForKeyDict):
      multiValueForKeyDict.allValues(forKey: key)
    }
  }
  
  @discardableResult
  internal mutating func removeAllValues(forKey key: Key) -> ValuesForKey<WrappedValue>? {
    _muatbleVariant.withResultMutateUnderlying(singleValueForKey: { singleValueForKeyDict in
      if let oldValue = singleValueForKeyDict.removeValue(forKey: key) {
        ValuesForKey(element: WrappedValue.value(oldValue))
      } else {
        nil
      }
    }, multiValueForKey: { multiValueForKeyDict in
      multiValueForKeyDict.removeAllValues(forKey: key)
    })
  }
}

// MARK: Append KeyValue

extension OrderedMultipleValuesForKeyStorage {
  internal mutating func append(key: Key,
                                value: Value,
                                collisionSource: @autoclosure () -> CollisionSource) {
    _muatbleVariant.append(key: key, value: value, collisionSource: collisionSource())
  }
  
  public mutating func append(_ newElement: (Key, Value), collisionSource: @autoclosure () -> CollisionSource) {
    append(key: newElement.0, value: newElement.1, collisionSource: collisionSource())
  }
}

extension OrderedMultipleValuesForKeyStorage {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _muatbleVariant.mutateUnderlying(singleValueForKey: { singleValueForKeyDict in
      singleValueForKeyDict.removeAll(keepingCapacity: keepCapacity)
    }, multiValueForKey: { multiValueForKeyDict in
      multiValueForKeyDict.removeAll(keepingCapacity: keepCapacity)
    })
  }
}

// TODO: using of inlining seems reasonable only internally. For public types like ErrorInfo dynamic disptach might be ok
// as it is fasr.
