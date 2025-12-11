//
//  CollisionTaggedValue.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 28/11/2025.
//

// MARK: - Value + Collision Wrapper

public struct CollisionTaggedValue<Value, CollisionSource> {
  public let value: Value
  public var collisionSource: CollisionSource? { _collisionSource?.wrapped }
  
  /// CollisionSource memory footprint is quite large. memoryLayout size == 33, stride == 40 at the moment of writing.
  /// Consuming 40bytes for each value where in fact collisionSource mostly often is nil is ineffective.
  /// Thats why store optional HeapBox, which takes only 8 bytes (64-bit pointer)
  @usableFromInline internal let _collisionSource: HeapBox<CollisionSource>?
  
  @inlinable @inline(__always)
  public init(value: Value, collisionSource: CollisionSource?) {
    self.value = value
    self._collisionSource = collisionSource.map(HeapBox.init)
  }
  
  @inlinable @inline(__always) // 50x speedup
  public static func value(_ value: Value) -> Self { Self(value: value, collisionSource: nil) }
  
  @inlinable @inline(__always) // 6x speedup
  internal static func collidedValue(_ value: Value, collisionSource: CollisionSource) -> Self {
    Self(value: value, collisionSource: collisionSource)
  }
}

extension CollisionTaggedValue: Sendable where Value: Sendable, CollisionSource: Sendable {}


@usableFromInline internal final class HeapBox<T> {
  @usableFromInline internal let wrapped: T
  
  @usableFromInline internal init(_ wrapped: T) { // inlining has no effect for perfomance
    self.wrapped = wrapped
  }
}

extension HeapBox: Sendable where T: Sendable {}
