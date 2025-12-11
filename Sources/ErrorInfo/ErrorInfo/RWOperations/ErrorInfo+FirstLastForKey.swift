//
//  ErrorInfo+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 11/12/2025.
//

// MARK: - Last ForKey

extension ErrorInfo {
  public func lastValue(forKey literalKey: StringLiteralKey) -> (any ValueType)? {
    lastValue(forKey: literalKey.rawValue)
  }
  
  // TODO: - remake examples for dynamic keys, as they are for literal api now
  
  @_disfavoredOverload
  public func lastValue(forKey dynamicKey: String) -> (any ValueType)? {
    guard let allRecordsForKey = _storage.allValues(forKey: dynamicKey) else { return nil }
    
    let reversedRecords: ReversedCollection<_> = allRecordsForKey.reversed()
    for record in reversedRecords {
      if let value = record.value._optional.optionalValue {
        return value
      }
    }
    return nil
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - First ForKey

extension ErrorInfo {
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
    guard let allRecordsForKey = _storage.allValues(forKey: dynamicKey) else { return nil }
    
    for record in allRecordsForKey {
      if let value = record.value._optional.optionalValue {
        return value
      }
    }
    return nil
  }
}
