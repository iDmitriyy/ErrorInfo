//
//  OrderedMultipleValuesForKeyStorage+Typealiases.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

public import struct OrderedCollections.OrderedDictionary

extension OrderedMultipleValuesForKeyStorage {
  // public ACL is for inlining
  @usableFromInline internal typealias SingleValueForKeyDict = OrderedDictionary<Key, Value>
  
  public typealias AnnotatedValue = CollisionAnnotatedRecord<Value>
  @usableFromInline internal typealias MultiValueForKeyDict = OrderedMultiValueDictionary<Key, AnnotatedValue>
  
  @usableFromInline internal typealias Variant = Either<SingleValueForKeyDict, MultiValueForKeyDict>
  
  public typealias Element = (key: Key, value: AnnotatedValue)
  
  public typealias Index = Int
}
