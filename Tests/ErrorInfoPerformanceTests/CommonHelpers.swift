//
//  CommonHelpers.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 04/01/2026.
//

import ErrorInfo

extension ErrorInfo {
  @inline(never) @_optimize(none)
  func stubValue(forKey _: String) -> ValueExistential? { nil }
}
