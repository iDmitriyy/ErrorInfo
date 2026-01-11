//
//  ErrorInfo+HasValueForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: - HasValue For Key

extension ErrorInfo {
  public func hasValue(forKey literalKey: StringLiteralKey) -> Bool {
    hasValue(forKey: literalKey.rawValue)
  }
  
  public func hasValue(forKey key: String) -> Bool {
    _storage.hasNonNilValue(forKey: key)
  }
  
  public func hasRecord(forKey literalKey: StringLiteralKey) -> Bool {
    hasRecord(forKey: literalKey.rawValue)
  }
  
  public func hasRecord(forKey key: String) -> Bool {
    _storage.hasSomeValue(forKey: key)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Has Multiple Records For Key

extension ErrorInfo {
  public func hasMultipleRecords(forKey literalKey: StringLiteralKey) -> Bool {
    hasMultipleRecords(forKey: literalKey.rawValue)
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

extension ErrorInfo {
  public func keyValueLookupResult(forKey literalKey: StringLiteralKey) -> KeyValueLookupResult {
    keyValueLookupResult(forKey: literalKey.rawValue)
  }
  
  public func keyValueLookupResult(forKey key: String) -> KeyValueLookupResult {
    // FIXME: instead of _storage.allValues(forKey: key) smth like
    // _storage.iterateWithResult(forKey: key), to eliminate allocations
    // on the other side, allValues(forKey:) should be quite fast.
    
    _storage.keyValueLookupResultIncludingNil(forKey: key)
  }
}
