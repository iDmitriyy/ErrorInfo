//
//  CollectionOfTwo.swift
//  ErrorInfo
//
//  Created by tmp on 03/10/2025.
//

internal struct CollectionOfTwo<Element>: RandomAccessCollection {
  private let pair: (first: Element, second: Element)
  
  internal init(_ first: Element, _ second: Element) {
    self.pair = (first, second)
  }
  
  internal var startIndex: Int { 0 }
  internal var endIndex: Int { 2 }
  
  internal subscript(position: Int) -> Element {
    get {
      switch position {
      case 0: return pair.first
      case 1: return pair.second
      default: preconditionFailure("Index is out of range")
      }
    }
  }
}
