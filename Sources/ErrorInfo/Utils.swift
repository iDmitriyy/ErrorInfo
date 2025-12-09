//
//  Utils.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

/// https://forums.swift.org/t/runtime-casts-of-sendable-type-to-another-sendable-type-not-possible/82070/2
internal func conditionalCast<T, U>(_ value: T, to _: U.Type) -> U? {
  value as? U
}

extension Optional {
  internal static func typeOfWrapped() -> Wrapped.Type { Wrapped.self }

  internal func typeOfWrapped() -> Wrapped.Type { Wrapped.self }
}
