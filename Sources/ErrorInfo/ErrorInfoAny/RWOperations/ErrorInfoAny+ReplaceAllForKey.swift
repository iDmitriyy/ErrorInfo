//
//  ErrorInfoAny+ReplaceAllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - Replace All Records For Key

extension ErrorInfoAny {
  @discardableResult
  public mutating func replaceAllRecords<T>(forKey literalKey: StringLiteralKey,
                                            by newValue: T) -> ItemsForKey<ValueExistential>? {
    _replaceAllRecordsImp(forKey: literalKey.rawValue, by: newValue, keyOrigin: literalKey.keyOrigin)
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func replaceAllRecords<T>(forKey dynamicKey: String,
                                            by newValue: T) -> ItemsForKey<ValueExistential>? {
    _replaceAllRecordsImp(forKey: dynamicKey, by: newValue, keyOrigin: .dynamic)
  }
  
  internal mutating func _replaceAllRecordsImp<T>(forKey key: String,
                                                  by newValue: T,
                                                  keyOrigin: KeyOrigin) -> ItemsForKey<ValueExistential>? {
    let oldValues = _storage.removeAllRecords_ReturningNonNilValues(forKey: key)
    _add(key: key,
         keyOrigin: keyOrigin,
         value: newValue,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: .allowEqual, // has no effect in this func
         writeProvenance: .onAppend(origin: nil)) // collisions must never happen using this func
    return oldValues
  }
}
