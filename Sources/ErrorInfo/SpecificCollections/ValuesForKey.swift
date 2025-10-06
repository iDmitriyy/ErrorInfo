//
//  ValuesForKey.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

private import enum SwiftyKit.Either

/// Store 1 element inline or heap allocated array.
public struct ValuesForKey<Value>: Sequence { // TODO: may consume slices. Need improvements or make it also slice
  @usableFromInline internal let _elements: Either<Value, Array<Value>>
  
  @inlinable
  @inline(__always)
  internal init(element: Value) { _elements = .left(element) }
  
  @inlinable
  @inline(__always)
  internal init(array: Array<Element>) { _elements = .right(array) }
  
  public func makeIterator() -> some IteratorProtocol<Value> {
    switch _elements {
    case .left(let element): AnyIterator(CollectionOfOne(element).makeIterator())
    case .right(let elements): AnyIterator(elements.makeIterator())
    }
  }
}

//public struct ValuesForKeySlice<Value>: Sequence { or OrderedMultipleValuesForKeyStorageSlice
//  private let _slice: Either<DiscontiguousSlice<A>, DiscontiguousSlice<B>>
//}
