//
//  IsEqualEqatableExistential.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 26/11/2025.
//

extension ErrorInfoFuncs {
  /// Optional values can not be passed as args.
  /// Pevented by compiler as Optional doesn't conform to CustomStringConvertible, so `any ErrorInfoValueType` is guaranteed to be non-optional,
  @inlinable @inline(__always) // 2.5%-5.5% speedup.
  public static func isEqualEqatableExistential(a: any ErrorInfoValueType, b: any ErrorInfoValueType) -> Bool {
    // Unpack existentials for type casting and comparing
    __PrivateImps._isEqualEqatableExistential(a: a, b: b)
  }
}

extension ErrorInfoFuncs.__PrivateImps {
  @inlinable @inline(__always)
  internal static func _isEqualEqatableExistential<A: Equatable>(a: A, b: some Equatable) -> Bool {
    guard let b = b as? A else { return false }
    return a == b
  }
}
