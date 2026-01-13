//
//  ErrorInfo+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: - AllValues ForKey

extension ErrorInfo {
  public func allValues(forKey key: String) -> ItemsForKey<ValueExistential>? {
    _storage.allNonNilValues(forKey: key)
  }
}
