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
                                         by newValue: ValueType) -> ValuesForKey<ValueType>? {
    _replaceAllRecordsImp(forKey: literalKey.rawValue, by: newValue, keyOrigin: literalKey.keyOrigin)
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func replaceAllRecords(forKey dynamicKey: String,
                                            by newValue: some ValueProtocol) -> ValuesForKey<ValueType>? {
    _replaceAllRecordsImp(forKey: dynamicKey, by: newValue, keyOrigin: .dynamic)
  }
  
  internal mutating func _replaceAllRecordsImp(forKey key: String,
                                               by newValue: some ValueProtocol,
                                               keyOrigin: KeyOrigin) -> ValuesForKey<ValueType>? {
    let oldValues = removeAllRecords(forKey: key)
    _add(key: key,
         keyOrigin: keyOrigin,
         value: newValue,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: .allowEqual, // has no effect in this func
         collisionSource: .onAppend(origin: nil)) // collisions must never happen using this func
    return oldValues
  }
}
