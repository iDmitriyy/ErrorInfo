//
//  ErrorInfoAny+Optional.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 20/12/2025.
//

// MARK: - Equatable OptionalAnyValue

extension ErrorInfoAny {
  /// An equatable, type‑erased optional wrapper used by `ErrorInfoAny`.
  ///
  /// Values are flattened so `Optional(Optional(x))` is treated as a single optional. Equality rules:
  /// - Two `.value` cases compare using structural equality by value for `Equatable` conformers.
  /// - Two `.nilInstance` cases are equal when their wrapped types are the same.
  /// - `.value` and `.nilInstance` are never equal.
  @usableFromInline
  internal struct EquatableOptionalAny: Equatable, ErrorInfoOptionalRepresentable {
    typealias Wrapped = Any
    typealias TypeOfWrapped = any Any.Type
    
    let maybeValue: ErrorInfoOptionalAny
    
    private init(_unverifiedMaybeValue: ErrorInfoOptionalAny) {
      maybeValue = _unverifiedMaybeValue
    }
    
    init(anyValue: any Any) {
      maybeValue = ErrorInfoFuncs.flattenOptional(any: anyValue)
    }
    
    static func value(_ anyValue: Any) -> Self {
      Self(anyValue: anyValue)
    }
    
    static func nilInstance(typeOfWrapped: any Any.Type) -> Self {
      // FIXME: - type can be incorrect, extract root type
      Self(_unverifiedMaybeValue: .nilInstance(typeOfWrapped: typeOfWrapped))
    }
    
    var isValue: Bool { maybeValue.isValue }
    
    var getWrapped: Any? { maybeValue.getWrapped }
    
    @usableFromInline
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.maybeValue, rhs.maybeValue) {
      case (.value, .nilInstance),
           (.nilInstance, .value):
        false
        
      case let (.value(lhsInstance), .value(rhsInstance)):
        // As `Any` instances are flattened in EquatableOptionalAny's initializer, call
        // _isEqualFlattenedExistentialAnyWithUnboxing func.
        ErrorInfoFuncs.__PrivateImps._isEqualFlattenedExistentialAnyWithUnboxing(a: lhsInstance, b: rhsInstance)
        
      case let (.nilInstance(lhsType), .nilInstance(rhsType)):
        lhsType == rhsType
      }
    }
  }
}

// MARK: - OptionalAnyValue

/// A type‑erased optional representation used by `ErrorInfoAny`.
///
/// - `.value(Any)`: Holds a concrete value.
/// - `.nilInstance(typeOfWrapped:)`: Represents an explicit `nil` for the given wrapped type.
///
/// # Example
/// ```swift
/// let value: ErrorInfoOptionalAny = .value(123)
/// let nilInstance: ErrorInfoOptionalAny = .nilInstance(typeOfWrapped: String.self)
///
/// value.isValue          // true
/// nilInstance.getWrapped // nil
/// ```
public enum ErrorInfoOptionalAny: ErrorInfoOptionalRepresentable {
  case value(Any)
  case nilInstance(typeOfWrapped: any Any.Type)
  
  public typealias TypeOfWrapped = any Any.Type
  
  var isValue: Bool {
    switch self {
    case .value: true
    case .nilInstance: false
    }
  }
  
  var getWrapped: Any? {
    switch self {
    case .value(let value): value
    case .nilInstance: nil
    }
  }
}
