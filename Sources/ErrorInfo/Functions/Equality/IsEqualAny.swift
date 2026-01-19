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
    if T.self is AnyObject.Type, type(of: lhs) != type(of: rhs) {
      return false
    }
    
    let lhsFlattened = flattenOptional(any: lhs)
    let rhsFlattened = flattenOptional(any: rhs)
    
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
  
  @inlinable @inline(__always)
  public static func isEqualAny2<T, U>(_ lhs: T, _ rhs: U) -> Bool {
    // if T.self is AnyObject.Type, type(of: lhs) != type(of: rhs) {
    //    return false
    // }
    
    //    let lhsFlattened = ErrorInfoOptionalAny.value(lhs) // flattenOptional(any: lhs)
    //    let rhsFlattened = ErrorInfoOptionalAny.value(rhs) // flattenOptional(any: rhs)
    //
    //    return switch (lhsFlattened, rhsFlattened) {
    //    case (.value, .nilInstance),
    //         (.nilInstance, .value):
    //      false
    //
    //    case let (.value(lhsInstance), .value(rhsInstance)):
    //      __PrivateImps._isEqualFlattenedExistentialAnyWithUnboxing(a: lhsInstance, b: rhsInstance)
    //
    //    case let (.nilInstance(lhsType), .nilInstance(rhsType)):
    //      lhsType == rhsType
    //    }
    
    __PrivateImps._isEqualFlattenedExistentialAnyWithUnboxing(a: lhs, b: rhs)
//    if let lhs = lhs as? any Hashable, let rhs = rhs as? any Hashable {
//      return AnyHashable(lhs) == AnyHashable(rhs)
//    }
//    if let lhs = lhs as? AnyHashable, let rhs = rhs as? AnyHashable {
//      return lhs == rhs
//    }
//    return false
  }
  
  /// For ErrorInfo equatable wrappers.
  ///
  @inlinable @inline(__always)
  public static func _isEqualWithUnboxingAndStdTypesSpecialization<A, B>(_ a: A, _ b: B) -> Bool {
    // ~0 | is ~0 only with A.self == B.self check before _specialize calls and concrete types passed directly.
    // Otherwise _specialize has equal speed to _isEqualWithUnboxing for concrete Equatable types or to Any
    // For values passed as `Any` check A.self == B.self has no impact.
    guard A.self == B.self else { print("????"); return false }
    // (0 as Any, "" as Any) passes check A.self == B.self
    print("____")
    if let intA = _specialize(a, for: Int.self), let intB = _specialize(b, for: Int.self) { // , let intB = b as? Int
      return intA == intB
    }
//    if let intA = _specialize(a, for: Int.self), let intB = b as? Int { // , let intB = b as? Int
//      return intA == intB
//    }
    if let stringA = _specialize(a, for: String.self) {
      let stringB = b as! String
      return stringA == stringB
    }
    if let doubleA = _specialize(a, for: Double.self) {
      let doubleB = b as! Double
      return doubleA == doubleB
    }
    if let boolA = _specialize(a, for: Bool.self) {
      let boolB = b as! Bool
      return boolA == boolB
    }
    if let uintA = _specialize(a, for: UInt.self) {
      let uintB = b as! UInt
      return uintA == uintB
    }
    if let floatA = _specialize(a, for: Float.self) {
      let floatB = b as! Float
      return floatA == floatB
    }
    
    // Range
    
    // Date
    // URL
    // UUID
    // Decimal
    
    return _isEqualWithUnboxing(a, b)
  }
  
  /// > Fast
  ///
  /// No guard from `nil`:
  /// ```
  /// isEqualWithUnboxing(nil as Int?, nil as UInt?)
  /// //  true
  /// ```
  /// No classes
  @inlinable @inline(__always)
  public static func _isEqualWithUnboxing<A, B>(_ a: A, _ b: B) -> Bool {    
    guard let a = a as? any Equatable else { return false }
    
    func _isEqual<EqA: Equatable>(_ equatableA: EqA) -> Bool {
        guard let equatableB = b as? EqA else { return false }
        return equatableA == equatableB
    }
    return _isEqual(a)
  }
}

extension ErrorInfoFuncs.__PrivateImps {
  /// Compares two flattened `Any` values for equality, with unboxing for type-specific comparison.
  ///
  /// - Note: This function only works when both values conform to `Equatable` and are of the same type.
  ///         If `a` and `b` are of different types, the function will immediately return `false`.
  @inlinable @inline(__always)
  internal static func _isEqualFlattenedExistentialAnyWithUnboxing<A, B>(a: A, b: B) -> Bool {
    // affect perf of Optional vs nonOptional. Not affect eq vs noneq.
    guard A.self == B.self else { return false } // significantly improve performance
    
    // if let int1 = _specialize(a, for: Int.self) { // ~0
    //   let int2 = unsafeBitCast(b, to: Int.self)
    //   return int1 == int2
    // }
    
    guard let a = a as? any Equatable else { return false }
    
    func _isEqual<EqA: Equatable>(_ equatableA: EqA) -> Bool {
        guard let equatableB = b as? EqA else { return false }
        return equatableA == equatableB
    }
    return _isEqual(a)
//    return _isEqualOneEquatableExistentialWithUnboxing(a: a, b: b)
  }
    
//  @inlinable @inline(__always)
//  internal static func _isEqualOneEquatableExistentialWithUnboxing<A: Equatable, B>(a: A, b: B) -> Bool {
//    guard let b = b as? A else { return false }
//    return a == b
//  }
}

// https://forums.swift.org/t/comparing-two-any-values-for-equality-is-this-the-simplest-implementation/73816
