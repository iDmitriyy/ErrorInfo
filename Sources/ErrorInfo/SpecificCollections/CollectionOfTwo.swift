//
//  CollectionOfTwo.swift
//  ErrorInfo
//
//  Created by tmp on 03/10/2025.
//

/// For storing multiple values
//internal struct CollectionOfTwo<Element>: RandomAccessCollection {
//  private let pair: (first: Element, second: Element)
//  
//  internal init(_ first: Element, _ second: Element) {
//    pair = (first, second)
//  }
//  
//  internal var startIndex: Int { 0 }
//  internal var endIndex: Int { 2 }
//  
//  internal subscript(position: Int) -> Element {
//    switch position {
//    case 0: return pair.first
//    case 1: return pair.second
//    default: preconditionFailure("Index \(position) is out of bounds")
//    }
//  }
//}
