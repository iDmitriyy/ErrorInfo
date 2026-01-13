//
//  IsEqualAny.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 18/12/2025.
//

extension ErrorInfoFuncs {
  /// Compares two values of `Any` type for equality, flattening optional values.
  ///
  /// This function compares two values of any type, handling cases where the values may be optional.
  /// It flattens optional values to compare their underlying values or `nil` state. If both values are
  /// of type `Equatable`, their equality is checked using unboxing techniques to avoid type erasure issues.
  /// If one or both values are `nil`, or of different types, the comparison returns `false`.
  ///
  /// - Parameters:
  ///   - lhs: The first value to compare.
  ///   - rhs: The second value to compare.
  /// - Returns: A Boolean value indicating whether the two values are equal.
  ///
  /// - Example:
  /// ```swift
  /// ErrorInfoFuncs.isEqualAny(a: 5, b: 5)              // true
  /// ErrorInfoFuncs.isEqualAny(a: 5, b: "5")            // false
  /// ErrorInfoFuncs.isEqualAny(a: 5, b: 6)              // false
  /// ErrorInfoFuncs.isEqualAny(a: 5, b: nil)            // false
  /// ErrorInfoFuncs.isEqualAny(a: 5, b: 5 as Int?)      // true
  /// ErrorInfoFuncs.isEqualAny(a: 5, b: 5 as Int??)     // true
  ///
  /// let intNil = nil as Int?
  /// let strNil = nil as String?
  /// ErrorInfoFuncs.isEqualAny(intNil, strNil)    // false
  /// ```
  public static func isEqualAny<T>(_ lhs: T, _ rhs: T) -> Bool {
    let lhsFlattened = flattenOptional(any: lhs)
    let rhsFlattened = flattenOptional(any: rhs)
    
    if T.self is AnyObject.Type {
      // print("_____ AnyObject \(type(of: lhs))")
    }
    
    return switch (lhsFlattened, rhsFlattened) {
    case (.value, .nilInstance),
         (.nilInstance, .value):
      false
      
    case let (.value(lhsInstance), .value(rhsInstance)):
      __PrivateImps._isEqualFlattenedExistentialAnyWithUnboxing(a: lhsInstance, b: rhsInstance)
      
    case let (.nilInstance(lhsType), .nilInstance(rhsType)):
      lhsType == rhsType
    }
  }
}

extension ErrorInfoFuncs.__PrivateImps {
  /// Compares two flattened `Any` values for equality, with unboxing for type-specific comparison.
  ///
  /// - Note: This function only works when both values conform to `Equatable` and are of the same type.
  ///         If `a` and `b` are of different types, the function will immediately return `false`.
  @inlinable @inline(__always)
  internal static func _isEqualFlattenedExistentialAnyWithUnboxing<A, B>(a: A, b: B) -> Bool {
    guard A.self == B.self else { return false } // TODO: check performance
    
    guard let a = a as? any Equatable, let b = b as? any Equatable else { return false }
    // TODO: optimize – cast here only `a`
    return _isEqualExistentialEquatableWithUnboxing(a: a, b: b)
    // return _isEqualOneEquatableExistentialWithUnboxing(a: a, b: b)
  }
  
  @inlinable @inline(__always)
  internal static func _isEqualOneEquatableExistentialWithUnboxing<A: Equatable, B>(a: A, b: B) -> Bool {
    guard let b = b as? A else { return false }
    return a == b
  }
}
