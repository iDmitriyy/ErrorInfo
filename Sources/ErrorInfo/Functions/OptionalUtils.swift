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
//  @usableFromInline
  @inlinable @inline(__always)
  public static func flattenOptional<T>(any: T) -> ErrorInfoOptionalAny {
    if let optionalExistential = any as? any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol {
      switch optionalExistential.getSelf() {
      case .some(let wrapped):
        return flattenOptional(any: wrapped)
      case .none:
        let rootWrappedType = getRootWrappedType(anyType: optionalExistential.getStaticWrappedType())
        return .nilInstance(typeOfWrapped: rootWrappedType)
      }
    } else {
      return .value(any)
    }
  }
  
  @inlinable @inline(__always)
  public static func flattenOptional_1<T>(any: T) -> ErrorInfoOptionalAny {
    if !(T.self is any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol.Type) {
      return .value(any)
    }
    
    if let optionalExistential = any as? any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol {
      switch optionalExistential.getSelf() {
      case .some(let wrapped):
        return flattenOptional_1(any: wrapped)
      case .none:
        let rootWrappedType = getRootWrappedType(anyType: optionalExistential.getStaticWrappedType())
        return .nilInstance(typeOfWrapped: rootWrappedType)
      }
    } else {
      return .value(any)
    }
  }
  
  @inlinable @inline(__always)
  public static func flattenOptional_22<T>(any maybeValue: T?) -> ErrorInfoOptionalAny {
    if let value = maybeValue {
//      if !(T.self is any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol.Type) {
//        return .value(value)
//      } else {
//        return flattenOptional_2(any: value)
//      }
      if let optionalExistential = maybeValue as? any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol {
        return flattenOptional_2_conformed(instance: optionalExistential)
      } else {
        return .value(value)
      }
    } else {
      let rootWrappedType = getRootWrappedType_2(anyType: T.self)
      return .nilInstance(typeOfWrapped: rootWrappedType)
    }
  }
    
  @inlinable @inline(__always)
  public static func flattenOptional_2<T>(any: T) -> ErrorInfoOptionalAny {
    if !(T.self is any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol.Type) {
      return .value(any)
    }

    if let optionalExistential = any as? any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol {
      return flattenOptional_2_conformed(instance: optionalExistential)
    } else {
      return .value(any)
    }
  }
  
  @inlinable @inline(__always)
  internal static func flattenOptional_2_conformed<C>(instance: C)
  -> ErrorInfoOptionalAny where C: ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol {
    switch instance.getSelf() {
    case .some(let wrapped):
      return flattenOptional_2(any: wrapped)

    case .none:
      let rootWrappedType = getRootWrappedType_2(anyType: instance.getStaticWrappedType())
      return .nilInstance(typeOfWrapped: rootWrappedType)
    }
  }
  
//  @inlinable @inline(__always)
//  internal static func flattenOptional_2_conformed(
//    instance: any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol
//  )
//  -> ErrorInfoOptionalAny {
//    switch instance.getSelf() {
//    case .some(let wrapped):
//      return flattenOptional_2(any: wrapped)
//
//    case .none:
//      let rootWrappedType = getRootWrappedType(anyType: instance.getStaticWrappedType())
//      return .nilInstance(typeOfWrapped: rootWrappedType)
//    }
//  }
    
  @inlinable @inline(__always)
  public static func test(_ value: (some Any)?) -> ErrorInfoOptionalAny {
    flattenOptional_22(any: value)
  }
  
  // TODO: - try to reduce count of casts, making arg optionall: any: T => any: T?
  // in most cases there is no nesting
  // https://forums.swift.org/t/how-to-dynamically-check-if-a-type-conforms-to-value-of-type/49118/2
  
  @usableFromInline
  internal static func flattenOptional(anySendable: some Sendable) -> Either<any Sendable, any Sendable.Type> {
    if let optionalExistential = anySendable as? any ErrorInfoFuncs.__PrivateImps.FlattenableSendableOptionalPrivateProtocol {
      switch optionalExistential.getSendableSelf() {
      case .some(let wrapped):
        return flattenOptional(anySendable: wrapped)
      case .none:
        let rootWrappedType = __PrivateImps
          ._getSendableRootWrappedType(anyType: optionalExistential.getStaticWrappedSendableType())
        return .right(rootWrappedType)
      }
    } else {
      return .left(anySendable)
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
        return getRootWrappedType(anyType: optionalExistential.getStaticWrappedType())
      }
    } else {
      // returning here type(of: any) can return `Any` for value like this: Optional<Any>.some("")
      // however, when passed to function which calls `type(of: any)` under the hood, then `String` is returned.
      return __PrivateImps._dynamicType(ofNonOptionalAny: any)
    }
  }
  
  /// When passed value is `nil`, we can not get type of values. In this extract `Wrapped` type from the most nested Optional type.
