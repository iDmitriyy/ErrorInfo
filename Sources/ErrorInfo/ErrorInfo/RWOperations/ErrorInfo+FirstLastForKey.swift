//
//  ErrorInfo+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 11/12/2025.
//

// MARK: - Last For Key

extension ErrorInfo {
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
  public func lastValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)? {
    lastValue(forKey: literalKey.rawValue)
  }
  
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
  public func lastValue(forKey dynamicKey: String) -> (ValueExistential)? {
    _storage.lastNonNilValue(forKey: dynamicKey)
  }
  
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
  public func lastRecorded(forKey literalKey: StringLiteralKey) -> OptionalValue? {
    lastRecorded(forKey: literalKey.rawValue)
  }
  
  public func lastRecorded_2(forKey dynamicKey: String) -> OptionalValue? {
    switch _storage._storage._variant {
    case .left(let singleValueForKeyDict):
      if let index = singleValueForKeyDict.index(forKey: dynamicKey) {
        return singleValueForKeyDict.values[index].someValue.instanceOfOptional
      } else {
        return nil
      }
    case .right(let multiValueForKeyDict):
      if let indices = multiValueForKeyDict._keyToEntryIndices[dynamicKey] {
        return multiValueForKeyDict._entries[indices.last].value.record.someValue.instanceOfOptional
      } else {
        return nil
      }
    }
  }
  
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
  /// ```
  public func lastRecorded(forKey dynamicKey: String) -> OptionalValue? {
    _storage.lastRecordedInstance(forKey: dynamicKey)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - First For Key

extension ErrorInfo {
  /// Returns the first non‑nil value associated with the given key.
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
  public func firstValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)? {
    firstValue(forKey: literalKey.rawValue)
  }
  
  /// Returns the first non‑nil value associated with the given key.
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
  public func firstValue(forKey dynamicKey: String) -> (ValueExistential)? {
    _storage.firstNonNilValue(forKey: dynamicKey)
  }
}

