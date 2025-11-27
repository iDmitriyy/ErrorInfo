//
//  OrderedMultipleValuesDictionaryLiteral.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 05/10/2025.
//

public struct OrderedMultipleValuesDictionaryLiteral<Key: Hashable, Value>: ExpressibleByDictionaryLiteral {
  internal let dict: OrderedMultipleValuesForKeyStorage<Key, Value, CollisionSource>
  
  public init(dictionaryLiteral elements: (Key, Value)...) {
    var dict = OrderedMultipleValuesForKeyStorage<Key, Value, CollisionSource>()
    for (key, value) in elements {
      dict.append(key: key, value: value, collisionSource: .onCreateWithDictionaryLiteral)
    }
    self.dict = dict
  }
}
