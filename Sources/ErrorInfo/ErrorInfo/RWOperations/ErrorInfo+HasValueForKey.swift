//
//  ErrorInfo+HasValueForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: HasValues ForKey

extension ErrorInfo {
  public func hasValue(forKey literalKey: StringLiteralKey) -> Bool {
    // FIXME: - incorrect semantics, it check for record / entry, not nonoptional value
    // is `hasValue` needed for underlying storage types?
    _storage.hasValue(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func hasValue(forKey key: String) -> Bool {
    // FIXME: -
    _storage.hasValue(forKey: key)
  }
  
  public func hasMultipleRecordsForAtLeastOneKey() -> Bool {
    _storage._storage.hasMultipleValuesForAtLeastOneKey
  }
  
  public func hasMultipleRecords(forKey literalKey: StringLiteralKey) -> Bool {
    hasMultipleRecords(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func hasMultipleRecords(forKey key: String) -> Bool {
    switch keyValueLookupResult(forKey: key) {
    case .nothing, .singleValue: false
    case .multipleRecords: true
    }
  }
}

extension ErrorInfo {
  public enum KeyValueLookupResult {
    case nothing
    case singleValue
    case multipleRecords(valuesCount: UInt16, nilCount: UInt16)
  }
  
  public func keyValueLookupResult(forKey literalKey: StringLiteralKey) -> KeyValueLookupResult {
    keyValueLookupResult(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func keyValueLookupResult(forKey key: String) -> KeyValueLookupResult {
    if let taggedValues = _storage.allValues(forKey: key) {
      var valuesCount: UInt16 = 0
      var nilInstancesCount: UInt16 = 0
      for taggedValue in taggedValues {
        if taggedValue.value.optional.isValue {
          valuesCount += 1
        } else {
          nilInstancesCount += 1
        }
      }
      
      // FIXME: - case singleNil
      if valuesCount > 1 || nilInstancesCount > 1 || (valuesCount == 1 && nilInstancesCount == 1) {
        return .multipleRecords(valuesCount: valuesCount, nilCount: nilInstancesCount)
      } else {
        return .singleValue
      }
    } else {
      return .nothing
    }
  }
}
