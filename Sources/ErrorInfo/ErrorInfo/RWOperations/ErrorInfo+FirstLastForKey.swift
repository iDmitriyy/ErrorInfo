//
//  ErrorInfo+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 11/12/2025.
//

// MARK: - Last For Key

extension ErrorInfo {
  public func lastValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)? {
    lastValue(forKey: literalKey.rawValue)
  }
  
  // TODO: - remake examples for dynamic keys (everywhere), as they are for literal api now
  
  public func lastValue(forKey dynamicKey: String) -> (ValueExistential)? {
    _storage.lastNonNilValue(forKey: dynamicKey)
  }
  
  /// Returns the last recorded entry for the given key, including explicit or implicit `nil`.
  ///
  /// Use this when you need to audit the final write for a key.
  /// For everyday reads of the latest meaningful value, prefer ``lastValue(forKey:)`` or the subscript.
  ///
  /// - Parameter dynamicKey: The key to look up.
  /// - Returns: The last recorded ``ErrorInfo/OptionalValue`` (either `.value` or `.nilInstance`),
  ///   or `nil` if the key has never been recorded.
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  /// info[.id] = 5
  /// info[.id] = nil as Int?
  ///
  /// if let last = info.lastRecorded(forKey: .id) {
  ///   switch last {
  ///   case .value(let v): print("last value:", v)
  ///   case .nilInstance: print("last write was an explicit nil")
  ///   }
  /// }
  /// ```
  public func lastRecorded(forKey dynamicKey: String) -> OptionalValue? {
    fullInfo(forKey: dynamicKey)?.last.value
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - First For Key

extension ErrorInfo {
  public func firstValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)? {
    firstValue(forKey: literalKey.rawValue)
  }
  
  public func firstValue(forKey dynamicKey: String) -> (ValueExistential)? {
    _storage.firstNonNilValue(forKey: dynamicKey)
  }
}

