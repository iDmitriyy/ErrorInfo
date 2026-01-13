//
//  ErrorInfoAny+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - Last For Key

extension ErrorInfoAny {
  public func lastValue(forKey key: String) -> (ValueExistential)? {
    _storage.lastNonNilValue(forKey: key)
  }
  
  public func lastRecorded(forKey key: String) -> ErrorInfoOptionalAny? {
    _storage.lastRecordedOptionalInstance(forKey: key)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - First For Key

extension ErrorInfoAny {
  public func firstValue(forKey key: String) -> (ValueExistential)? {
    _storage.firstNonNilValue(forKey: key)
  }
  
  public func firstRecorded(forKey key: String) -> ErrorInfoOptionalAny? {
    _storage.firstRecordedOptionalInstance(forKey: key)
  }
}
