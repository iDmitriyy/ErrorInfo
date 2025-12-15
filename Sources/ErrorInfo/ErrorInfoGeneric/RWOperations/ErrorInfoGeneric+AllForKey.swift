//
//  ErrorInfoGeneric+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

// MARK: - AllValues ForKey

extension ErrorInfoGeneric {
  func allSomeValues(forKey key: Key) -> ValuesForKey<GValue>? {
    _storage.allValues(forKey: key)?._compactMap { $0.record.someValue }
  }
}

extension ErrorInfoGeneric where GValue: ErrorInfoOptionalProtocol {
  func allNonNilValues(forKey key: Key) -> ValuesForKey<GValue.Wrapped>? {
    _storage.allValues(forKey: key)?._compactMap { $0.record.someValue.getWrapped }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Remove All Records For Key

// FIXME: - @discardableResult remove operations – check perfomance
// may it is better to make 2 overloads – pure remove and remove with result

extension ErrorInfoGeneric {
  @discardableResult
  mutating func removeAllRecords_ReturningSomeValues(forKey key: Key) -> ValuesForKey<GValue>? {
    _storage.removeAllValues(forKey: key)?._compactMap { $0.record.someValue }
  }
}

extension ErrorInfoGeneric where GValue: ErrorInfoOptionalProtocol {
  @discardableResult
  mutating func removeAllRecords_ReturningNonNilValues(forKey key: Key) -> ValuesForKey<GValue.Wrapped>? {
    _storage.removeAllValues(forKey: key)?._compactMap { $0.record.someValue.getWrapped }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Replace All Records For Key

extension ErrorInfoGeneric {
  internal mutating func _replaceAllRecords(forKey key: Key,
                                            keyOrigin: KeyOrigin,
                                            bySomeValue newValue: GValue) -> ValuesForKey<GValue>? {
    let oldValues = removeAllRecords_ReturningSomeValues(forKey: key)
    _add(key: key,
         keyOrigin: keyOrigin,
         someValue: newValue,
         duplicatePolicy: .allowEqual, // has no effect in this func
         collisionSource: .onAppend(origin: nil)) // collisions must never happen using this func
    return oldValues
  }
}

extension ErrorInfoGeneric where GValue: ErrorInfoOptionalProtocol {
  internal mutating func _replaceAllRecords(forKey key: Key,
                                            keyOrigin: KeyOrigin,
                                            byNonNilValue newValue: GValue.Wrapped,
                                            typeOfWrapped: GValue.TypeOfWrapped) -> ValuesForKey<GValue.Wrapped>? {
    let oldValues = removeAllRecords_ReturningNonNilValues(forKey: key)
    _add(key: key,
         keyOrigin: keyOrigin,
         optionalValue: newValue,
         typeOfWrapped: typeOfWrapped,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: .allowEqual, // has no effect in this func
         collisionSource: .onAppend(origin: nil)) // collisions must never happen using this func
    return oldValues
  }
}

// TBD: check perfomance for args when they have no semantical effect, e.g. preserveNilValues: true or duplicatePolicy: .allowEqual
// Constant values / if branches should be optimized by compiler. Check it
