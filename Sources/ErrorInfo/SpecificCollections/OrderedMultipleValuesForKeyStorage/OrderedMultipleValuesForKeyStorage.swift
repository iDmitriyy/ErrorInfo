//
//  OrderedMultipleValuesForKeyStorage.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 05/10/2025.
//

internal import enum SwiftyKit.Either
private import struct OrderedCollections.OrderedDictionary

/// Reduces the overhead which `OrderedMultiValueDictionary` has.
/// Almost all time Error info instances has single value for ech key. Until first collision happens, `OrderedDictionary` is used.
/// When first collision happens, `OrderedDictionary` is replaced by `OrderedMultiValueDictionary`.
@usableFromInline
internal struct OrderedMultipleValuesForKeyStorage<Key: Hashable, Value> {
  @usableFromInline internal var _variant: Variant { _muatbleVariant._variant }
  
  // FIXME: private set
  @usableFromInline internal var _muatbleVariant: _Variant
  
  internal init() {
    _muatbleVariant = _Variant(.left(OrderedDictionary()))
  }
}

extension OrderedMultipleValuesForKeyStorage: Sendable where Key: Sendable, Value: Sendable {}

// MARK: Get methods

extension OrderedMultipleValuesForKeyStorage {
  func hasValue(forKey key: Key) -> Bool {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.hasValue(forKey: key)
    case .right(let multiValueForKeyDict): multiValueForKeyDict.hasValue(forKey: key)
    }
  }
  
  func allValues(forKey key: Key) -> (some Sequence<WrappedValue>)? { // & ~Escapable
    ValuesForKeySlice(_variant: _variant, key: key)
  }
}

// MARK: Mutating methods

extension OrderedMultipleValuesForKeyStorage {
  @inlinable
  @inline(__always)
  internal mutating func append(key: Key,
                                value: Value,
                                collisionSource: @autoclosure () -> CollisionSource) {
    _muatbleVariant.append(key: key, value: value, collisionSource: collisionSource())
  }
  
  internal mutating func removeAllValues(forKey key: Key) {
    _muatbleVariant.mutateUnderlying(singleValueForKey: { dict in
      dict[key] = nil
    }, multiValueForKey: { dict in
      dict.removeAllValues(forKey: key)
    })
  }
  
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _muatbleVariant.mutateUnderlying(singleValueForKey: { dict in
      dict.removeAll(keepingCapacity: keepCapacity)
    }, multiValueForKey: { dict in
      dict.removeAll(keepingCapacity: keepCapacity)
    })
  }
}
