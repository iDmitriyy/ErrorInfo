//
//  ValueWithCollisionWrapper.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 28/11/2025.
//

// MARK: - Value + Collision Wrapper

public struct ValueWithCollisionWrapper<Value, CollisionSource> {
  public let value: Value
  public let collisionSource: CollisionSource?
  
  @inlinable
  internal init(value: Value, collisionSource: CollisionSource?) {
    self.value = value
    self.collisionSource = collisionSource
  }
  
  @inlinable
  internal static func value(_ value: Value) -> Self { Self(value: value, collisionSource: nil) }
  
  @inlinable
  internal static func collidedValue(_ value: Value, collisionSource: CollisionSource) -> Self {
    Self(value: value, collisionSource: collisionSource)
  }
}

extension ValueWithCollisionWrapper: Sendable where Value: Sendable, CollisionSource: Sendable {}
