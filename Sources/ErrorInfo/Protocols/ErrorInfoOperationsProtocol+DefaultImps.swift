//
//  ErrorInfoOperationsProtocol+DefaultImps.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 12/01/2026.
//

// get-value functions can have default imps for StringLiteralKey overloads.

extension ErrorInfoOperationsProtocol where KeyType == String {
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
  public subscript(unavailable _: StringLiteralKey) -> Never? {
    @available(*, unavailable,
                message: "This is a set-only subscript for guidance.")
    get { nil }
    
    @available(*, deprecated, message: "To remove value use removeAllRecords(forKey:) function.")
    set {}
  }
  
  // MARK: - Read access Subscript
  
  public subscript(_ literalKey: StringLiteralKey) -> (ValueExistential)? {
    lastValue(forKey: literalKey.rawValue)
  }
  
  public subscript(dynamicKey key: String) -> (ValueExistential)? {
    lastValue(forKey: key)
  }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
    
  // MARK: - All ForKey
  
  public func allValues(forKey literalKey: StringLiteralKey) -> ItemsForKey<ValueExistential>? {
    allValues(forKey: literalKey.rawValue)
  }
  
  public func allRecords(forKey literalKey: StringLiteralKey) -> ItemsForKey<Record>? {
    allRecords(forKey: literalKey.rawValue)
  }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - FirstLastForKey
  
  // MARK: Last Value For Key
  
  public func lastValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)? {
    lastValue(forKey: literalKey.rawValue)
  }
  
  // MARK: First Value For Key
  
  public func firstValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)? {
    firstValue(forKey: literalKey.rawValue)
  }
  
  // MARK: Last Recorded For Key
  
  public func lastRecorded(forKey literalKey: StringLiteralKey) -> OptionalValue? {
    lastRecorded(forKey: literalKey.rawValue)
  }
  
  // MARK: First Recorded For Key
  
  public func firstRecorded(forKey literalKey: StringLiteralKey) -> OptionalValue? {
    firstRecorded(forKey: literalKey.rawValue)
  }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - KeyValue Lookup
  
  public func hasValue(forKey literalKey: StringLiteralKey) -> Bool {
    hasValue(forKey: literalKey.rawValue)
  }
  
  public func hasRecord(forKey literalKey: StringLiteralKey) -> Bool {
    hasRecord(forKey: literalKey.rawValue)
  }
  
  public func hasMultipleRecords(forKey literalKey: StringLiteralKey) -> Bool {
    hasMultipleRecords(forKey: literalKey.rawValue)
  }
  
  public func keyValueLookupResult(forKey literalKey: StringLiteralKey) -> KeyValueLookupResult {
    keyValueLookupResult(forKey: literalKey.rawValue)
  }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - RemoveAll ForKey
  
  @discardableResult
  public mutating func removeAllRecords(forKey literalKey: StringLiteralKey) -> ItemsForKey<ValueExistential>? {
    removeAllRecords(forKey: literalKey.rawValue)
  }
}
