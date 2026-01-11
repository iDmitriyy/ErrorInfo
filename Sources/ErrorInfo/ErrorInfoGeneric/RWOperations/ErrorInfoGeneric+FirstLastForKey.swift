//
//  ErrorInfoGeneric+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

// MARK: - Last For Key

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentableEquatable {
  internal func lastRecordedOptionalInstance(forKey key: Key) -> RecordValue.OptionalInstanceType? { // optimized
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
  func lastNonNilValue(forKey key: Key) -> RecordValue.Wrapped? { // optimized
    switch _storage._variant {
    case .left(let singleValueForKeyDict):
      if let index = singleValueForKeyDict.index(forKey: key) {
        return singleValueForKeyDict.values[index].someValue.getWrapped
      } else {
        return nil
      }
    case .right(let multiValueForKeyDict):
      if let indices = multiValueForKeyDict._keyToEntryIndices[key] {
        switch indices._variant {
        case .left(let singleIndex): return multiValueForKeyDict._entries[singleIndex].value.record.someValue.getWrapped
        case .right(let indices):
          for index in indices.base.reversed() {
            if let value = multiValueForKeyDict._entries[index].value.record.someValue.getWrapped {
              return value
            }
          }
        }
      }
      return nil
    }
  } // inlining has no performance gain.
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
  func firstNonNilValue(forKey key: Key) -> RecordValue.Wrapped? { // optimized
    switch _storage._variant {
    case .left(let singleValueForKeyDict):
      if let index = singleValueForKeyDict.index(forKey: key) {
        return singleValueForKeyDict.values[index].someValue.getWrapped
      } else {
        return nil
      }
    case .right(let multiValueForKeyDict):
      if let indices = multiValueForKeyDict._keyToEntryIndices[key] {
        switch indices._variant {
        case .left(let singleIndex): return multiValueForKeyDict._entries[singleIndex].value.record.someValue.getWrapped
        case .right(let indices):
          for index in indices.base {
            if let value = multiValueForKeyDict._entries[index].value.record.someValue.getWrapped {
              return value
            }
          }
        }
      }
      return nil
    }
  } // inlining has no performance gain.
}
