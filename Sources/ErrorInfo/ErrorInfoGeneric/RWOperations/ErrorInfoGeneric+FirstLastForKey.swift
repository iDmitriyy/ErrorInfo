//
//  ErrorInfoGeneric+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

// MARK: - Last For Key

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentableEquatable {
  internal func lastRecordedInstance(forKey key: Key) -> RecordValue.OptionalInstanceType? { // optimized
    switch _storage._variant {
    case .left(let singleValueForKeyDict):
      if let index = singleValueForKeyDict.index(forKey: key) {
        return singleValueForKeyDict.values[index].someValue.instanceOfOptional
      } else {
        return nil
      }
    case .right(let multiValueForKeyDict):
      if let indices = multiValueForKeyDict._keyToEntryIndices[key] {
        return multiValueForKeyDict._entries[indices.last].value.record.someValue.instanceOfOptional
      } else {
        return nil
      }
    }
  } // inlining has no performance gain.
}

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  func lastNonNilValue(forKey key: Key) -> RecordValue.Wrapped? {
    guard let annotatedRecords = _storage.allValues(forKey: key) else { return nil }
    
    if let last = annotatedRecords.last.record.someValue.getWrapped { // fast path
      return last
    } else {
      // iteration by indices.dropLast().reversed() is faster than iteration over allRecordsForKey.dropLast().reversed()
      for index in annotatedRecords.indices.dropLast().reversed() {
        if let value = annotatedRecords[index].record.someValue.getWrapped {
          return value
        }
      }
      return nil
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - First For Key

extension ErrorInfoGeneric {
  func firstSomeValue(forKey key: Key) -> RecordValue? {
    guard let allRecordsForKey = _storage.allValues(forKey: key) else { return nil }
    return allRecordsForKey.first.record.someValue
  }
}

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  func firstNonNilValue(forKey key: Key) -> RecordValue.Wrapped? {
    guard let annotatedRecords = _storage.allValues(forKey: key) else { return nil }

    if let first = annotatedRecords.first.record.someValue.getWrapped { // fast path
      return first
    } else {
      // iteration by indices.dropFirst() is faster than iteration over allRecordsForKey.dropFirst()
      for index in annotatedRecords.indices.dropFirst() {
        if let value = annotatedRecords[index].record.someValue.getWrapped {
          return value
        }
      }
      return nil
    }
  }
}
