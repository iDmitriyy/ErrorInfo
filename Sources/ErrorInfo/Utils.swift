//
//  Utils.swift
//  ErrorInfo
//
//  Created by tmp on 27/10/2025.
//

extension Optional {
  internal static func typeOfWrapped() -> Wrapped.Type { Wrapped.self }

  internal func typeOfWrapped() -> Wrapped.Type { Wrapped.self }
}
