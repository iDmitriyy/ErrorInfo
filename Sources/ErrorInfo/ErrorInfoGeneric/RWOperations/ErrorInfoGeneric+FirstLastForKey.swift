//
//  ErrorInfoGeneric+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

// MARK: - Non-Nil Value

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  // MARK: last
  
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
  
  // MARK: first
  
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

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - OptionalInstance

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentableEquatable {
  // MARK: last
  
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
  
  // MARK: first
  
  internal func firstRecordedOptionalInstance(forKey key: Key) -> RecordValue.OptionalInstanceType? { // optimized
    switch _storage._variant {
    case .left(let singleValueForKeyDict):
      if let index = singleValueForKeyDict.index(forKey: key) {
        return singleValueForKeyDict.values[index].someValue.instanceOfOptional
      } else {
        return nil
      }
    case .right(let multiValueForKeyDict):
      if let indices = multiValueForKeyDict._keyToEntryIndices[key] {
        return multiValueForKeyDict._entries[indices.first].value.record.someValue.instanceOfOptional
      } else {
        return nil
      }
    }
  } // inlining has no performance gain.
}
