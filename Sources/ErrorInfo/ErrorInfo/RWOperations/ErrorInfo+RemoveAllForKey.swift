//
//  ErrorInfo+RemoveAllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

// MARK: - Remove All Records For Key

extension ErrorInfo {
  @discardableResult
  public mutating func removeAllRecords(forKey literalKey: StringLiteralKey) -> ValuesForKey<ValueExistential>? {
    removeAllRecords(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func removeAllRecords(forKey dynamicKey: String) -> ValuesForKey<ValueExistential>? {
    _storage.removeAllRecords_ReturningNonNilValues(forKey: dynamicKey)
  }
}
