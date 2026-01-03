//
//  ErrorInfo+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: - AllValues ForKey

extension ErrorInfo {
  public func allValues(forKey literalKey: StringLiteralKey) -> ValuesForKey<ValueExistential>? {
    allValues(forKey: literalKey.rawValue)
  }
  
  public func allValues(forKey dynamicKey: String) -> ValuesForKey<ValueExistential>? {
    _storage.allNonNilValues(forKey: dynamicKey) // TODO: - optimize, 0.02ms
  }
}
