//
//  ErrorInfoProtocols.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

// MARK: - Error Info

/// This approach addresses several important concerns:
/// - Thread Safety: The Sendable requirement is essential to prevent data races and ensure safe concurrent access.
/// - String Representation: Requiring CustomStringConvertible forces developers to provide meaningful string representations for stored values, which is invaluable for debugging and logging. It also prevents unexpected results when converting values to strings.
/// - Collision Resolution: The Equatable requirement allows to detect and potentially resolve collisions if different values are associated with the same key. This adds a layer of robustness.
public typealias ErrorInfoValueType = CustomStringConvertible & Equatable & Sendable

/// If a collision happens, then two symbols are used as a start of random key suffix:
/// for subscript: `$` , e.g. "keyName$Ta5"
/// for merge functions: `#` , e.g. "keyName_don0_file_line_FileName_81_#Wng"
public protocol ErrorInfoType<Key, Value>: Sequence where Self.Element == (key: Key, value: Value) {
  associatedtype Key: Hashable
  associatedtype Value
  
  func sendableReprsentation() -> any Sequence<(key: String, value: any Sendable)>
}

public protocol InformativeError: Error {
  associatedtype ErrorInfoType
  
  var info: ErrorInfoType { get }
}

public protocol IterableErrorInfo<Key, Value>: Sequence where Key: Hashable, Self.Iterator.Element == (key: Key, value: Value) {
  associatedtype Key
  associatedtype Value
  
  var isEmpty: Bool { get }
  
  var count: Int { get }
}

protocol ErrorInfoOptionalProtocol {
  associatedtype Value
  associatedtype TypeOfWrapped
  
  static func value(_: Value) -> Self
  static func nilInstance(typeOfWrapped: TypeOfWrapped) -> Self
  
  var isValue: Bool { get }
}

extension ErrorInfoOptionalProtocol {
  @inlinable @inline(__always) var isNil: Bool { !isValue }
}