//  internal
  @inlinable @inline(__always)
  public static func getRootWrappedType(anyType: any Any.Type) -> any Any.Type {
    if let optionalType = anyType as? (any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol.Type) {
      return getRootWrappedType(anyType: optionalType.getStaticWrappedType())
    } else {
      return anyType // TODO: - check is it enough or need to call _dynamicType(ofNonOptionalAny:)
    }
  }
  
  @inlinable @inline(__always)
  public static func getRootWrappedType_2<T>(anyType: T.Type) -> any Any.Type { // improved
    if let optionalType = anyType as? (any ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol.Type) {
      return getRootWrappedType(anyType: optionalType.getStaticWrappedType())
    } else {
      return anyType // TODO: - check is it enough or need to call _dynamicType(ofNonOptionalAny:)
    }
  }
}

extension ErrorInfoFuncs.__PrivateImps {
  internal static func _dynamicType(ofNonOptionalAny nonOptionalAny: Any) -> any Any.Type {
    type(of: nonOptionalAny)
  }
  
  fileprivate static func _getSendableRootWrappedType(anyType: any Sendable.Type) -> any Sendable.Type {
    if let optionalType = anyType as? (any FlattenableSendableOptionalPrivateProtocol.Type) {
      return _getSendableRootWrappedType(anyType: optionalType.getStaticWrappedSendableType())
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
  @usableFromInline internal protocol FlattenableOptionalPrivateProtocol<Wrapped> {
    associatedtype Wrapped
      
    static func getStaticWrappedType() -> Wrapped.Type
    
    func getStaticWrappedType() -> Wrapped.Type
    
    func getSelf() -> Wrapped?
  }
  
  @usableFromInline internal protocol FlattenableSendableOptionalPrivateProtocol<Wrapped>: Sendable {
    associatedtype Wrapped: Sendable
      
    static func getStaticWrappedSendableType() -> Wrapped.Type
    
    func getStaticWrappedSendableType() -> Wrapped.Type
    
    func getSendableSelf() -> Wrapped?
  }
}

extension Optional: ErrorInfoFuncs.__PrivateImps.FlattenableOptionalPrivateProtocol {
  @inlinable @inline(__always) internal static func getStaticWrappedType() -> Wrapped.Type { Wrapped.self }
  
  @inlinable @inline(__always) internal func getStaticWrappedType() -> Wrapped.Type { Wrapped.self }
  
  @inlinable @inline(__always) internal func getSelf() -> Wrapped? { self }
}

extension Optional: ErrorInfoFuncs.__PrivateImps.FlattenableSendableOptionalPrivateProtocol {
  @usableFromInline internal static func getStaticWrappedSendableType() -> Wrapped.Type { Wrapped.self }
  
  @usableFromInline internal func getStaticWrappedSendableType() -> Wrapped.Type { Wrapped.self }
  
  @usableFromInline internal func getSendableSelf() -> Wrapped? { self }
}
