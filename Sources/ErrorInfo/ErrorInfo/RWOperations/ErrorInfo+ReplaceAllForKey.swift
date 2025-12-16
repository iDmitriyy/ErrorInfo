//
//  ErrorInfo+ReplaceAllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

// MARK: - Replace All Records For Key

extension ErrorInfo {
  /// Removes all existing records associated with the specified key and replaces them with
  /// a new value, returning the removed non-nil values as a sequence.
  ///
  /// - Parameters:
  ///   - literalKey: The key for which the records should be replaced.
  ///   - newValue: The new value to associate with the specified key.
  ///
  /// - Returns: A non-empty sequence of the old values that were replaced, or `nil`
  /// if no value were associated with the key.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  ///
  /// errorInfo[.id] = 5
  /// errorInfo[.id] = 6
  /// errorInfo[.id] = nil as Optional<String>
  ///
  /// let removed = errorInfo.replaceAllRecords(forKey: .id, by: 11)
  /// // removed == [5, 6]
  /// // errorInfo now stores `11` for key `"id"`
  /// ```
  @discardableResult
  public mutating func replaceAllRecords(forKey literalKey: StringLiteralKey,
                                         by newValue: any ValueType) -> ValuesForKey<any ValueType>? {
    _replaceAllRecordsImp(forKey: literalKey.rawValue, by: newValue, keyOrigin: literalKey.keyOrigin)
  }
  
  /// Removes all existing records associated with the specified key and replaces them with
  /// a new value, returning the removed non-nil values as a sequence.
  ///
  /// - Parameters:
  ///   - dynamicKey: The key for which the records should be replaced.
  ///   - newValue: The new value to associate with the specified key.
  ///
  /// - Returns: A non-empty sequence of the old values that were replaced, or `nil`
  ///  if no value were associated with the key.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  ///
  /// errorInfo["id"] = 5
  /// errorInfo["id"] = 6
  /// errorInfo["id"] = nil as Optional<String>
  ///
  /// let removed = errorInfo.replaceAllRecords(forKey: "id", by: 11)
  /// // removed == [5, 6]
  /// // errorInfo now stores single record: `11` for key `"id"`
  /// ```
  @_disfavoredOverload @discardableResult
  public mutating func replaceAllRecords(forKey dynamicKey: String,
                                         by newValue: any ValueType) -> ValuesForKey<any ValueType>? {
    _replaceAllRecordsImp(forKey: dynamicKey, by: newValue, keyOrigin: .dynamic)
  }
  
  internal mutating func _replaceAllRecordsImp(forKey key: String,
                                               by newValue: any ValueType,
                                               keyOrigin: KeyOrigin) -> ValuesForKey<any ValueType>? {
    let oldValues = _storage.removeAllValues(forKey: key)
    _add(key: key,
         keyOrigin: keyOrigin,
         value: newValue,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: .allowEqual, // has no effect in this func
         collisionSource: .onAppend(origin: nil)) // collisions must never happen using this func
    return oldValues?._compactMap { $0.value._optional.maybeValue.asOptional }
  }
}
