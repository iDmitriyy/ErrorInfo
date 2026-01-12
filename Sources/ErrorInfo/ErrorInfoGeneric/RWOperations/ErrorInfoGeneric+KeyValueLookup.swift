//
//  ErrorInfoGeneric+HasValueForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

// MARK: - HasValue For Key

extension ErrorInfoGeneric {
  public func hasRecord(forKey key: Key) -> Bool { // optimized
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.hasValue(forKey: key)
    case .right(let multiValueForKeyDict): multiValueForKeyDict.hasValue(forKey: key)
    }
  }
  
  public func recordsCount(forKey key: Key) -> Int {
    switch _variant {
    case .left(let singleValueForKeyDict):
      singleValueForKeyDict.hasValue(forKey: key) ? 1 : 0
    case .right(let multiValueForKeyDict):
      multiValueForKeyDict.valuesCount(forKey: key)
    }
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
  func hasMultipleRecords(forKey key: Key) -> Bool { // optimized
    switch _variant {
    case .left: false
    case .right(let multiValueForKeyDict): multiValueForKeyDict.hasMultipleValues(forKey: key)
    }
  }
}

extension ErrorInfoGeneric {
  public func hasMultipleRecordsForAtLeastOneKey() -> Bool { // optimized
    switch _variant {
    case .left: false
    case .right(let multiValueForKeyDict): multiValueForKeyDict.hasMultipleValuesForAtLeastOneKey
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - KeyValue Lookup Result

extension ErrorInfoGeneric {
  func keyValueLookupResultIgnoringNil(forKey key: Key) -> KeyNonOptionalValueLookupResult { // optimized
    switch _variant {
    case .left(let singleValueForKeyDict):
      if singleValueForKeyDict.hasValue(forKey: key) {
        return .singleValue
      } else {
        return .nothing
      }
      
    case .right(let multiValueForKeyDict):
      if let indexSet = multiValueForKeyDict._keyToEntryIndices[key] {
        let indexSetCount = indexSet.count
        if indexSetCount < 2 {
          return .singleValue
        } else {
          return .multipleRecords(valuesCount: indexSetCount)
        }
      } else {
        return .nothing
      }
    }
  }
}

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  func keyValueLookupResultIncludingNil(forKey key: Key) -> KeyValueLookupResult { // optimized
    switch _variant {
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
  } // inlining gives +2% performance, which is meaningless
}
