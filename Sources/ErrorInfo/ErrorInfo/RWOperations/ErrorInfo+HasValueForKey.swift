//
//  ErrorInfo+HasValueForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: - HasValue For Key

extension ErrorInfo {
  /// Checks whether the key is associated with at least one non-nil value.
  ///
  /// - Parameter literalKey: The key to search for in the `ErrorInfo` storage.
  ///
  /// - Returns: `true` if there is at least one non-nil value for the given key; otherwise, `false`.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo = ErrorInfo()
  ///
  /// errorInfo[.url] = nil as URL?
  /// errorInfo.hasValue(forKey: .url) // returns false
  ///
  /// errorInfo[.id] = 5
  /// errorInfo.hasValue(forKey: .id) // returns true
  /// ```
  public func hasValue(forKey literalKey: StringLiteralKey) -> Bool {
    hasValue(forKey: literalKey.rawValue)
  }
  
  /// Checks whether the key is associated with at least one non-nil value.
  ///
  /// - Parameter key: The key to search for in the `ErrorInfo` storage.
  ///
  /// - Returns: `true` if there is at least one non-nil value for the given key; otherwise, `false`.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo = ErrorInfo()
  ///
  /// errorInfo["url"] = nil as URL?
  /// errorInfo.hasValue(forKey: "url") // returns false
  ///
  /// errorInfo["id"] = 5
  ///
  /// errorInfo.hasValue(forKey: "id") // returns true
  /// ```
  @_disfavoredOverload
  public func hasValue(forKey key: String) -> Bool {
    switch keyValueLookupResult(forKey: key) {
    case .nothing: false
    case .singleValue: true
    case .singleNil: false
    case .multipleRecords(let valuesCount, _): valuesCount > 0
    }
  }
  
  
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Has Multiple Records For Key

extension ErrorInfo {
  /// Checks if the key is associated with multiple values (both non-nil and nil) in the `ErrorInfo` storage.
  ///
  /// - Parameter literalKey: The key to search for in the `ErrorInfo` storage.
  ///
  /// - Returns: `true` if the key is associated with multiple values; otherwise `false`.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo = ErrorInfo()
  ///
  /// errorInfo[.id] = 5
  /// errorInfo[.id] = nil as Int?
  ///
  /// errorInfo.hasMultipleRecords(forKey: .id) // true because there are multiple records
  /// ```
  public func hasMultipleRecords(forKey literalKey: StringLiteralKey) -> Bool {
    hasMultipleRecords(forKey: literalKey.rawValue)
  }
  
  /// Checks if the key is associated with multiple values (both non-nil and nil) in the `ErrorInfo` storage.
  ///
  /// - Parameter key: The key to search for in the `ErrorInfo` storage.
  ///
  /// - Returns: `true` if the key is associated with multiple values; otherwise `false`.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo = ErrorInfo()
  ///
  /// errorInfo["id"] = 5
  /// errorInfo["id"] = nil as Int?
  ///
  /// errorInfo.hasMultipleRecords(forKey: "id")  // true because there are multiple records
  /// ```
  @_disfavoredOverload
  public func hasMultipleRecords(forKey key: String) -> Bool {
    switch keyValueLookupResult(forKey: key) {
    case .nothing, .singleValue, .singleNil: false
    case .multipleRecords: true
    }
  }
  
  /// Checks if there is any key in the `ErrorInfo` storage that is associated with more than one value.
  ///
  /// - Returns: `true` if any key is associated with multiple records; otherwise `false`.
  ///
  /// # Example:
  ///
  /// ```swift
  /// let errorInfo = ErrorInfo()
  ///
  /// errorInfo["key1"] = "A"
  /// errorInfo["key1"] = "B"
  /// errorInfo["key2"] = Date()
  ///
  /// errorInfo.hasMultipleRecordsForAtLeastOneKey() // true because "key1" has multiple records
  /// ```
  public func hasMultipleRecordsForAtLeastOneKey() -> Bool {
    _storage._storage.hasMultipleValuesForAtLeastOneKey
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - KeyValue Lookup Result

extension ErrorInfo {
  /// Returns the result of looking up a key in the storage, encapsulating the presence and state of values.
  ///
  /// - Parameter literalKey: The key to look up in the `ErrorInfo` storage.
  ///
  /// - Returns: A `KeyValueLookupResult` indicating the result of the lookup.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo = ErrorInfo()
  ///
  /// errorInfo[.id] = 5
  /// errorInfo[.id] = nil as Int?
  ///
  /// let result = errorInfo.keyValueLookupResult(forKey: .id)
  /// // Returns .multipleRecords(valuesCount: 1, nilCount: 1)
  /// // because one value is non-nil and one is nil.
  /// ```
  public func keyValueLookupResult(forKey literalKey: StringLiteralKey) -> KeyValueLookupResult {
    keyValueLookupResult(forKey: literalKey.rawValue)
  }
  
  /// Returns the result of looking up a key in the storage, encapsulating the presence and state of values.
  ///
  /// This method checks the key's associated values in the storage and returns an appropriate `KeyValueLookupResult`.
  ///
  /// - Parameter literalKey: The key to look up in the `ErrorInfo` storage.
  ///
  /// - Returns: A `KeyValueLookupResult` indicating the result of the lookup.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo = ErrorInfo()
  ///
  /// errorInfo["id"] = 5
  /// errorInfo["id"] = nil as Int?
  ///
  /// let result = errorInfo.keyValueLookupResult(forKey: "id")
  /// // Returns .multipleRecords(valuesCount: 1, nilCount: 1)
  /// // because one value is non-nil and one is nil.
  /// ```
  @_disfavoredOverload
  public func keyValueLookupResult(forKey key: String) -> KeyValueLookupResult {
    // FIXME: instead of _storage.allValues(forKey: key) smth like
    // _storage.iterateWithResult(forKey: key), to eliminate allocations
    // on the other side, allValues(forKey:) should be quite fast.
    
    
    if let taggedRecords = _storage.allValues(forKey: key) {
      var valuesCount: UInt16 = 0
      var nilInstancesCount: UInt16 = 0
      for taggedRecord in taggedRecords {
        if taggedRecord.value._optional.maybeValue.isValue {
          valuesCount += 1
        } else {
          nilInstancesCount += 1
        }
      }
      // TODO: - UInt16 overflow crash test (on MacOS)
      switch (valuesCount, nilInstancesCount) {
      case (1, 0): return .singleValue
      case (0, 1): return .singleNil
      default: return .multipleRecords(valuesCount: valuesCount, nilCount: nilInstancesCount)
      }
    } else {
      return .nothing
    }
  }
}
