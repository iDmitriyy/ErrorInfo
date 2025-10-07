//
//  OrderedMultiValueErrorInfoGeneric+PartialCollection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

extension OrderedMultiValueErrorInfoGeneric {
  internal var count: Int { _storage.count }
  
  internal var isEmpty: Bool { _storage.isEmpty }
    
  public func makeIterator() -> some IteratorProtocol<Element> {
    var sourceIterator = _storage.makeIterator()
    return AnyIterator {
      if let (key, valueWrapper) = sourceIterator.next() {
        (key, valueWrapper)
      } else {
        nil
      }
    }
  }
}
