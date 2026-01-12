//
//  ErrorInfoAny+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

extension ErrorInfoAny {
  public func allValues(forKey dynamicKey: String) -> ItemsForKey<ValueExistential>? {
    _storage.allNonNilValues(forKey: dynamicKey)
  }
}
