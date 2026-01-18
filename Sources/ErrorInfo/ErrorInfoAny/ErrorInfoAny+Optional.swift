//
//  ErrorInfoAny+Optional.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 20/12/2025.
//

// MARK: - Equatable OptionalAnyValue

extension ErrorInfoAny {
  public typealias OptionalValue = ErrorInfoOptionalAny
  
  /// An equatable, type‑erased optional wrapper used by `ErrorInfoAny`.
  ///
  /// Enables safe, predictable equality comparisons for optional values, flattening nested optionals and ensuring
  /// type-safe equality, avoiding issues like type mismatches or undefined behavior.
  ///
  /// - Note: Flattening occurs during the initialization of the `EquatableOptionalAny` instance.
  ///   After initialization, instances can be compared for equality with each other.
  ///
  /// Values are flattened so `Optional(Optional(x))` is treated as a single optional. Equality rules:
  /// - Two `.value` cases compare using structural equality by value for `Equatable` conformers.
  /// - Two `.nilInstance` cases are equal when their wrapped types are the same.
  /// - `.value` and `.nilInstance` are never equal.
  @usableFromInline
  @frozen
  internal struct EquatableOptionalAny: Equatable, ErrorInfoOptionalRepresentableEquatable, CustomDebugStringConvertible {
    @usableFromInline typealias Wrapped = Any
    @usableFromInline typealias TypeOfWrapped = any Any.Type
    
    @usableFromInline
    let instanceOfOptional: ErrorInfoOptionalAny
    
    private init(_unverifiedOptionalInstance: ErrorInfoOptionalAny) {
      instanceOfOptional = _unverifiedOptionalInstance
    }
    
    private init(anyValue: Any) {
      instanceOfOptional = ErrorInfoFuncs.flattenOptional(any: anyValue)
    }
    
    @usableFromInline
    static func value(_ anyValue: Any) -> Self {
      Self(anyValue: anyValue)
    }
    
    @usableFromInline
    static func nilInstance(typeOfWrapped: any Any.Type) -> Self {
      let type = ErrorInfoFuncs.getRootWrappedType(anyType: typeOfWrapped)
      return Self(_unverifiedOptionalInstance: .nilInstance(typeOfWrapped: type))
    }
    
    @usableFromInline
    var isValue: Bool { instanceOfOptional.isValue }
    
    @usableFromInline
    var isNil: Bool { instanceOfOptional.isValue }
    
    @usableFromInline
    var getWrapped: Any? { instanceOfOptional.getWrapped }
    
    @usableFromInline
    var debugDescription: String { instanceOfOptional.debugDescription }
    
    @usableFromInline
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.instanceOfOptional, rhs.instanceOfOptional) {
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
@frozen
public enum ErrorInfoOptionalAny: ErrorInfoOptionalRepresentable, CustomDebugStringConvertible {
  public typealias TypeOfWrapped = any Any.Type
  
  case value(Any)
  case nilInstance(typeOfWrapped: any Any.Type)
  
  public var isValue: Bool {
    switch self {
    case .value: true
    case .nilInstance: false
    }
  }
  
  public var isNil: Bool {
    switch self {
    case .nilInstance: true
    case .value: false
    }
  }
  
  public var getWrapped: Any? {
    switch self {
    case .value(let value): value
    case .nilInstance: nil
    }
  }
  
  public var debugDescription: String {
    switch self {
    case .value(let value): "value(\(String(reflecting: value)))"
    case .nilInstance(let type): "nilInstance<\(type)>"
    }
  }
}
