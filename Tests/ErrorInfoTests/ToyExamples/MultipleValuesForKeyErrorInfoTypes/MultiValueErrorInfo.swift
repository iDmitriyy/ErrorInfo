//
//  MultiValueErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import ErrorInfo
import OrderedCollections

/// If a key collision happens, the values are put into a container
//struct MultiValueErrorInfo: IterableErrorInfo {
//  typealias Key = String
//  typealias Value = ErrorInfo.ValueExistential
//  typealias Element = (key: Key, value: Value)
//  
//  private typealias MultiValueStorage = OrderedMultiValueErrorInfoGeneric<Key, Value>
//  
//  private var _storage: MultiValueStorage
//  
//  init() {
//    _storage = MultiValueStorage()
//  }
//  
//  func makeIterator() -> some IteratorProtocol<Element> {
//    var iterator = _storage.makeIterator()
//    return AnyIterator {
//      guard let (key, warppedValue) = iterator.next() else { return nil }
//      return (key, warppedValue.value)
//    }
//  }
//  
//  mutating func addResolvingCollisions(key: Key, value: Value, insertIfEqual: Bool) {
//    _storage.appendResolvingCollisions(key: key, value: value, insertIfEqual: insertIfEqual,
//                                       collisionSource: .onSubscript(keyKind: .dynamic))
//  }
//}
