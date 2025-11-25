//
//  IsEqualEqatableExistential.swift
//  ErrorInfo
//
//  Created by tmp on 26/11/2025.
//

extension ErrorInfoFuncs {
  /// No Optional values can be passed as args.
  /// Pevented by compiler as Optional doesn't conform to CustomStringConvertible, so `any ErrorInfoValueType` is guaranteed to be non-optional,
  internal static func isEqualEqatableExistential(a: any ErrorInfoValueType, b: any ErrorInfoValueType) -> Bool {
    _isEqualEqatableExistential(a: a, b: b)
  }
  
  private static func _isEqualEqatableExistential<A: Equatable, B: Equatable>(a: A, b: B) -> Bool {
    guard let b = b as? A else { return false }
    return a == b
  }
}



