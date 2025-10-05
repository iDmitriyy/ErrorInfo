//
//  OrderedMultiValueDictionary+ExpressibleByDictionaryLiteral.swift
//  ErrorInfo
//
//  Created by tmp on 05/10/2025.
//

extension OrderedMultiValueDictionary: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init()
    
    for (key, value) in elements {
      self.append(key: key, value: value)
    }
  }
}
