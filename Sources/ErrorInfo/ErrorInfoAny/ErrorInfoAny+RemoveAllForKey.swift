//
//  ErrorInfoAny+RemoveAllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - Remove All Records For Key

extension ErrorInfoAny {
  @discardableResult
  public mutating func removeAllRecords(forKey literalKey: StringLiteralKey) -> ValuesForKey<ValueType>? {
    removeAllRecords(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func removeAllRecords(forKey dynamicKey: String) -> ValuesForKey<ValueType>? {
    _storage.removeAllRecords_ReturningNonNilValues(forKey: dynamicKey)
  }
}
