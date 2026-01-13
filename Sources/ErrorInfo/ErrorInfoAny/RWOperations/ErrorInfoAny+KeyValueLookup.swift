//
//  ErrorInfoAny+KeyValueLookup.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - HasValue For Key

extension ErrorInfoAny {
  public func hasRecord(forKey key: String) -> Bool {
    _storage.hasRecord(forKey: key)
  }
  
  public func recordsCount(forKey key: String) -> Int {
    _storage.recordsCount(forKey: key)
  }
  
  public func containsValue(forKey key: String, where predicate: (OptionalValue) -> Bool) -> Bool {
    _storage.containsValue(forKey: key, where: { predicate($0.instanceOfOptional) })
  }
  
  public func countValues(forKey key: String, where predicate: (OptionalValue) -> Bool) -> Int {
    _storage.countValues(forKey: key, where: { predicate($0.instanceOfOptional) })
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Has Multiple Records For Key

extension ErrorInfoAny {
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
