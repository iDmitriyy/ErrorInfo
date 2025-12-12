//
//  LegacyErrorInfo+ToDictionary.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 12/12/2025.
//

extension LegacyErrorInfo {
  public init(_ info: [String: Any]) {
    _storage = KeyAugmentationErrorInfoGeneric(info)
  }
}

extension LegacyErrorInfo {
  public func asDictionary() -> [String: Any] {
    _storage._storage
  }
}
