//
//  ErrorInfoOperationsProtocol.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

/// A protocol that defines the operations for managing key-value pairs in `ErrorInfo` types that are able to preserve nil values.
/// Keeps documentation for common methods.
///
/// This protocol provides essential methods for adding, retrieving, and manipulating error-related information in a strongly-typed, flexible collection.
/// It allows multiple values (both `nil` and `non-nil`) to be associated with individual keys.
public protocol ErrorInfoOperationsProtocol where KeyType == String {
  associatedtype KeyType: Hashable
  associatedtype ValueExistential
  associatedtype OptionalValue: ErrorInfoOptionalRepresentable
  
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
  
  // MARK: User Guidance Subscript
  
  /// A guidance-only subscript that prevents accidental removal by `nil` literal assignment.
  ///
  /// This subscript exists to catch patterns like `info["key"] = nil`, which can look like
  /// “remove the value” in dictionaries. In `ErrorInfo`, removal is explicit and
  /// `nil` can be recorded as a meaningful entry. Use dedicated removal APIs instead.
  ///
  /// - Get: Unavailable.
  /// - Set: Deprecated. Use ``removeAllRecords(forKey:)`` (or other explicit removal APIs) instead.
  ///
  /// Rationale: Keeping removal explicit avoids silent loss of earlier context and aligns with
  /// `ErrorInfo`’s multi-record model.
  @_disfavoredOverload
  subscript(unavailable _: StringLiteralKey) -> Never? {
    @available(*, unavailable, message: "This is a set-only subscript for guidance.")
    get
    
    @available(*, deprecated, message: "To remove value use removeAllRecords(forKey:) function")
    set
  }
  
  // MARK: Last Value for Key Subscript
  
  /// Returns the last non‑nil value associated with the given literal key.
  ///
  /// This subscript is the ergonomic read path and surfaces the latest meaningful value.
  /// Explicit `nil` entries are preserved for auditing but are skipped here. Use
  /// ``lastRecorded(forKey:)`` or ``allRecords(forKey:)``  to inspect the last
  /// recorded entry including `nil`, its ``KeyOrigin``, and ``WriteProvenance``.
  ///
  /// ## Rationale:
  /// From a usability standpoint, the subscript is the ergonomic read path and should surface the last meaningful value by default.
  /// ErrorInfo intentionally separates “removal” from “explicitly recorded `nil`” so you don’t accidentally lose a meaningful prior value.
  /// Returning `nil` just because a later stage wrote a `nil` would reintroduce the classic “silent overwrite” pitfall ``ErrorInfo`` is trying to avoid.
  /// - Subscript is returning the last non‑nil value.
  ///   This matches how most callers read “the latest meaningful value” and prevents a trailing `nil`
  ///   from blanking useful context.
  /// - Iteration and the `lastValue` / `firstValue` APIs already operate on non‑nil values;
  ///   the subscript should remain consistent with that model for predictability and ergonomics.
  /// - Explicit `nil` is still preserved as a record for auditing and legacy‑style “removal” semantics.
  ///   When you need to know that the last write was `nil`, use `lastRecorded(forKey:)` or
  ///   `allRecords(forKey:)` to inspect the final record including `nil`.
  /// - This approach balances resilience (no silent loss of a good value due to a late `nil`)
  ///   with precision (you can still detect and reason about `nil` writes when you care).
  ///
  /// - Parameter literalKey: The literal key to read.
  /// - Returns: The last non‑nil value for the key, or `nil` if none exists.
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  /// info[.id] = 5
  /// info[.id] = 6
  /// info[.id] = nil as Int?
  ///
  /// info[.id] // 6
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
  
  /// Returns a collection of all (possibly **non unique**) keys in the `ErrorInfo` instance. Unlike `keys`, this does not enforce uniqueness,
  /// so it may contain duplicate entries, if there are multiple values for some keys.
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
  
