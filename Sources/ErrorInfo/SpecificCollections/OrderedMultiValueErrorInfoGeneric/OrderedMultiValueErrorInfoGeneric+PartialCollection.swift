//
//  OrderedMultiValueErrorInfoGeneric+PartialCollection.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

extension OrderedMultiValueErrorInfoGeneric: Collection {
  public var count: Int { _storage.count }
  
  public var isEmpty: Bool { _storage.isEmpty }
    
//  public func makeIterator() -> some IteratorProtocol<Element> {
//    var sourceIterator = _storage.makeIterator()
//    return AnyIterator {
//      if let (key, valueWrapper) = sourceIterator.next() {
//        (key, valueWrapper)
//      } else {
//        nil
//      }
//    }
//  }
}

extension OrderedMultiValueErrorInfoGeneric: RandomAccessCollection {
  public var startIndex: Int { _storage.startIndex }
  
  public var endIndex: Int { _storage.endIndex }
  
  public subscript(position: Int) -> Element { _storage[position] }
}
