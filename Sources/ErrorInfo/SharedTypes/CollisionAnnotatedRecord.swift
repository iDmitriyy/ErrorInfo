//
//  CollisionAnnotatedRecord.swift
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
/// let value = CollisionAnnotatedRecord.value(42)
///
/// // Creating a value with a collision source
/// let collidedValue = CollisionAnnotatedRecord.collidedValue(42, collisionSource: .onCreateWithDictionaryLiteral)
/// ```
public struct CollisionAnnotatedRecord<Record>: CustomDebugStringConvertible {
  public let record: Record
  @usableFromInline internal let _collisionSource: HeapBox<CollisionSource>?
  
  @inlinable
  @inline(__always)
  public var collisionSource: CollisionSource? { _collisionSource?.wrapped }
  
  /// CollisionSource memory footprint is quite large. memoryLayout size == 33, stride == 40 at the moment of writing.
  /// Consuming additional 40 bytes for each value, where in fact collisionSource mostly often is nil, is ineffective.
  /// Thats why store optional HeapBox, which takes only 8 bytes (64-bit pointer)
  
  @inlinable
  @inline(__always)
  internal init(value: Record, collisionSource: CollisionSource?) {
    record = value
    _collisionSource = collisionSource.map(HeapBox.init) // TODO: check prefomnace when using if-let
  }
  
  @inlinable
  @inline(__always) // 50x speedup
  internal static func value(_ value: Record) -> Self { Self(value: value, collisionSource: nil) }
  
  @inlinable
  @inline(__always) // 6x speedup
  internal static func collidedValue(_ value: Record, collisionSource: CollisionSource) -> Self {
    Self(value: value, collisionSource: collisionSource)
  }
  
  public var debugDescription: String {
    if let source = collisionSource {
      "(record: {\(String(reflecting: record))}, collisionSource: \(String(reflecting: source)))"
    } else {
      "(record: {\(String(reflecting: record)))}"
    }
  }
}

extension CollisionAnnotatedRecord: Sendable where Record: Sendable {}

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
