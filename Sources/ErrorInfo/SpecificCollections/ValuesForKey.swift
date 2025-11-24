//
//  ValuesForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

private import enum SwiftyKit.Either

/// Store 1 element inline or heap allocated array.
public struct ValuesForKey<Value>: Sequence { // TODO: make nonEmpty
  private let _elements: Either<Value, Array<Value>>
  
  internal init(element: Value) { _elements = .left(element) }
  
  internal init(array: Array<Element>) { _elements = .right(array) }
  
  internal var first: Value {
    switch _elements {
    case .left(let element): return element
    case .right(let elements): return elements.first! // FIXME: forced unwrapping
    }
  }
  
  /// Return nonEmpty instance
  internal func _compactMap<U>(_ transform: (Value) -> U?) -> ValuesForKey<U>? {
    switch _elements {
    case .left(let element):
      return if let transformedElement = transform(element) {
        ValuesForKey<U>(element: transformedElement)
      } else {
        nil
      }
    case .right(let elements):
      let transformedElements = elements.compactMap(transform)
      return transformedElements.isEmpty ? nil : ValuesForKey<U>(array: transformedElements)
    }
  }
  
  public func makeIterator() -> some IteratorProtocol<Value> {
    switch _elements {
    case .left(let element): AnyIterator(CollectionOfOne(element).makeIterator())
    case .right(let elements): AnyIterator(elements.makeIterator())
    }
  }
}

// TODO: may consume slices. Need improvements or make it also slice
extension ValuesForKey {
  @_spi(Testing)
  public init(__element: Value) { _elements = .left(__element) }
  
  @_spi(Testing)
  public init(__array: Array<Element>) { _elements = .right(__array) }
}

//public struct ValuesForKeySlice<Value>: Sequence { or OrderedMultipleValuesForKeyStorageSlice
//  private let _slice: Either<DiscontiguousSlice<A>, DiscontiguousSlice<B>>
//}
