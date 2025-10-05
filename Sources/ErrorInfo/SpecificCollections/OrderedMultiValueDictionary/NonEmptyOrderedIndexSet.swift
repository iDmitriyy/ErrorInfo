//
//  NonEmptyOrderedIndexSet.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 05/10/2025.
//

internal import typealias SwiftCollectionsNonEmpty.NonEmptyOrderedSet

// MARK: - NonEmpty Ordered IndexSet

/// Introduced for implementing OrderedMultiValueDictionary. In most cases, Error-info types contain 1 value for a given key.
/// When there are multiple values for key, multiple indices are also stored.
/// This `NonEmpty Ordered IndexSet` stores single index inlined as a value type. h
/// Heap allocated OrderedSet is only created when there are 2 or more indices.
internal struct NonEmptyOrderedIndexSet: RandomAccessCollection {
  typealias Element = Int
  
  internal private(set) var _storage: Storage
  
  internal static func single(index: Int) -> Self {
    Self(_storage: .single(index: index))
  }
  
  internal var startIndex: Int { 0 }
  
  internal var endIndex: Int {
    switch _storage {
    case .single: 1
    case .multiple(let indices): indices.endIndex
    }
  }
  
  var first: Element {
    switch _storage {
    case .single(let index): index
    case .multiple(let indices): indices.first
    }
  }
  
  internal subscript(position: Int) -> Element {
    switch _storage {
    case .single(let index):
      switch position {
      case 0: return index
      default: preconditionFailure("Index \(position) is out of bounds")
      }
    case .multiple(let indices):
      return indices.base[position]
    }
  }
  
  internal mutating func insert(_ newIndex: Int) {
    switch _storage {
    case .single(let currentIndex):
      _storage = .multiple(indices: NonEmptyOrderedSet<Int>(elements: currentIndex, newIndex))
    case .multiple(var elements):
      elements.append(newIndex) // TODO: remove cow of elements
      _storage = .multiple(indices: elements)
    }
  }
    
  @available(*, deprecated, message: "not optimal")
  internal var _asHeapNonEmptyOrderedSet: NonEmptyOrderedSet<Int> { // TODO: confrom Sequence protocol instead of this
    switch _storage {
    case let .single(index): NonEmptyOrderedSet<Int>(element: index)
    case let .multiple(indices): indices
    }
  }
  
  internal func asRangeSet<C>(for collection: C) -> RangeSet<Int> where C: Collection, C.Index == Int {
    switch _storage {
    case let .single(index): RangeSet(CollectionOfOne(index), within: collection)
    case let .multiple(indices): RangeSet(indices, within: collection)
    }
  }
}

extension NonEmptyOrderedIndexSet {
  internal enum Storage {
    case single(index: Int)
    case multiple(indices: NonEmptyOrderedSet<Int>)
  }
}
