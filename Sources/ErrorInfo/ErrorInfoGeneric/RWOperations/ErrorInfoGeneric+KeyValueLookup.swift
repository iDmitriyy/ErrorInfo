//
//  ErrorInfoGeneric+HasValueForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

// MARK: - HasValue For Key

extension ErrorInfoGeneric {
  func hasSomeValue(forKey key: Key) -> Bool {
    _storage.hasValue(forKey: key)
  }
}

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  func hasNonNilValue(forKey key: Key) -> Bool {
    switch keyValueLookupResult_Optional(forKey: key) {
    case .nothing: false
    case .singleValue: true
    case .singleNil: false
    case .multipleRecords(let valuesCount, _): valuesCount > 0
    }
  }
  
  func hasNilInstance(forKey key: Key) -> Bool {
    switch keyValueLookupResult_Optional(forKey: key) {
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
    return recordsForKey.count > 1 // TODO: - optimize
    // recordsCount(forKey:) | valuesCount(forKey:)
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
  func keyValueLookupResult_NonOptional(forKey key: Key) -> KeyNonOptionalValueLookupResult {
    if let taggedRecords = _storage.allValues(forKey: key) {
      var valuesCount: UInt16 = UInt16(taggedRecords.count)

      // TODO: - UInt16 overflow crash test (on MacOS)
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
  func keyValueLookupResult_Optional(forKey key: Key) -> KeyValueLookupResult {
    // FIXME: instead of _storage.allValues(forKey: key) smth like
    // _storage.iterateWithResult(forKey: key), to eliminate allocations
    // on the other side, allValues(forKey:) should be quite fast.
    
//    _storage.iterateAllValues(forKey: key) { annotatedRecord in
//    }
    
//    if let allRecords = _storage.allValues(forKey: key) {
//      if allRecords.count == 1 {
//      } else {
//      }
//    }
    
    if let taggedRecords = _storage.allValues(forKey: key) {
      var valuesCount: UInt16 = 0
      var nilInstancesCount: UInt16 = 0
      for taggedRecord in taggedRecords {
        if taggedRecord.record.someValue.isValue {
          valuesCount += 1
        } else {
          nilInstancesCount += 1
        }
      }
      // TODO: - UInt16 overflow crash test (on MacOS) | check perfomance for Int
      switch (valuesCount, nilInstancesCount) {
      case (1, 0): return .singleValue
      case (0, 1): return .singleNil
      default: return .multipleRecords(valuesCount: valuesCount, nilCount: nilInstancesCount)
      }
    } else {
      return .nothing
    }
  }
}
