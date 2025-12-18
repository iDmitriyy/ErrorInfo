//
//  ValuesForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

import NonEmpty

/// A `NonEmpty` collection that stores one or more values.
///
/// ## Type Parameters:
/// - `Value`: The type of the value(s) associated with the key.
///
/// ## Performance:
/// `ValuesForKey` is optimized for the case where only a single value is stored, providing fast access.
/// The  case where multiple values are stored still offers efficient access.
///
/// # Example:
/// ```swift
///
/// // A typical case where a single value is stored for the key "error_code".
/// if let values = errorInfo.allValues(forKey: .errorCode) {
///   values.first // "404"
/// }
///
/// // Multiple values are stored for the key "id".
/// if let values = errorInfo.allValues(forKey: .id) {
///   values.first // 17
///   values.last  // "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"
/// }
/// ```
public struct ValuesForKey<Value>: Sequence, RandomAccessCollection {
  @usableFromInline internal let _elements: Either<Value, NonEmptyArray<Value>>
  
  public typealias Index = Int
  
  // MARK: - Initializers
    
  /// Creates a `ValuesForKey` instance with a single value.
  ///
  /// - Parameter element: The value to store.
  @inlinable @inline(__always)
  internal init(element: Value) { _elements = .left(element) }
  
  /// Creates a `ValuesForKey` instance with multiple values.
  ///
  /// - Parameter array: A non-empty array of values to store.
  @inlinable @inline(__always)
  internal init(array: NonEmptyArray<Element>) {
    _elements = .right(array)
  }
  
  // MARK: - Collection Access
  
  /// Accesses the element at the specified index.
  ///
  /// - Parameter position: The index of the element to access.
  /// - Returns: The value at the specified position.
  /// - Precondition: The index must be within bounds (0 for a single value).
  @inlinable @inline(__always) // 10.5x speedup
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
  
  /// The starting index of the collection, always 0.
  @inlinable
  public var startIndex: Int { 0 }
  
  /// The end index of the collection.
  ///
  /// - Returns: 1 for a single value, or the count of the non-empty array for multiple values.
  @inlinable
  public var endIndex: Int {
    switch _elements {
    case .left: 1
    case .right(let elements): elements.endIndex
    }
  } // no speedup for direct access, keep @inlinable to be transparent for compiler
  
  /// The first element in the collection.
  ///
  /// - Returns: The first value stored, whether it's a single value or the first element
  /// in the non-empty array.
  @inlinable @inline(__always) // 13.5x speedup
  public var first: Value {
    switch _elements {
    case .left(let element): element
    case .right(let elements): elements.first
    }
  }
  
  /// The last element in the collection.
  ///
  /// - Returns: The last value stored, whether it's a single value or the last element
  /// in the non-empty array.
  @inlinable @inline(__always) // 13.5x speedup
  public var last: Value {
    switch _elements {
    case .left(let element): element
    case .right(let elements): elements.last
    }
  }
  
  /// The number of elements in the collection.
  ///
  /// - Returns: `1` for a single value or the count of the non-empty array for multiple values.
  @inlinable
  public var count: Int {
    switch _elements {
    case .left: 1
    case .right(let elements): elements.count
    }
  } // no speedup for direct access, keep @inlinable to be transparent for compiler
  
  // MARK: - Transformations
  
  /// Applies a transformation to each value in the collection and returns a new `ValuesForKey`
  /// instance with the transformed values.
  ///
  /// - Parameter transform: A closure that transforms each element.
  /// - Returns: A new `ValuesForKey` instance containing the transformed values.
  /// - Throws: Any error that occurs during the transformation.
  @inlinable
  public func map<T, E>(_ transform: (Self.Element) throws(E) -> T) throws(E) -> ValuesForKey<T> {
    switch _elements {
    case .left(let element): try ValuesForKey<T>(element: transform(element))
    case .right(let elements): try ValuesForKey<T>(array: elements.map(transform))
    }
  }
    
  /// Returns a new `ValuesForKey` instance containing only the non-nil results of applying the transformation closure.
  ///
  /// - Parameter transform: A closure that transforms each element into an optional value.
  /// - Returns: A new `ValuesForKey` instance containing only the non-nil transformed
  /// elements, or `nil` if no valid elements are left.
  @inlinable
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
}

extension ValuesForKey {
  @_spi(PerfomanceTesting)
  @inlinable @inline(__always)
  public init(__element: Value) { self.init(element: __element) }
  
  @_spi(PerfomanceTesting)
  @inlinable @inline(__always)
  public init(__array: NonEmptyArray<Element>) { self.init(array: __array) }
}
