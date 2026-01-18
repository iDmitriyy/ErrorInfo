//
//  ErrorInfoAny+RemoveAllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - Remove All Records For Key

extension ErrorInfoAny {
  @discardableResult
  public mutating func removeAllRecords(forKey key: String) -> ItemsForKey<OptionalValue>? {
    _storage.removeAllRecordsReturningOptionalInstances(forKey: key)
  }
}

