//
//  ErrorInfoOperationsProtocol.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

/// A protocol that defines the operations for managing key-value pairs in an `ErrorInfo`. Keeps documentation for common methods.
///
/// This protocol provides essential methods for adding, retrieving, and manipulating error-related information in a strongly-typed, flexible collection.
/// It allows multiple values (both `nil` and non-`nil`) to be associated with individual keys.
public protocol ErrorInfoOperationsProtocol where KeyType == String {
  associatedtype KeyType: Hashable
  associatedtype ValueExistential
  
  associatedtype Keys: Collection<KeyType> & _UniqueCollection
  associatedtype AllKeys: Collection<KeyType>
  
  /// Creates an empty `ErrorInfo` instance.
  init()
  
  /// Creates an empty `ErrorInfo` instance with a specified minimum capacity.
  init(minimumCapacity: Int)
  
  /// Returns empty instance of `ErrorInfo`.
  static var empty: Self { get }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
    
  // MARK: - Subscript
  
  /// A restricted subscript used to warn against removing values by mistake.
  ///
  /// - Note:
  /// It is needed to warn users when they try to pass a nil literal, like `info["key"] = nil`
  ///
  /// - Deprecated: This subscript is deprecated and will show a warning if used. To remove values, use `removeValue(forKey:)`.
  /// - Unavailable: This subscript cannot be used for getting or setting values. Use `removeValue(forKey:)` to remove a value.
  @_disfavoredOverload
  subscript(_: StringLiteralKey) -> InternalRestrictionToken? {
    @available(*, unavailable, message: "This is a stub subscript. To remove value use removeValue(forKey:) function")
    get
    
    @available(*, deprecated, message: "To remove value use removeValue(forKey:) function")
    set
  }
  
  /// Returns the last value associated with the given literal key.
  ///
  /// - Returns: The last value associated with key, or `nil` if no value is found.
  ///
  /// - Note:
  /// Use `allValues(forKey:)` if you need to access all values for a key.
  ///
  /// # Example:
  /// ```swift
  /// var info = ErrorInfo()
  /// info[.id] = 5
  /// info[.id] = 6
  ///
  /// let id = errorInfo[.id] as? Int // returns 6
  /// ```
  subscript(_ literalKey: StringLiteralKey) -> (ValueExistential)? { get }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
    
  // MARK: - Keys
  
  /// Returns a collection of **unique** keys from the `ErrorInfo` instance.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo: ErrorInfo = ["a": 0, "b": 1, "c": 3, "b": 2]
  ///
  /// let keys = errorInfo.keys // ["a", "b", "c"]
  /// ```
  var keys: Keys { get }
  
  /// Returns a collection of all (possibly **non unique**) keys in the `ErrorInfo` instance. Unlike `keys`, this does not enforce uniqueness, so it may contain duplicate entries, if there
  /// are multiple values for some keys.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo: ErrorInfo = ["a": 0, "b": 1, "c": 3, "b": 2]
  ///
  /// let allKeys = errorInfo.allKeys // ["a", "b", "c", "b"]
  /// ```
  var allKeys: AllKeys { get }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
    
  // MARK: - All ForKey
  
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
  func allValues(forKey literalKey: StringLiteralKey) -> ValuesForKey<ValueExistential>?
  
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
  func allValues(forKey dynamicKey: KeyType) -> ValuesForKey<ValueExistential>?
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - FirstLastForKey
  
  // MARK: Last For Key
  
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
  func lastValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)?
  
  @_disfavoredOverload
  func lastValue(forKey dynamicKey: KeyType) -> (ValueExistential)?
  
  // MARK: First For Key
  
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
  func firstValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)?
  
  @_disfavoredOverload
  func firstValue(forKey dynamicKey: KeyType) -> (ValueExistential)?
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - KeyValue Lookup
  
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
  func hasValue(forKey literalKey: StringLiteralKey) -> Bool
  
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
  /// errorInfo.hasValue(forKey: "id") // returns true
  /// ```
  @_disfavoredOverload
  func hasValue(forKey key: KeyType) -> Bool
  
  // MARK: Has Multiple Records For Key
  
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
  func hasMultipleRecords(forKey literalKey: StringLiteralKey) -> Bool
  
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
  func hasMultipleRecords(forKey key: KeyType) -> Bool
  
  /// Checks if there is any key in the `ErrorInfo` storage that is associated with more than one record.
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
  /// errorInfo.hasMultipleRecordsForAtLeastOneKey()
  /// // true because "key1" has multiple records
  /// ```
  func hasMultipleRecordsForAtLeastOneKey() -> Bool
  
  // MARK: KeyValue Lookup Result
  
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
  func keyValueLookupResult(forKey literalKey: StringLiteralKey) -> KeyValueLookupResult
  
  /// Returns the result of looking up a key in the storage, encapsulating the presence and state of values.
  ///
  /// This method checks the key's associated values in the storage and returns an appropriate `KeyValueLookupResult`.
  ///
  /// - Parameter key: The key to look up in the `ErrorInfo` storage.
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
  ///
  @_disfavoredOverload
  func keyValueLookupResult(forKey key: KeyType) -> KeyValueLookupResult
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - RemoveAll
  
  /// Removes all key-value pairs from the storage, optionally keeping its capacity.
  ///
  /// - Parameter keepCapacity: Pass `true` to keep the existing capacity of
  ///   the errorInfo after removing its records. The default value is `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the count of all records.
  mutating func removeAll(keepingCapacity keepCapacity: Bool)
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - RemoveAll ForKey
  
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
  mutating func removeAllRecords(forKey literalKey: StringLiteralKey) -> ValuesForKey<ValueExistential>?
  
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
  @_disfavoredOverload
  @discardableResult
  mutating func removeAllRecords(forKey dynamicKey: KeyType) -> ValuesForKey<ValueExistential>?
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - ReplaceAll ForKey
  
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
  mutating func replaceAllRecords(forKey literalKey: StringLiteralKey,
                                  by newValue: ValueExistential) -> ValuesForKey<ValueExistential>?
  
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
  @_disfavoredOverload
  @discardableResult
  mutating func replaceAllRecords(forKey dynamicKey: KeyType,
                                  by newValue: ValueExistential) -> ValuesForKey<ValueExistential>?
}
