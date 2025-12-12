//
//  CollisionTaggedValue.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 28/11/2025.
//

// MARK: - Value + Collision Wrapper

/// A structure that stores a value alongside an optional collision source, used to track values
/// that may have collided in a merging process.
///
/// ## Type Parameters:
/// - `Value`: The type of the value being stored.
/// - `CollisionSource`: The type of the source where the collision occurred, if any.
///
/// ## Memory Optimization:
/// To minimize memory overhead, the `CollisionSource` is stored using a `HeapBox`, which ensures
/// that the source is only allocated when needed. If the collision source is `nil`, the storage
/// is more efficient (only 8 bytes for the `HeapBox` pointer).
///
/// ## Example:
/// ```swift
/// // Creating a value with no collision source
/// let value = CollisionTaggedValue.value(42)
///
/// // Creating a value with a collision source
/// let collidedValue = CollisionTaggedValue.collidedValue(42, collisionSource: .onCreateWithDictionaryLiteral)
/// ```
public struct CollisionTaggedValue<Value, CollisionSource> {
  public let value: Value
  public var collisionSource: CollisionSource? { _collisionSource?.wrapped }
  
  /// CollisionSource memory footprint is quite large. memoryLayout size == 33, stride == 40 at the moment of writing.
  /// Consuming additional 40 bytes for each value, where in fact collisionSource mostly often is nil, is ineffective.
  /// Thats why store optional HeapBox, which takes only 8 bytes (64-bit pointer)
  @usableFromInline internal let _collisionSource: HeapBox<CollisionSource>?
  
  @inlinable @inline(__always)
  internal init(value: Value, collisionSource: CollisionSource?) {
    self.value = value
    self._collisionSource = collisionSource.map(HeapBox.init)
  }
  
  @inlinable @inline(__always) // 50x speedup
  internal static func value(_ value: Value) -> Self { Self(value: value, collisionSource: nil) }
  
  @inlinable @inline(__always) // 6x speedup
  internal static func collidedValue(_ value: Value, collisionSource: CollisionSource) -> Self {
    Self(value: value, collisionSource: collisionSource)
  }
}

extension CollisionTaggedValue: Sendable where Value: Sendable, CollisionSource: Sendable {}

// MARK: - HeapBox

/// A lightweight box that wraps a value on the heap. Used internally to store collision sources
/// with minimal memory overhead, only allocating memory when necessary.
@usableFromInline internal final class HeapBox<T> {
  @usableFromInline internal let wrapped: T
  
  @usableFromInline
  internal init(_ wrapped: T) {
    self.wrapped = wrapped
  } // inlining has no effect on perfomance
}

extension HeapBox: Sendable where T: Sendable {}
