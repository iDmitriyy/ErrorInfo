//
//  ErrorInfo+RemoveAllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

// MARK: - Remove All Records For Key

extension ErrorInfo {
  @discardableResult
  public mutating func removeAllRecords(forKey key: String) -> ItemsForKey<OptionalValue>? {
    _storage.removeAllRecordsReturningOptionalInstances(forKey: key)
  } // inlining worsen performance
  
  // faster but lead to overload resolution problems
  // public mutating func removeAllRecords(forKey key: String) {
  //   _storage.removeAllRecords(forKey: key)
  // }
}
