//
//  OrderedMultipleValuesForKeyStorage+Typealiases.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 06/10/2025.
//

internal import enum SwiftyKit.Either
internal import struct OrderedCollections.OrderedDictionary

extension OrderedMultipleValuesForKeyStorage {
  // public ACL is for inlining
  public typealias SingleValueForKeyDict = OrderedDictionary<Key, Value>
  
  public typealias WrappedValue = ValueWithCollisionWrapper<Value, CollisionSource>
  public typealias MultiValueForKeyDict = OrderedMultiValueDictionary<Key, WrappedValue>
  
  public typealias Variant = Either<SingleValueForKeyDict, MultiValueForKeyDict>
  
  public typealias Element = (key: Key, value: WrappedValue)
  
  public typealias Index = Int
}
