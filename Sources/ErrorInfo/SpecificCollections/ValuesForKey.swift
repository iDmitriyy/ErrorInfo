//
//  ValuesForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

private import enum SwiftyKit.Either
import NonEmpty

/// NonEmpty collection.
/// Stores 1 element inline or a heap allocated NonEmptyArray of elements.
public struct ValuesForKey<Value>: Sequence {
  private let _elements: Either<Value, NonEmptyArray<Value>>
  
  internal init(element: Value) { _elements = .left(element) }
  
  internal init(array: NonEmptyArray<Element>) {
    if array.count > 1 {
      _elements = .right(array)
    } else {
      _elements = .left(array.first)
    }
  }
  
  public var first: Value {
    switch _elements {
    case .left(let element): element
    case .right(let elements): elements.first
    }
  }
  
  public var count: Int {
    switch _elements {
    case .left: 1
    case .right(let elements): elements.count
    }
  }
  
  // Improvement: should be NonEmptySlice<Array<Value>> instead of Slice<NonEmptyArray<Value>>
  public var _destrctured: (first: Value, others: Slice<NonEmptyArray<Value>>?) {
    switch _elements {
    case .left(let element): (element, nil)
    case .right(let elements): (elements.first, elements[1...])
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
      return if let transformed = NonEmptyArray(base: elements.compactMap(transform)) {
        ValuesForKey<U>(array: transformed)
      } else {
        nil
      }
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
  public init(__array: NonEmptyArray<Element>) { _elements = .right(__array) }
}

// public struct ValuesForKeySlice<Value>: Sequence { or OrderedMultipleValuesForKeyStorageSlice
//  private let _slice: Either<DiscontiguousSlice<A>, DiscontiguousSlice<B>>
// }
