//
//  ErrorInfoGeneric+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

// MARK: - AllValues ForKey

extension ErrorInfoGeneric {
  func allAnnotatedRecords(forKey key: Key) -> ItemsForKey<AnnotatedRecord>? { // optimized
    switch _storage._variant {
    case .left(let singleValueForKeyDict):
      if let index = singleValueForKeyDict.index(forKey: key) {
        ItemsForKey(element: AnnotatedRecord.value(singleValueForKeyDict.values[index]))
      } else {
        nil
      }
    case .right(let multiValueForKeyDict):
      multiValueForKeyDict.allValues(forKey: key)
    }
  } // inlining has no performance gain.
  
  func allAnnotatedRecords<T>(forKey key: Key, transform: (AnnotatedRecord) -> T) -> ItemsForKey<T>? { // optimized
    switch _storage._variant {
    case .left(let singleValueForKeyDict):
      if let index = singleValueForKeyDict.index(forKey: key) {
        return ItemsForKey<T>(element: transform(AnnotatedRecord.value(singleValueForKeyDict.values[index])))
      } else {
        return nil
      }
    case .right(let multiValueForKeyDict):
      return multiValueForKeyDict.allValues(forKey: key, transform: transform)
    }
  } // inlining worsen performance
}

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  func allNonNilValues(forKey key: Key) -> ItemsForKey<RecordValue.Wrapped>? { // optimized
    switch _storage._variant {
    case .left(let singleValueForKeyDict):
      if let index = singleValueForKeyDict.index(forKey: key),
          let value = singleValueForKeyDict.values[index].someValue.getWrapped {
        return ItemsForKey(element: value)
      } else {
        return nil
      }
      
    case .right(let multiValueForKeyDict):
      if let indexSet = multiValueForKeyDict._keyToEntryIndices[key] {
        switch indexSet._variant {
        case .left(let singleIndex):
          if let value = multiValueForKeyDict._entries[singleIndex].value.record.someValue.getWrapped {
            return ItemsForKey(element: value)
          }
        case .right(let indices):
          var values: Array<RecordValue.Wrapped> = Array(minimumCapacity: 2)
          for index in indices.base {
            if let value = multiValueForKeyDict._entries[index].value.record.someValue.getWrapped {
              values.append(value)
            }
          }
          return ItemsForKey(swiftArray: values)
        }
      }
      return nil
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Remove All Records For Key

// FIXME: - @discardableResult remove operations – check performance
// may it is better to make 2 overloads – pure remove and remove with result

extension ErrorInfoGeneric {
  @discardableResult
  mutating func removeAllRecords_ReturningSomeValues(forKey key: Key) -> ItemsForKey<RecordValue>? {
    _storage.removeAllValues(forKey: key)?._compactMap { $0.record.someValue }
  }
}

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentable {
  @discardableResult
  mutating func removeAllRecords_ReturningNonNilValues(forKey key: Key) -> ItemsForKey<RecordValue.Wrapped>? {
    _storage.removeAllValues(forKey: key)?._compactMap { $0.record.someValue.getWrapped }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Replace All Records For Key

extension ErrorInfoGeneric where RecordValue: Equatable {
  internal mutating func _replaceAllRecords(forKey key: Key,
                                            keyOrigin: KeyOrigin,
                                            bySomeValue newValue: RecordValue) -> ItemsForKey<RecordValue>? {
    let oldValues = removeAllRecords_ReturningSomeValues(forKey: key)
    _add(key: key,
         keyOrigin: keyOrigin,
         someValue: newValue,
         duplicatePolicy: .allowEqual, // has no effect in this func
         writeProvenance: .onAppend(origin: nil)) // collisions must never happen using this func
    return oldValues
  }
}

extension ErrorInfoGeneric where RecordValue: Equatable & ErrorInfoOptionalRepresentable {
  internal mutating func _replaceAllRecords(forKey key: Key,
                                            keyOrigin: KeyOrigin,
                                            byNonNilValue newValue: RecordValue.Wrapped,
                                            typeOfWrapped: RecordValue.TypeOfWrapped) -> ItemsForKey<RecordValue.Wrapped>? {
    let oldValues = removeAllRecords_ReturningNonNilValues(forKey: key)
    _add(key: key,
         keyOrigin: keyOrigin,
         optionalValue: newValue,
         typeOfWrapped: typeOfWrapped,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: .allowEqual, // has no effect in this func
         writeProvenance: .onAppend(origin: nil)) // collisions must never happen using this func
    return oldValues
  }
}

// DEFERRED: check performance for args when they have no semantical effect, e.g. preserveNilValues: true or duplicatePolicy: .allowEqual
// Constant values / if branches should be optimized by compiler. Check it
