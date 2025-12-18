//
//  OptionalUtils.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - Flatten Optional

extension ErrorInfoFuncs {
  /// Recursively flattens nested optional values into a single `ErrorInfoOptionalAny`.
  ///
  /// This function takes a value of any type and recursively unwraps nested optionals.
  /// If the value is `nil`, it returns a `nilInstance` case with the `Wrapped` type.
  /// If the value is `non-optional`, it is returned directly as a `value` case of the `ErrorInfoOptionalAny` enum.
  ///
  /// - Parameter any: A value of any type, potentially containing nested optionals.
  /// - Returns: An `ErrorInfoOptionalAny` enum representing the flattened value:
  ///   - `.value`: If the value is non-optional or the final unwrapped value is found.
  ///   - `.nilInstance`: If the value is `nil` or the final unwrapped value is `nil`.
  public static func flattenOptional<T>(any: T) -> ErrorInfoOptionalAny {
    if let optionalExistential = any as? any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol {
      switch optionalExistential.getSelf() {
      case .some(let wrapped):
        return flattenOptional(any: wrapped)
      case .none:
        let rootWrappedType = __PrivateImps._getRootWrappedType(anyType: optionalExistential.getStaticWrrappedType())
        return .nilInstance(typeOfWrapped: rootWrappedType)
      }
    } else {
      return .value(any)
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Type Of Wrapped

extension ErrorInfoFuncs {
  /// Returns the type of value wrapped to `Any` existential, or the `Wrapped` type of an optional inside `Any` existential.
  ///
  /// If the passed argument is an optional type, it recursively extracts the `Wrapped` type.
  /// For non-optional values, it returns the type of the value itself.
  ///
  /// ## Parameters:
  /// - `any`: The value whose wrapped type is to be determined. This can be an optional type or any other type.
  ///
  /// ## Example:
  /// ```swift
  /// let value = Optional<Optional<Optional<Any>>>.some(.some(.some("" as Any))))
  /// typeOfWrapped(any: value) // Returns `String`
  /// ```
  public static func typeOfWrapped<T>(any: T) -> any Any.Type {
    if let optionalExistential = any as? any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol {
      switch optionalExistential.getSelf() {
      case .some(let wrapped):
        return typeOfWrapped(any: wrapped)
      case .none:
        return __PrivateImps._getRootWrappedType(anyType: optionalExistential.getStaticWrrappedType())
      }
    } else {
      // returning here type(of: any) can return `Any` for value like this: Optional<Any>.some("")
      // however, when passed to function which calls `type(of: any)` ubser the hood, then `String` is returned.
      return __PrivateImps._dynamicType(ofNonOptionalAny: any)
    }
  }
}

extension ErrorInfoFuncs.__PrivateImps {
  fileprivate static func _dynamicType(ofNonOptionalAny nonOptionalAny: Any) -> any Any.Type {
    type(of: nonOptionalAny)
  }
  
  /// When passed value is `nil`, we can not get type of values. In this extract `Wrapped` type from the most nested Optional type.
  fileprivate static func _getRootWrappedType(anyType: any Any.Type) -> any Any.Type {
    if let optionalType = anyType as? (any FlattenableOptionalPrivateProtocol.Type) {
      return _getRootWrappedType(anyType: optionalType.getStaticWrrappedType())
    } else {
      return anyType
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Helper Protocol

extension ErrorInfoFuncs.__PrivateImps {
  /// **Only `Swift.Optional` must conform to this protocol**.
  /// A protocol that provides methods to inspect and extract the `Wrapped` type of optional value.
  /// Needed for `typeOfWrapped<T>(any: T)` function.
  ///
  /// ## Methods:
  /// - `getStaticWrappedType()`: Returns the static type of the wrapped value (i.e., the type inside the optional).
  /// - `getSelf()`: Returns the optional instance itself.
  fileprivate protocol FlattenableOptionalPrivateProtocol<Wrapped> {
    associatedtype Wrapped
      
    static func getStaticWrrappedType() -> Wrapped.Type
    
    func getStaticWrrappedType() -> Wrapped.Type
    
    func getSelf() -> Wrapped?
  }
}

extension Optional: ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol {
  fileprivate static func getStaticWrrappedType() -> Wrapped.Type { Wrapped.self }
  
  fileprivate func getStaticWrrappedType() -> Wrapped.Type { Wrapped.self }
  
  fileprivate func getSelf() -> Wrapped? { self }
}
