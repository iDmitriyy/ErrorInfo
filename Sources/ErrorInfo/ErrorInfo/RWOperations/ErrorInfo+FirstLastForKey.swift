//
//  ErrorInfo+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 11/12/2025.
//

// MARK: - Last For Key

extension ErrorInfo {
  public func lastValue(forKey dynamicKey: String) -> (ValueExistential)? {
    _storage.lastNonNilValue(forKey: dynamicKey)
  }
  
  public func lastRecorded(forKey dynamicKey: String) -> OptionalValue? {
    _storage.lastRecordedOptionalInstance(forKey: dynamicKey)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - First For Key

extension ErrorInfo {
  public func firstValue(forKey dynamicKey: String) -> (ValueExistential)? {
    _storage.firstNonNilValue(forKey: dynamicKey)
  }
  
  public func firstRecorded(forKey dynamicKey: String) -> OptionalValue? {
    _storage.firstRecordedOptionalInstance(forKey: dynamicKey)
  }
}

