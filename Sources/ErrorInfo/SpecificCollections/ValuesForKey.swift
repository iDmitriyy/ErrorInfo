//
//  ValuesForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

import NonEmpty

/// NonEmpty collection.
/// Stores 1 element inline or a heap allocated NonEmptyArray of elements.
public struct ValuesForKey<Value>: Sequence, RandomAccessCollection {
  @usableFromInline internal let _elements: Either<Value, NonEmptyArray<Value>>
  
  public typealias Index = Int
  
  @inlinable @inline(__always)
  internal init(element: Value) { _elements = .left(element) }
  
  @inlinable @inline(__always)
  internal init(array: NonEmptyArray<Element>) {
    if array.rawValue.count > 1 {
      _elements = .right(array)
    } else {
      _elements = .left(array.first)
    }
  }
  
  public subscript(position: Int) -> Value {
    switch _elements {
    case .left(let element):
      switch position {
      case 0: return element
      default: preconditionFailure("Index \(position) is out of bounds")
      }
    case .right(let elements):
      return elements[position]
    }
  }
  
  public var startIndex: Int { 0 }
  
  public var endIndex: Int {
    switch _elements {
    case .left: 1
    case .right(let elements): elements.endIndex
    }
  }
    
  public var first: Value {
    switch _elements {
    case .left(let element): element
    case .right(let elements): elements.first
    }
  }
  
  public var last: Value {
    switch _elements {
    case .left(let element): element
    case .right(let elements): elements.last
    }
  }
  
  public var count: Int {
    switch _elements {
    case .left: 1
    case .right(let elements): elements.count
    }
  }
  
  @inlinable public func map<T, E>(_ transform: (Self.Element) throws(E) -> T) throws(E) -> ValuesForKey<T> {
    switch _elements {
    case .left(let element): ValuesForKey<T>(element: try transform(element))
    case .right(let elements): ValuesForKey<T>(array: try elements.map(transform))
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
  
  // TODO: - is it needed now?
  // check iteration speed when having this Iteratpr and default IndexingIterator from RandomAccessCollection
  public func makeIterator() -> some IteratorProtocol<Value> {
    switch _elements {
    case .left(let element): AnyIterator(CollectionOfOne(element).makeIterator())
    case .right(let elements): AnyIterator(elements.makeIterator())
    }
  }
}

// TODO: may consume slices. Need improvements or make it also slice
extension ValuesForKey {
  @_spi(PerfomanceTesting)
  @inlinable @inline(__always)
  public init(__element: Value) { self.init(element: __element) }
  
  @_spi(PerfomanceTesting)
  @inlinable @inline(__always)
  public init(__array: NonEmptyArray<Element>) { self.init(array: __array) }
}

// public struct ValuesForKeySlice<Value>: Sequence { or OrderedMultipleValuesForKeyStorageSlice
//  private let _slice: Either<DiscontiguousSlice<A>, DiscontiguousSlice<B>>
// }
