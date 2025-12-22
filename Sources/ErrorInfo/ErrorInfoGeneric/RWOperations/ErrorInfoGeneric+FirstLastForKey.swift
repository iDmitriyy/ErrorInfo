//
//  ErrorInfoGeneric+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

// MARK: - Last For Key

extension ErrorInfoGeneric {
  func lastSomeValue(forKey key: Key) -> RecordValue? {
    guard let allRecordsForKey = _storage.allValues(forKey: key) else { return nil }
    return allRecordsForKey.last.record.someValue
  }
}

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  func lastNonNilValue(forKey key: Key) -> RecordValue.Wrapped? {
    guard let annotatedRecords = _storage.allValues(forKey: key) else { return nil }
    
    if let last = annotatedRecords.last.record.someValue.getWrapped { // fast path
      return last
    } else {
      // ieration by indices.dropLast().reversed() is faster than iteration over allRecordsForKey.dropLast().reversed()
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
      // ieration by indices.dropFirst() is faster than iteration over allRecordsForKey.dropFirst()
      for index in annotatedRecords.indices.dropFirst() {
        if let value = annotatedRecords[index].record.someValue.getWrapped {
          return value
        }
      }
      return nil
    }
  }
}
