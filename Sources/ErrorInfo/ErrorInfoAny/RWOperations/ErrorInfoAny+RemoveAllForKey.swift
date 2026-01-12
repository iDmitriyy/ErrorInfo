//
//  ErrorInfoAny+RemoveAllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - Remove All Records For Key

extension ErrorInfoAny {
  @discardableResult
  public mutating func removeAllRecords(forKey literalKey: StringLiteralKey) -> ItemsForKey<ValueExistential>? {
    removeAllRecords(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func removeAllRecords(forKey dynamicKey: String) -> ItemsForKey<ValueExistential>? {
    // FIXME: - imp
    return nil
    // _storage.removeAllRecords_ReturningNonNilValues(forKey: dynamicKey)
  }
}
