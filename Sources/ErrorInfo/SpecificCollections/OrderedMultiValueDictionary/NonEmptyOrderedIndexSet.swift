//
//  NonEmptyOrderedIndexSet.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/10/2025.
//

public import typealias SwiftCollectionsNonEmpty.NonEmptyOrderedSet
internal import struct OrderedCollections.OrderedSet
private import NonEmpty

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
@frozen
public struct NonEmptyOrderedIndexSet: Sendable, RandomAccessCollection {
  public typealias Element = Int
  
  @usableFromInline internal var _variant: Either<Int, NonEmptyOrderedSet<Int>>
    
  /// Creates a non-empty set containing a single index stored inline.
//  @_spi(PerformanceTesting)
  public static func single(index: Int) -> Self {
    Self(_variant: .left(index))
  } // no speedup with inlining
  
  /// Inserts `newIndex`, preserving order of insertion.
  /// Switches to heap-backed storage on the first insertion beyond one element.
  @inlinable
  @inline(__always)
  public mutating func insert(_ newIndex: Int) {
    switch _variant {
    case .left(let currentIndex):
      _variant = .right(NonEmpty(base: OrderedSet(_elements: currentIndex, newIndex))!)
      
    case .right(var elements):
      // On release builds, compiler optimizes CoW here, like it is inout switch / in-place mutation
      elements.append(newIndex)
      _variant = .right(elements)
    }
  }
  
  // MARK: - Collection Protocol Imp
  
  /// Always zero.
  @inlinable
  @inline(__always) // no speedup for direct access with inlining, keep @inlinable to be transparent for compiler
  public var startIndex: Int { 0 }
  
  /// 1 when a single index is stored; otherwise the count of the heap-backed orderedS set.
  // @usableFromInline internal
  public var endIndex: Int {
    switch _variant {
    case .left: 1
    case .right(let indices): indices.endIndex
    }
  } // inlining worsen performance up to 1.7x when single index (case .left). For .right speedup 2%
  
   /// The first stored index.
   public var first: Element {
     switch _variant {
     case .left(let index): index
     case .right(let indices): indices.first
     }
   } // inlining worsen performance up to 1.7x when single index (case .left). For .right speedup 2%
  
  public var last: Element {
    switch _variant {
    case .left(let index): index
    case .right(let indices): indices.last
    }
  }
  
  // public var count: Int {
  //   switch _variant {
  //   case .left: 1
  //   case .right(let indices): indices.base.count
  //   }
  // }
  
  /// Accesses the index at `position`.
  /// - Precondition: `position` is within bounds.
  @_spi(PerformanceTesting)
  public subscript(position: Int) -> Element {
    switch _variant {
    case .left(let index):
      switch position {
      case 0: return index
      default: preconditionFailure("Index \(position) is out of bounds")
      }
    case .right(let indices):
      return indices[position]
    }
  } // inlining worsen performance up to 1.7x when single index (case .left). For .right speedup 2%
}

extension OrderedSet {
  @inlinable // @inline(__always)
  internal init(_element: Element) {
    self.init(uncheckedUniqueElements: [_element])
  }
  
  // Improvement: rename args
  
  @inlinable
  public init(_elements first: Element, _ second: Element) {
    if _fastPath(first != second) {
      self.init(uncheckedUniqueElements: [first, second])
    } else {
      self.init(uncheckedUniqueElements: [first])
    }
  }
}
