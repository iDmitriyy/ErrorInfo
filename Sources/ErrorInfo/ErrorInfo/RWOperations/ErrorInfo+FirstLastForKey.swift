//
//  ErrorInfo+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 11/12/2025.
//

// MARK: - Last For Key

extension ErrorInfo {
  /// Returns the last non-nil value associated with the given literal key.
  ///
  /// - Returns: The last value associated with key, or `nil` if no value is found.
  ///
  /// # Example:
  /// ```swift
  /// var info = ErrorInfo()
  /// info[.id] = 5
  /// info[.id] = 6
  ///
  /// errorInfo.lastValue[forKey: .id) // returns 6
  /// ```
  public func lastValue(forKey literalKey: StringLiteralKey) -> (any ValueType)? {
    lastValue(forKey: literalKey.rawValue)
  }
  
  // TODO: - remake examples for dynamic keys (everywhere), as they are for literal api now
  
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

// MARK: - First For Key

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
  /// errorInfo.firstValue(forKey: .id) // returns 5
  /// ```
  public func firstValue(forKey literalKey: StringLiteralKey) -> (any ValueType)? {
    firstValue(forKey: literalKey.rawValue)
  }
  
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
