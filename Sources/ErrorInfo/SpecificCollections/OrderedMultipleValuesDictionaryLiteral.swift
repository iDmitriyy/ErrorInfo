//
//  OrderedMultipleValuesDictionaryLiteral.swift
//  ErrorInfo
//
//  Created by tmp on 05/10/2025.
//

public struct OrderedMultipleValuesDictionaryLiteral<Key: Hashable, Value>: ExpressibleByDictionaryLiteral {
  internal let dict: OrderedMultiValueDictionary<Key, Value>
  
  public init(dictionaryLiteral elements: (Key, Value)...) {
    var dict = OrderedMultiValueDictionary<Key, Value>()
    for (key, value) in elements {
      dict.append(key: key, value: value)
    }
    self.dict = dict
  }
}


