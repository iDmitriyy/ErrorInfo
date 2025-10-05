//
//  OrderedMultipleValuesForKeyStorage+Typealiases.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

internal import enum SwiftyKit.Either
internal import struct OrderedCollections.OrderedDictionary

extension OrderedMultipleValuesForKeyStorage {
  internal typealias SingleValueForKeyDict = OrderedDictionary<Key, Value>
  
  internal typealias WrappedValue = ValueWithCollisionWrapper<Value, CollisionSource>
  internal typealias MultiValueForKeyDict = OrderedMultiValueDictionary<Key, WrappedValue>
  
  internal typealias Variant = Either<SingleValueForKeyDict, MultiValueForKeyDict>
  
  internal typealias Element = (key: Key, value: WrappedValue)
  
  internal typealias Index = Int
}
