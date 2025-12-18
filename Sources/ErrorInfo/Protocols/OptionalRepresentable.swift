//
//  OptionalRepresentable.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

/// A lightweight abstraction over Optional-like values used by ErrorInfo.
///
/// Conforming types represent either a concrete value (`Wrapped`) or a typed
/// `nil` that preserves the intended wrapped type (`TypeOfWrapped`). This lets
/// higher-level APIs filter non-nil values while keeping type information for
/// missing values.
protocol ErrorInfoOptionalRepresentable {
  /// The underlying non-optional value type.
  associatedtype Wrapped
  /// A type that identifies `Wrapped` when constructing a typed `nil`
  associatedtype TypeOfWrapped
  
  /// Creates an instance that contains the given value.
  static func value(_: Wrapped) -> Self
  /// Creates a typed `nil` for the given wrapped type.
  static func nilInstance(typeOfWrapped: TypeOfWrapped) -> Self
  
  /// Returns the wrapped value, or `nil` if this instance represents a typed `nil`.
  var getWrapped: Wrapped? { get }
  
  /// Returns `true` if this instance contains a value; `false` if it is a typed `nil`.
  var isValue: Bool { get } // TODO: - check perfomance with inlining
}

extension ErrorInfoOptionalRepresentable {
//  @inlinable @inline(__always) var isNil: Bool { !isValue }
}

