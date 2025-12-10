//
//  ErrorInfo+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: - AllValues ForKey

extension ErrorInfo {
  // TODO: public func allValuesSlice(forKey key: Key) -> (some Sequence<Value>)? {}
  // replace usage of allValues(forKey:) for better perfomance | reduce allocations
  
  /// Returns all non-nil values associated with a given key in the `ErrorInfo` storage.
  ///
  /// This method retrieves all values associated with the specified key, returning them as a sequence.
  ///
  /// - Parameter literalKey: The key to look up in the `ErrorInfo` storage.
  ///
  /// - Returns: A non-empty sequence of values associated with the key, or `nil` if the key has no associated values.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  ///
  /// errorInfo[.id] = 5
  /// errorInfo[.id] = 6
  /// errorInfo[.id] = nil as Optional<String>
  ///
  /// // errorInfo.allValues(forKey: .id) // returns [5, 6]
  /// ```
  public func allValues(forKey literalKey: StringLiteralKey) -> ValuesForKey<any ValueType>? {
    allValues(forKey: literalKey.rawValue)
  }
  
  /// Returns all non-nil values associated with a given key in the `ErrorInfo` storage.
  ///
  /// This method retrieves all values associated with the specified key, returning them as a sequence.
  ///
  /// - Parameter dynamicKey: The key to look up in the `ErrorInfo` storage.
  ///
  /// - Returns: A non-empty sequence of values associated with the key, or `nil` if the key has no associated values.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  ///
  /// errorInfo["id"] = 5
  /// errorInfo["id"] = 6
  /// errorInfo["id"] = nil as Optional<String>
  ///
  /// // errorInfo.allValues(forKey: "id") // returns [5, 6]
  /// ```
  @_disfavoredOverload
  public func allValues(forKey dynamicKey: String) -> ValuesForKey<any ValueType>? {
    _storage.allValues(forKey: dynamicKey)?._compactMap { $0.value._optional.optionalValue }
  }
  
  /// Returns the first non-nil value associated with the given key.
  ///
  /// - Parameter literalKey: The key to look up in the `ErrorInfo` storage.
  ///
  /// - Returns: The first non-nil value associated with the key, or `nil` if no such value exists.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  /// errorInfo[.id] = 5
  /// errorInfo[.id] = 6
  ///
  /// let id = errorInfo.firstValue(forKey: .id) // returns 5
  /// ```
  public func firstValue(forKey literalKey: StringLiteralKey) -> (any ValueType)? {
    firstValue(forKey: literalKey.rawValue)
  }
  
  // TODO: - remake examples for dynamic keys, as they are for literal api now
  
  @_disfavoredOverload
  public func firstValue(forKey dynamicKey: String) -> (any ValueType)? {
    allValues(forKey: dynamicKey)?.first
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Remove All Records ForKey

extension ErrorInfo {
  /// Removes all records associated with the specified key and returns the removed non-nil values
  /// as a sequence.
  ///
  /// - Parameter literalKey: The key for which the records should be removed.
  ///
  /// - Returns: A non-empty sequence of removed values, or `nil` if no values were associated with the key.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  ///
  /// errorInfo[.id] = 5
  /// errorInfo[.id] = 6
  /// errorInfo[.id] = nil as Optional<String>
  ///
  /// let removedIDs = errorInfo.removeAllRecords(forKey: .id)
  /// // returns [5, 6]
  ///
  /// let removedURL = errorInfo.removeAllRecords(forKey: .url)
  /// // returns nil
  /// ```
  @discardableResult
  public mutating func removeAllRecords(forKey literalKey: StringLiteralKey) -> ValuesForKey<any ValueType>? {
    removeAllRecords(forKey: literalKey.rawValue)
  }
  
  /// Removes all records associated with the specified key and returns the removed non-nil values
  /// as a sequence.
  ///
  /// - Parameter dynamicKey: The key for which the records should be removed.
  ///
  /// - Returns: A non-empty sequence of removed values, or `nil` if no values were associated with the key.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  ///
  /// errorInfo["id"] = 5
  /// errorInfo["id"] = 6
  /// errorInfo["id"] = nil as Optional<String>
  ///
  /// let removed = errorInfo.removeAllRecords(forKey: "id")
  /// // returns [5, 6]
  ///
  /// let removedURL = errorInfo.removeAllRecords(forKey: "url")
  /// // returns nil
  /// ```
  @_disfavoredOverload @discardableResult
  public mutating func removeAllRecords(forKey dynamicKey: String) -> ValuesForKey<any ValueType>? {
    _storage.removeAllValues(forKey: dynamicKey)?._compactMap { $0.value._optional.optionalValue }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Replace All Records ForKey

extension ErrorInfo {
  /// Removes all existing records associated with the specified key and replaces them with
  /// a new value, returning the removed non-nil values as a sequence.
  ///
  /// - Parameters:
  ///   - literalKey: The key for which the records should be replaced.
  ///   - newValue: The new value to associate with the specified key.
  ///
  /// - Returns: A non-empty sequence of the old values that were replaced, or `nil` if no value were associated with the key.
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
  /// - Returns: A non-empty sequence of the old values that were replaced, or `nil` if no value were associated with the key.
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
  /// // errorInfo now stores `11` for key `"id"`
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
    return oldValues?._compactMap { $0.value._optional.optionalValue }
  }
}
