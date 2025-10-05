//
//  OrderedMultipleValuesForKeyStorage.swift
//  ErrorInfo
//
//  Created by tmp on 05/10/2025.
//

private import enum SwiftyKit.Either
private import struct OrderedCollections.OrderedDictionary

extension OrderedMultipleValuesForKeyStorage {
  internal typealias SingleValueForKeyDict = OrderedDictionary<Key, Value>
  
  internal typealias ValueWrapper = ValueWithCollisionWrapper<Value, CollisionSourceSpecifier>
  internal typealias MultiValueForKeyDict = OrderedMultiValueDictionary<Key, ValueWrapper>
  
  internal typealias Variant = Either<SingleValueForKeyDict, MultiValueForKeyDict>
  
  internal typealias Element = (key: Key, values: ValuesForKey)
}

/// Reduces the overhead which `OrderedMultiValueDictionary` has.
/// Almost all time Error info instances has single value for ech key. Until first collision happens, `OrderedDictionary` is used.
/// When first collision happens, `OrderedDictionary` is replaced by `OrderedMultiValueDictionary`.
internal struct OrderedMultipleValuesForKeyStorage<Key: Hashable, Value> {
  internal var _variant: Variant { _muatbleVariant._variant }
  
  private var _muatbleVariant: _Variant
  
  internal init() {
    self._muatbleVariant = _Variant(.left(OrderedDictionary()))
  }
}

extension OrderedMultipleValuesForKeyStorage: Sendable where Key: Sendable, Value: Sendable {}

// MARK: Mutating methods

extension OrderedMultipleValuesForKeyStorage {
  public mutating func append(key: Key, value: Value, collisionSourceSpecifier: @autoclosure () -> CollisionSourceSpecifier) {
    _muatbleVariant.append(key: key, value: value, collisionSourceSpecifier: collisionSourceSpecifier())
  }
  
  public mutating func removeAllValues(forKey key: Key) {
    _muatbleVariant.mutateUnderlying(singleValueForKey: { dict in
      dict[key] = nil
    }, multiValueForKey: { dict in
      dict.removeAllValues(forKey: key)
    })
  }
  
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _muatbleVariant.mutateUnderlying(singleValueForKey: { dict in
      dict.removeAll(keepingCapacity: keepCapacity)
    }, multiValueForKey: { dict in
      dict.removeAll(keepingCapacity: keepCapacity)
    })
  }
}
