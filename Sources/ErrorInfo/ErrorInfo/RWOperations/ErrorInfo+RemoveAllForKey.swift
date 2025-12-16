//
//  ErrorInfo+RemoveAllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

// MARK: - Remove All Records For Key

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
    _storage.removeAllValues(forKey: dynamicKey)?._compactMap { $0.value._optional.maybeValue.asOptional }
  }
}
