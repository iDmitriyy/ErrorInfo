//
//  IsEqualAnyEqatable.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

extension ErrorInfoFuncs {
  /// Including optional. | Any that can be an Optional
  internal static func isEqualAnyEqatable<A: Equatable, B: Equatable>(a: A, b: B) -> Bool {
    // FIXME: optional values
    guard let b = b as? A else { return false }
    return a == b
  }
}
