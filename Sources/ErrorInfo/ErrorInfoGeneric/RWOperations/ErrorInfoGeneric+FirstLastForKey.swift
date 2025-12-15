//
//  ErrorInfoGeneric+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

// MARK: - Last For Key

extension ErrorInfoGeneric {
  func lastSomeValue(forKey key: Key) -> GValue? {
    guard let allRecordsForKey = _storage.allValues(forKey: key) else { return nil }
    return allRecordsForKey.last.record.someValue
  }
}

extension ErrorInfoGeneric where GValue: ErrorInfoOptionalProtocol {
  func lastNonNilValue(forKey key: Key) -> GValue.Wrapped? {
    guard let allRecordsForKey = _storage.allValues(forKey: key) else { return nil }
    
    let reversedRecords: ReversedCollection<_> = allRecordsForKey.reversed()
    for annotatedRecord in reversedRecords {
      if let value = annotatedRecord.record.someValue.getWrapped {
        return value
      }
    }
    return nil
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - First For Key

extension ErrorInfoGeneric {
  func firstSomeValue(forKey key: Key) -> GValue? {
    guard let allRecordsForKey = _storage.allValues(forKey: key) else { return nil }
    return allRecordsForKey.first.record.someValue
  }
}

extension ErrorInfoGeneric where GValue: ErrorInfoOptionalProtocol {
  func firstNonNilValue(forKey key: Key) -> GValue.Wrapped? {
    guard let allRecordsForKey = _storage.allValues(forKey: key) else { return nil }

    for annotatedRecord in allRecordsForKey {
      if let value = annotatedRecord.record.someValue.getWrapped {
        return value
      }
    }
    return nil
  }
}
