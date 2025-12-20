//
//  ErrorInfo+Optional.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - Equatable OptionalAnyValue

extension ErrorInfo {
  /// An internal, equatable wrapper for optional `ValueProtocol` existentials.
  ///
  /// Used by `ErrorInfo` to uniformly compare values when enforcing ``ValueDuplicatePolicy``.
  /// Equality semantics:
  /// - `.value(lhs)` equals `.value(rhs)` when the underlying `ValueProtocol` values are equal.
  /// - `.nilInstance(T)` equals `.nilInstance(U)` only if `T == U`.
  /// - `.value` never equals `.nilInstance`.
  @usableFromInline internal struct EquatableOptionalAnyValue: Sendable, Equatable, ErrorInfoOptionalRepresentable {
    @usableFromInline internal let maybeValue: OptionalAnyValue
    
    internal static func value(_ value: ValueExistential) -> Self {
      Self(maybeValue: .value(value))
    }
    
    internal static func nilInstance(typeOfWrapped: any Sendable.Type) -> Self {
      Self(maybeValue: .nilInstance(typeOfWrapped: typeOfWrapped))
    }
    
    @usableFromInline var getWrapped: (ValueExistential)? { maybeValue.getWrapped }
    
    var isValue: Bool { maybeValue.isValue }
    
    @usableFromInline
    @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.maybeValue, rhs.maybeValue) {
      case (.value, .nilInstance),
           (.nilInstance, .value):
        false
        
      case let (.value(lhsInstance), .value(rhsInstance)):
        ErrorInfoFuncs.isEqualEqatableExistential(a: lhsInstance, b: rhsInstance)
        
      case let (.nilInstance(lhsType), .nilInstance(rhsType)):
        lhsType == rhsType
      }
    } // inlining has 5% perfomance gain. Will not be called often in practice
  }
}

// MARK: - OptionalAnyValue

extension ErrorInfo {
  /// A type‑erased optional container for `ErrorInfo` values.
  ///
  /// Represents either a concrete value (`.value`) or an explicit `nil` for a specific wrapped type (`.nilInstance`).
  ///
  /// - Note: The wrapped type of a `nil` instance is preserved for diagnostics and duplicate handling.
  ///
  /// # Example
  /// ```swift
  /// let a: ErrorInfo.OptionalAnyValue = .value(42 as Int)
  /// let b: ErrorInfo.OptionalAnyValue = .nilInstance(typeOfWrapped: String.self)
  ///
  /// a.isNil  // false
  /// b.isNil  // true
  ///
  /// b.getWrapped // 42
  /// b.getWrapped // nil
  /// ```
  public enum OptionalAnyValue: Sendable {
    case value(any ValueProtocol)
    case nilInstance(typeOfWrapped: any Sendable.Type)
    
    public var getWrapped: (any ValueProtocol)? {
      switch self {
      case .value(let value): value
      case .nilInstance: nil
      }
    } // inlining has no effect on perfomance
    
    public var isValue: Bool {
      switch self {
      case .value: true
      case .nilInstance: false
      }
    } // inlining has no effect on perfomance
    
    public var isNil: Bool {
      switch self {
      case .value: false
      case .nilInstance: true
      }
    } // inlining has no effect on perfomance
  }
}

// DEFERRED: - add DebugStringConvertible

