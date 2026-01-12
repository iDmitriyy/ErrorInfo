//
//  ErrorInfo+HasValueForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: - HasValue For Key

extension ErrorInfo {
  public func hasValue(forKey key: String) -> Bool {
    _storage.hasNonNilValue(forKey: key)
  }
  
  public func hasRecord(forKey key: String) -> Bool {
    _storage.hasRecord(forKey: key)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Has Multiple Records For Key

extension ErrorInfo {
  public func hasMultipleRecords(forKey key: String) -> Bool {
    _storage.hasMultipleRecords(forKey: key)
  }
  
  public func hasMultipleRecordsForAtLeastOneKey() -> Bool {
    _storage.hasMultipleRecordsForAtLeastOneKey()
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - KeyValue Lookup Result

extension ErrorInfo {
  public func keyValueLookupResult(forKey key: String) -> KeyValueLookupResult {
    _storage.keyValueLookupResultIncludingNil(forKey: key)
  }
}
