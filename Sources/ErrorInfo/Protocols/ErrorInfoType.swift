//
//  ErrorInfoType.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

/// If a collision happens, then two symbols are used as a start of random key suffix:
/// for subscript: `$` , e.g. "keyName$Ta5"
/// for merge functions: `#` , e.g. "keyName_don0_file_line_FileName_81_#Wng"
public protocol ErrorInfoType<Key, Value>: Sequence where Self.Element == (key: Key, value: Value) {
  associatedtype Key: Hashable
  associatedtype Value
  
  func sendableReprsentation() -> any Sequence<(key: String, value: any Sendable)>
}
