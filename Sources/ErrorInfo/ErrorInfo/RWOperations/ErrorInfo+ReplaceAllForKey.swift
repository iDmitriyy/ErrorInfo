//
//  ErrorInfo+ReplaceAllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

// MARK: - Replace All Records For Key

extension ErrorInfo {
  @discardableResult
  public mutating func replaceAllRecords(forKey literalKey: StringLiteralKey,
                                         by newValue: ValueExistential) -> ValuesForKey<ValueExistential>? {
    _replaceAllRecordsImp(forKey: literalKey.rawValue, by: newValue, keyOrigin: literalKey.keyOrigin)
  }
  
  @_disfavoredOverload
  @discardableResult
  public mutating func replaceAllRecords(forKey dynamicKey: String,
                                         by newValue: ValueExistential) -> ValuesForKey<ValueExistential>? {
    _replaceAllRecordsImp(forKey: dynamicKey, by: newValue, keyOrigin: .dynamic)
  }
  
  internal mutating func _replaceAllRecordsImp(forKey key: String,
                                               by newValue: ValueExistential,
                                               keyOrigin: KeyOrigin) -> ValuesForKey<ValueExistential>? {
    let oldValues = removeAllRecords(forKey: key)
    _addDetachedValue(key: key,
                      keyOrigin: keyOrigin,
                      value: newValue,
                      shouldPreserveNilValues: true, // has no effect in this func
                      duplicatePolicy: .allowEqual, // has no effect in this func
                      writeProvenance: .onAppend(origin: nil)) // collisions must never happen using this func
    return oldValues
  }
}
