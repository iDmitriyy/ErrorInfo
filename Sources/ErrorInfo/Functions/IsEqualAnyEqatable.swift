//
//  IsEqualAnyEqatable.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

extension ErrorInfoFuncs {
  // TODO: optional values
  internal static func isEqualAnyEqatable<A: Equatable, B: Equatable>(a: A, b: B) -> Bool {
    guard let b = b as? A else { return false }
    return a == b
  }
}
