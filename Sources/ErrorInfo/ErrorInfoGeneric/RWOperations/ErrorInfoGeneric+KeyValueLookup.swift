//
//  ErrorInfoGeneric+HasValueForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

// MARK: - HasValue For Key

extension ErrorInfoGeneric {
  public func hasSomeValue(forKey key: Key) -> Bool {
    _storage.hasValue(forKey: key)
  }
}

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  func hasNonNilValue(forKey key: Key) -> Bool {
    switch keyValueLookupResultIncludingNil(forKey: key) {
    case .nothing: false
    case .singleValue: true
    case .singleNil: false
    case .multipleRecords(let valuesCount, _): valuesCount > 0
    }
  }

  // DEFERRED: optimize – for hasNonNilValue / hasNilInstance it is enough to find first value and return early
  
  func hasNilInstance(forKey key: Key) -> Bool {
    switch keyValueLookupResultIncludingNil(forKey: key) {
    case .nothing: false
    case .singleValue: false
    case .singleNil: true
    case .multipleRecords(_, let nilCount): nilCount > 0
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Has Multiple Records For Key

extension ErrorInfoGeneric {
  func hasMultipleRecords(forKey key: Key) -> Bool {
    guard let recordsForKey = _storage.allValues(forKey: key) else { return false }
    return recordsForKey.count > 1
    // TODO: - optimize _storage.hasMultipleValues(forKey: key)
  }
}

extension ErrorInfoGeneric {
  public func hasMultipleRecordsForAtLeastOneKey() -> Bool {
    _storage.hasMultipleValuesForAtLeastOneKey
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - KeyValue Lookup Result

extension ErrorInfoGeneric {
  func keyValueLookupResultIgnoringNil(forKey key: Key) -> KeyNonOptionalValueLookupResult {
    if let taggedRecords = _storage.allValues(forKey: key) {
      let valuesCount = taggedRecords.count
      switch valuesCount {
      case 1: return .singleValue
      default: return .multipleRecords(valuesCount: valuesCount)
      }
    } else {
      return .nothing
    }
  }
}

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  func keyValueLookupResultIncludingNil(forKey key: Key) -> KeyValueLookupResult { // optimized
    switch _storage._variant {
    case .left(let singleValueForKeyDict):
      if let index = singleValueForKeyDict.index(forKey: key) {
        if singleValueForKeyDict.values[index].someValue.isValue {
          return .singleValue
        } else {
          return .singleNil
        }
      } else {
        return .nothing
      }
      
    case .right(let multiValueForKeyDict):
      if let indexSet = multiValueForKeyDict._keyToEntryIndices[key] {
        switch indexSet._variant {
        case .left(let singleIndex):
          if multiValueForKeyDict._entries[singleIndex].value.record.someValue.isValue {
            return .singleValue
          } else {
            return .singleNil
          }
        case .right(let indices):
          var valuesCount: Int = 0
          var nilInstancesCount: Int = 0
          
          for index in indices.base {
            if multiValueForKeyDict._entries[index].value.record.someValue.isValue {
              valuesCount += 1
            } else {
              nilInstancesCount += 1
            }
          }
          return .multipleRecords(valuesCount: valuesCount, nilCount: nilInstancesCount)
        }
      } else {
        return .nothing
      }
    }
  }
}
