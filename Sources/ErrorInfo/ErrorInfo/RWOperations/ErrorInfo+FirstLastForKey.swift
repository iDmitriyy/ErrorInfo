//
//  ErrorInfo+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 11/12/2025.
//

// MARK: - Last For Key

extension ErrorInfo {
  /// extension ErrorInfo {
  ///     /// Returns the last recorded entry including explicit nils.
  ///     /// Use when you need legacy-like removal semantics.
  ///     public func lastRecorded(forKey key: String) -> OptionalValue? {
  ///         fullInfo(forKey: key)?.last?.value
  ///     }
  /// }
  /// if let lastRecord = info.fullInfo(forKey: .url)?.last {
  ///   switch lastRecord.value {
  ///   case .value(let v): print("last value:", v)
  ///   case .nilInstance: print("last write was a nil")
  ///   }
  /// }
  public func lastValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)? {
    lastValue(forKey: literalKey.rawValue)
  }
  
  // TODO: - remake examples for dynamic keys (everywhere), as they are for literal api now
  
  public func lastValue(forKey dynamicKey: String) -> (ValueExistential)? {
    _storage.lastNonNilValue(forKey: dynamicKey)
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
