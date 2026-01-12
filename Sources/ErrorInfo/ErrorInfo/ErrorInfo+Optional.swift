//
//  ErrorInfo+Optional.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - Equatable OptionalAnyValue

extension ErrorInfo {
  /// An internal, equatable wrapper for optional ``ErrorInfo.ValueProtocol`` existentials.
  ///
  /// Enables safe, predictable equality comparisons for ``ErrorInfo.OptionalValue`` ensuring
  /// type-safe equality, avoiding issues like type mismatches or undefined behavior.
  ///
  /// - Note: Flattening is not needed for `Optional` values here (in comparison to ``ErrorInfoOptionalAny``).
  /// `Swift.Optional` doesn't conform to `CustomStringConvertible` protocol,
  /// which is required by ``ErrorInfo.ValueProtocol``.
  /// Thats why optional value can not be casted as `any ValueProtocol`.
  /// There can exist an `Optional<any ValueProtocol>`, but once this optional
  /// unwrapped, we get `any ValueProtocol` existential, which by itself can not
  /// contain another optional inside.
  ///
  /// Used by ``ErrorInfo`` to uniformly compare values when enforcing ``ValueDuplicatePolicy``.
  /// Equality semantics:
  /// - `.value(lhs)` equals `.value(rhs)` when the underlying `ValueProtocol` values are equal.
  /// - `.nilInstance(T)` equals `.nilInstance(U)` only if `T == U`.
  /// - `.value` never equals `.nilInstance`.
  @usableFromInline
  @frozen
  internal struct EquatableOptionalValue: Sendable, ErrorInfoOptionalRepresentableEquatable,
    CustomDebugStringConvertible {
    
    @usableFromInline
    internal let instanceOfOptional: OptionalValue
    
    @usableFromInline
    static func value(_ value: ValueExistential) -> Self {
      Self(instanceOfOptional: .value(value))
    }
    
    @usableFromInline
    static func nilInstance(typeOfWrapped: any Sendable.Type) -> Self {
      Self(instanceOfOptional: .nilInstance(typeOfWrapped: typeOfWrapped))
    }
    
    @usableFromInline
    var getWrapped: ValueExistential? { instanceOfOptional.getWrapped } // inlining has no effect on performance
    
    @usableFromInline
    var isValue: Bool { instanceOfOptional.isValue } // inlining has no effect on performance
    
    @usableFromInline
    var isNil: Bool { instanceOfOptional.isNil }
    
    @usableFromInline
    var debugDescription: String { instanceOfOptional.debugDescription }
    
    @usableFromInline
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.instanceOfOptional, rhs.instanceOfOptional) {
      case let (.value(lhsInstance), .value(rhsInstance)):
        ErrorInfoFuncs.isEqualEquatableExistential(a: lhsInstance, b: rhsInstance)
        
      case (.value, .nilInstance),
           (.nilInstance, .value):
        false
        
      case let (.nilInstance(lhsType), .nilInstance(rhsType)):
        lhsType == rhsType
      }
    } // inlining has no performance gain.
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
  @frozen
  public enum OptionalValue: Sendable, ErrorInfoOptionalRepresentable, CustomDebugStringConvertible {
    case value(any ValueProtocol)
    case nilInstance(typeOfWrapped: any Sendable.Type)
    
    public var getWrapped: (any ValueProtocol)? {
      switch self {
      case .value(let value): value
      case .nilInstance: nil
      }
    } // inlining has no effect on performance
    
    public var isValue: Bool {
      switch self {
      case .value: true
      case .nilInstance: false
      }
    } // inlining has no effect on performance
    
    public var isNil: Bool {
      switch self {
      case .nilInstance: true
      case .value: false
      }
    } // inlining has no effect on performance
    
    public var debugDescription: String {
      switch self {
      case .value(let value): "value(\(String(reflecting: value)))"
      case .nilInstance(let type): "nilInstance<\(type)>"
      }
    }
  }
}
