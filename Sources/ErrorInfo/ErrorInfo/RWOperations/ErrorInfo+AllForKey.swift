//
//  ErrorInfo+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: - AllValues ForKey

extension ErrorInfo {
  public func allValues(forKey literalKey: StringLiteralKey) -> ItemsForKey<ValueExistential>? {
    allValues(forKey: literalKey.rawValue)
  }
  
  public func allValues(forKey dynamicKey: String) -> ItemsForKey<ValueExistential>? {
    _storage.allNonNilValues(forKey: dynamicKey) // TODO: - optimize, 0.02ms
  }
}
