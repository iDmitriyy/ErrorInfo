//
//  ErrorInfoAny+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - Last For Key

extension ErrorInfoAny {
  public func lastValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)? {
    lastValue(forKey: literalKey.rawValue)
  }
    
  @_disfavoredOverload
  public func lastValue(forKey dynamicKey: String) -> (ValueExistential)? {
    _storage.lastNonNilValue(forKey: dynamicKey)
  }
  
  public func lastRecorded(forKey dynamicKey: String) -> ErrorInfoOptionalAny? {
    _storage.lastRecordedOptionalInstance(forKey: dynamicKey)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - First For Key

extension ErrorInfoAny {
  public func firstValue(forKey literalKey: StringLiteralKey) -> (ValueExistential)? {
    firstValue(forKey: literalKey.rawValue)
  }
  
  public func firstRecorded(forKey dynamicKey: String) -> ErrorInfoOptionalAny? {
    _storage.firstRecordedOptionalInstance(forKey: dynamicKey)
  }
  
  @_disfavoredOverload
  public func firstValue(forKey dynamicKey: String) -> (ValueExistential)? {
    _storage.firstNonNilValue(forKey: dynamicKey)
  }
}
