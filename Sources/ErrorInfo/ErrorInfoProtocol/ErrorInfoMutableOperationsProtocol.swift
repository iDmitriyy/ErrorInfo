//
//  ErrorInfoMutableOperationsProtocol.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/01/2026.
//

// MARK: - Mutable Operations

// Mutable operations can only be done consuming existentials, while at implementation level functions are generic.

public protocol ErrorInfoMutableOperationsProtocol: ErrorInfoOperationsProtocol {
  static func mergeTo(recipient: inout Self,
                      donator: Self,
                      origin: @autoclosure () -> WriteProvenance.Origin)
  
  // MARK: - RemoveAll ForKey
  
  /// Removes all records associated with the specified key and returns the removed `non-nil` values
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
//  @discardableResult
//  mutating func removeAllRecords(forKey literalKey: StringLiteralKey) -> ItemsForKey<ValueExistential>?
  
  /// Removes all records associated with the specified key and returns the removed `non-nil` values
  /// as a sequence.
  ///
  /// - Parameter key: The key for which the records should be removed.
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
//  @_disfavoredOverload
//  @discardableResult
//  mutating func removeAllRecords(forKey key: KeyType) -> ItemsForKey<ValueExistential>?
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - ReplaceAll ForKey
  
  /// Removes all existing records associated with the specified key and replaces them with
  /// a new value, returning the removed `non-nil` values as a sequence.
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
//  @discardableResult
//  mutating func replaceAllRecords(forKey literalKey: StringLiteralKey,
//                                  by newValue: ValueExistential) -> ItemsForKey<ValueExistential>?
  
  /// Removes all existing records associated with the specified key and replaces them with
  /// a new value, returning the removed `non-nil` values as a sequence.
  ///
  /// - Parameters:
  ///   - key: The key for which the records should be replaced.
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
//  @_disfavoredOverload
//  @discardableResult
//  mutating func replaceAllRecords(forKey key: KeyType,
//                                  by newValue: ValueExistential) -> ItemsForKey<ValueExistential>?
}
