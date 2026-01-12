//
//  ErrorInfoAny+KeyValueLookup.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - HasValue For Key

extension ErrorInfoAny {
  public func hasValue(forKey key: String) -> Bool {
    _storage.hasNonNilValue(forKey: key)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Has Multiple Records For Key

extension ErrorInfoAny {
  public func hasRecord(forKey key: String) -> Bool {
    _storage.hasRecord(forKey: key)
  }
  
  public func hasMultipleRecords(forKey key: String) -> Bool {
    _storage.hasMultipleRecords(forKey: key)
  }
  
  public func hasMultipleRecordsForAtLeastOneKey() -> Bool {
    _storage.hasMultipleRecordsForAtLeastOneKey()
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - KeyValue Lookup Result

extension ErrorInfoAny {  
  public func keyValueLookupResult(forKey key: String) -> KeyValueLookupResult {
    _storage.keyValueLookupResultIncludingNil(forKey: key)
  }
}
