//
//  _Copied.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 10/12/2025.
//

@usableFromInline
@frozen
internal enum Either<L: ~Copyable, R: ~Copyable>: ~Copyable {
  case left(L)
  case right(R)
}

extension Either: Copyable where L: Copyable, R: Copyable {}

extension Either: BitwiseCopyable where L: BitwiseCopyable, R: BitwiseCopyable {}

extension Either: Equatable where L: Equatable, R: Equatable {}

extension Either: Hashable where L: Hashable, R: Hashable {}

extension Either: Sendable where L: Sendable, R: Sendable {}

@inlinable @inline(__always)
internal func mutate<T: ~Copyable, E>(value: consuming T, mutation: (inout T) throws(E) -> Void) throws(E) -> T {
  try mutation(&value)
  return value
}

@available(*, deprecated, message: "use configured(object:) for reference types instead")
@inlinable @inline(__always)
internal func mutate<T: AnyObject, E>(value: consuming T, mutation: (inout T) throws(E) -> Void) throws(E) -> T {
  try mutation(&value)
  return value
}

extension String {
  @inlinable @inline(__always)
  internal init(minimumCapacity: Int) {
    self.init(); reserveCapacity(minimumCapacity)
  }
}

extension Array {
  @inlinable @inline(__always)
  internal init(minimumCapacity: Int) {
    self.init(); reserveCapacity(minimumCapacity)
  }
}

extension String {
  /// Perfomant way to convert StaticString to String
  @inlinable @inline(__always)
  internal init(_ staticString: StaticString) {
    self = String(describing: staticString)
    // under the hood of `description` property the following is used: `withUTF8Buffer { String._uncheckedFromUTF8($0) }`
    // it is the most perfomant way to convert StaticString to StaticString
  }
}
