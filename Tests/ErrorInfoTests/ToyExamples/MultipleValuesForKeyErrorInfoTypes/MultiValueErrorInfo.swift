//
//  MultiValueErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import ErrorInfo
import OrderedCollections

/// If a key collision happens, the values are put into a container
struct MultiValueErrorInfo: IterableErrorInfo {
  typealias Key = String
  typealias Value = any ErrorInfoValueType
  typealias Element = (key: Key, value: Value)
  
  private typealias MultiValueStorage = OrderedMultiValueErrorInfoGeneric<Key, Value>
  
  private var _storage: MultiValueStorage
  
  init() {
    _storage = MultiValueStorage()
  }
  
  func makeIterator() -> some IteratorProtocol<Element> {
    var iterator = _storage.makeIterator()
    return AnyIterator {
      guard let (key, warppedValue) = iterator.next() else { return nil }
      return (key, warppedValue.value)
    }
  }
  
  mutating func addResolvingCollisions(key: Key, value: Value, omitEqualValue omitIfEqual: Bool = true) {
    _storage.appendResolvingCollisions(key: key, value: value, omitEqualValue: omitIfEqual,
                                       collisionSource: .onSubscript) // TODO: collisionSource
  }
}
