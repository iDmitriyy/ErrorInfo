//
//  ErrorInfoAny+KeyValueLookup.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - HasValue For Key

extension ErrorInfoAny {
  public func hasValue(forKey literalKey: StringLiteralKey) -> Bool {
    hasValue(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload public func hasValue(forKey key: String) -> Bool {
    _storage.hasNonNilValue(forKey: key)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Has Multiple Records For Key

extension ErrorInfoAny {
  public func hasMultipleRecords(forKey literalKey: StringLiteralKey) -> Bool {
    hasMultipleRecords(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload public func hasMultipleRecords(forKey key: String) -> Bool {
    _storage.hasMultipleRecords(forKey: key)
  }
  
  public func hasMultipleRecordsForAtLeastOneKey() -> Bool {
    _storage.hasMultipleRecordsForAtLeastOneKey()
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - KeyValue Lookup Result

extension ErrorInfoAny {
  public func keyValueLookupResult(forKey literalKey: StringLiteralKey) -> KeyValueLookupResult {
    keyValueLookupResult(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload public func keyValueLookupResult(forKey key: String) -> KeyValueLookupResult {
    _storage.keyValueLookupResult_Optional(forKey: key)
  }
}
