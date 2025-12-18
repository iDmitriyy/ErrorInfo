//
//  NonEmptyOrderedIndexSet.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/10/2025.
//

internal import typealias SwiftCollectionsNonEmpty.NonEmptyOrderedSet

// MARK: - NonEmpty Ordered IndexSet

/// A compact, non-empty set of ordered indices.
///
/// In most cases, Error-info types contain 1 value for a given key. T
/// This index set is optimized for the common case of a single index: stores one index inline and switches to a
/// heap-backed `NonEmptyOrderedSet` only when a second index is inserted.
/// Used by `OrderedMultiValueDictionary` to track positions of multiple values per key
/// without paying heap costs for the single-value case.
///
/// Example
/// ```swift
/// var indices = NonEmptyOrderedIndexSet.single(index: 2)
/// indices.first        // 2
/// Array(indices)       // [2]
/// indices.insert(5)
/// Array(indices)       // [2, 5]
/// ```
@usableFromInline internal struct NonEmptyOrderedIndexSet: Sendable, RandomAccessCollection {
  @usableFromInline typealias Element = Int
  
  internal private(set) var _variant: _Variant
  
  /// Creates a non-empty set containing a single index stored inline.
  internal static func single(index: Int) -> Self {
    Self(_variant: .single(index: index))
  }
  
  /// Always zero.
  @usableFromInline internal var startIndex: Int { 0 }
  
  /// 1 when a single index is stored; otherwise the count of the heap-backed orderedS set.
  @usableFromInline internal var endIndex: Int {
    switch _variant {
    case .single: 1
    case .multiple(let indices): indices.endIndex
    }
  }
  
  /// The first stored index.
  // var first: Element {
  //   switch _variant {
  //   case .single(let index): index
  //   case .multiple(let indices): indices.first
  //   }
  // }
  
  /// Accesses the index at `position`.
  /// - Precondition: `position` is within bounds.
  @usableFromInline internal subscript(position: Int) -> Element {
    switch _variant {
    case .single(let index):
      switch position {
      case 0: return index
      default: preconditionFailure("Index \(position) is out of bounds")
      }
    case .multiple(let indices):
      return indices.base[position]
    }
  }
  
  /// Inserts `newIndex`, preserving order of insertion.
  /// Switches to heap-backed storage on the first insertion beyond one element.
  internal mutating func insert(_ newIndex: Int) {
    switch _variant {
    case .single(let currentIndex):
      _variant = .multiple(indices: NonEmptyOrderedSet<Int>(elements: currentIndex, newIndex))
    case .multiple(var elements):
      elements.append(newIndex) // FIXME: remove cow of elements
      _variant = .multiple(indices: elements)
    }
  }
  
  /// Builds a `RangeSet` of indices relative to `collection`.
  internal func asRangeSet<C>(for collection: C) -> RangeSet<Int> where C: Collection, C.Index == Int {
    switch _variant {
    case let .single(index): RangeSet(CollectionOfOne(index), within: collection) // TODO: check for CollectionOfOne
    case let .multiple(indices): RangeSet(indices, within: collection)
    }
  }
}

extension NonEmptyOrderedSet<Int> {
  /// Builds a `RangeSet` of indices relative to `collection`.
  internal func asRangeSet<C>(for collection: C) -> RangeSet<Int> where C: Collection, C.Index == Int {
    RangeSet(self, within: collection)
  }
}

extension NonEmptyOrderedIndexSet {
  /// Storage variant: inline single index or heap-backed non-empty orderedS set.
  internal enum _Variant: Sendable {
    case single(index: Int)
    case multiple(indices: NonEmptyOrderedSet<Int>)
  }
}

// TODO: - perfomance checks
