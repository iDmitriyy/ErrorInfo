//
//  ErrorInfo+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 11/12/2025.
//

// MARK: - Last For Key

extension ErrorInfo {
  public func lastValue(forKey key: String) -> (ValueExistential)? {
    _storage.lastNonNilValue(forKey: key)
  } // inlining worsen performance
  
  public func lastRecorded(forKey key: String) -> OptionalValue? {
    _storage.lastRecordedOptionalInstance(forKey: key)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - First For Key

extension ErrorInfo {
  public func firstValue(forKey key: String) -> (ValueExistential)? {
    _storage.firstNonNilValue(forKey: key)
  }
  
  public func firstRecorded(forKey key: String) -> OptionalValue? {
    _storage.firstRecordedOptionalInstance(forKey: key)
  }
}