  /// Returns all `non-nil` values associated with a given key in the `ErrorInfo` storage.
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
  /// errorInfo[.id] = nil as String?
  ///
  /// // errorInfo.allValues(forKey: .id) // returns [5, 6]
  /// ```
  func allValues(forKey literalKey: StringLiteralKey) -> ItemsForKey<ValueExistential>?
  
  /// Returns all `non-nil` values associated with a given key in the `ErrorInfo` storage.
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
  /// errorInfo["id"] = nil as String?
  ///
  /// // errorInfo.allValues(forKey: "id") // returns [5, 6]
  /// ```
  func allValues(forKey dynamicKey: KeyType) -> ItemsForKey<ValueExistential>?
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - FirstLastForKey
  
  // MARK: Last Value For Key
    
  /// Returns the last non‑nil value associated with the given key.
  ///
  /// This mirrors the subscript’s read behavior and surfaces the latest meaningful value.
  /// `nil` entries are preserved in history but skipped here.
  /// Use ``lastRecorded(forKey:)`` or ``allRecords(forKey:)`` to inspect
  /// the final record including `nil` and its provenance.
  ///
  /// - Parameter literalKey: The literal key to read.
  /// - Returns: The last non‑nil value for the key, or `nil` if none exists.
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  ///
  /// info[.id] = 5
  /// info[.id] = 6
  /// info[.id] = nil as Int?
  ///
  /// info.lastValue(forKey: .id) // 6
  /// ```
  func lastValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)?
  
  // TODO: - remake examples for dynamic keys (everywhere), as they are for literal api now
  
  /// Returns the last non‑nil value associated with the given key.
  ///
  /// This mirrors the subscript’s read behavior and surfaces the latest meaningful value.
  /// `nil` entries are preserved in history but skipped here.
  /// Use ``lastRecorded(forKey:)`` or ``allRecords(forKey:)`` to inspect
  /// the final record including `nil` and its provenance.
  ///
  /// - Parameter dynamicKey: The dynamic key to read.
  /// - Returns: The last non‑nil value for the key, or `nil` if none exists.
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  /// let key = "id"
  ///
  /// info[key] = 5
  /// info[key] = 6
  /// info[key] = nil as Int?
  ///
  /// info.lastValue(forKey: key) // 6
  /// ```
  func lastValue(forKey dynamicKey: KeyType) -> (ValueExistential)?
  
  // MARK: First Value For Key
    
  /// Returns the first `non‑nil` value associated with the given key.
  ///
  /// Use this to read the earliest meaningful entry when a key has multiple records.
  /// `nil` entries are preserved in history but skipped here.
  ///
  /// - Parameter literalKey: The literal key to read.
  /// - Returns: The first non‑nil value for the key, or `nil` if none exists.
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  ///
  /// info[.id] = nil as Int?
  /// info[.id] = 5
  /// info[.id] = 6
  ///
  /// info.firstValue(forKey: .id) // 5
  /// ```
  func firstValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)?
  
  /// Returns the first `non‑nil` value associated with the given key.
  ///
  /// Use this to read the earliest meaningful entry when a key has multiple records.
  /// `nil` entries are preserved in history but skipped here.
  ///
  /// - Parameter dynamicKey: The dynamic key to read.
  /// - Returns: The first non‑nil value for the key, or `nil` if none exists.
  ///
  /// ```swift
  /// var info = ErrorInfo()
  /// let key = "id"
  ///
  /// info[key] = nil as Int?
  /// info[key] = 5
  /// info[key] = 6
  ///
  /// info.firstValue(forKey: key) // 5
  /// ```
  func firstValue(forKey dynamicKey: KeyType) -> (ValueExistential)?
  
  // MARK: Last Recorded For Key
  
  /// Returns the last recorded entry for the given key, including explicit or implicit `nil`.
  ///
  /// Use this when you need to audit the final write for a key. For typical lookups of the latest
  /// meaningful value, prefer ``lastValue(forKey:)`` or the subscript.
  ///
  /// - Parameter literalKey: The literal key to look up.
  /// - Returns: The last recorded ``ErrorInfo/OptionalValue`` (either `.value` or `.nilInstance`),
  ///   or `nil` if the key has never been recorded.
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  ///
  /// info[.id] = 5
  /// info[.id] = nil as Int?
  ///
  /// if let last = info.lastRecorded(forKey: .id) {
  ///   switch last {
  ///   case .value(let v): print("last value:", v)
  ///   case .nilInstance(let t): print("last write was a nil of type \(t)")
  ///   }
  ///   // print: "last write was a nil of type Int"
  /// }
  /// ```
  func lastRecorded(forKey literalKey: StringLiteralKey) -> OptionalValue?
  
  /// Returns the last recorded entry for the given key, including explicit or implicit `nil`.
  ///
  /// Use this when you need to audit the final write for a key. For typical lookups of the latest
  /// meaningful value, prefer ``lastValue(forKey:)`` or the subscript.
  ///
  /// - Parameter dynamicKey: The dynamic key to look up.
  /// - Returns: The last recorded ``ErrorInfo/OptionalValue`` (either `.value` or `.nilInstance`),
  ///   or `nil` if the key has never been recorded.
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  /// let key = "id"
  ///
  /// info[key] = 5
  /// info[key] = nil as Int?
  ///
  /// if let last = info.lastRecorded(forKey: key) {
  ///   switch last {
  ///   case .value(let v): print("last value:", v)
  ///   case .nilInstance(let t): print("last write was a nil of type \(t)")
  ///   }
  ///   // print: "last write was a nil of type Int"
  /// }
  /// ```
  func lastRecorded(forKey dynamicKey: KeyType) -> OptionalValue?
  
  // MARK: First Recorded For Key
  
  func firstRecorded(forKey literalKey: StringLiteralKey) -> OptionalValue?
  
  func firstRecorded(forKey dynamicKey: String) -> OptionalValue?
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - KeyValue Lookup
  
  /// Checks whether the key is associated with at least one `non-nil` value.
  ///
  /// - Parameter literalKey: The key to search for in the `ErrorInfo` storage.
  ///
  /// - Returns: `true` if there is at least one `non-nil` value for the given key; otherwise, `false`.
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
  
  /// Checks whether the key is associated with at least one `non-nil` value.
  ///
  /// - Parameter key: The key to search for in the `ErrorInfo` storage.
  ///
  /// - Returns: `true` if there is at least one `non-nil` value for the given key; otherwise, `false`.
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
  
  func hasRecord(forKey key: KeyType) -> Bool
  
  // MARK: Has Multiple Records For Key
  
  /// Checks if the key is associated with multiple values (both `non-nil` and `nil`) in the `ErrorInfo` storage.
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
  
  /// Checks if the key is associated with multiple values (both `non-nil` and `nil`) in the `ErrorInfo` storage.
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
  /// // because one value is `non-nil` and one is nil.
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
  /// // because one value is `non-nil` and one is nil.
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
  @discardableResult
  mutating func removeAllRecords(forKey literalKey: StringLiteralKey) -> ItemsForKey<ValueExistential>?
  
  /// Removes all records associated with the specified key and returns the removed `non-nil` values
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
  mutating func removeAllRecords(forKey dynamicKey: KeyType) -> ItemsForKey<ValueExistential>?
  
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
  @discardableResult
  mutating func replaceAllRecords(forKey literalKey: StringLiteralKey,
                                  by newValue: ValueExistential) -> ItemsForKey<ValueExistential>?
  
  /// Removes all existing records associated with the specified key and replaces them with
  /// a new value, returning the removed `non-nil` values as a sequence.
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
                                  by newValue: ValueExistential) -> ItemsForKey<ValueExistential>?
}
