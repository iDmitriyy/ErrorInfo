//
//  KeyValueLookupResult.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 15/12/2025.
//

/// Represents the result of a key-value lookup in `ErrorInfo` storage.
public enum KeyValueLookupResult {
  /// Indicates that no value, either `non-nil` or `nil`, is associated with the key.
  case nothing
  
  /// Indicates that exactly one `non-nil` value is associated with the key.
  case singleValue
  
  /// Indicates that exactly one `nil` value is associated with the key.
  case singleNil
  
  /// Indicates that multiple values (both `non-nil` and nil) are associated with the key.
  /// Contains the count of `non-nil` and `nil` values.
  case multipleRecords(valuesCount: Int, nilCount: Int)
}

public enum KeyNonOptionalValueLookupResult {
  /// Indicates that no value, either `non-nil` or `nil`, is associated with the key.
  case nothing
  
  /// Indicates that exactly one `non-nil` value is associated with the key.
  case singleValue
    
  /// Indicates that multiple values are associated with the key.
  /// Contains the count of `non-nil` values.
  case multipleRecords(valuesCount: Int)
}
