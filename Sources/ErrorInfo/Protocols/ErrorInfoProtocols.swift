//
//  ErrorInfoProtocols.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

// MARK: - Error Info

/// If a collision happens, then two symbols are used as a start of random key suffix:
/// for subscript: `$` , e.g. "keyName$Ta5"
/// for merge functions: `#` , e.g. "keyName_don0_file_line_FileName_81_#Wng"
public protocol ErrorInfoType<Key, Value>: Sequence where Self.Element == (key: Key, value: Value) {
  associatedtype Key: Hashable
  associatedtype Value
  
  func sendableReprsentation() -> any Sequence<(key: String, value: any Sendable)>
}

public protocol IterableErrorInfo<Key, Value>: Sequence where Key: Hashable, Self.Iterator.Element == (key: Key, value: Value) {
  associatedtype Key
  associatedtype Value
  
  var isEmpty: Bool { get }
  
  var count: Int { get }
}
