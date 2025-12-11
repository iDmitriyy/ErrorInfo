//
//  PrettyDescription.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

private import Foundation

// TODO: - remove foundation

// MARK: - Pretty Description for Any & Optional<T>

/// Cleans up the string representation of any value (including deeply nested optionals) by removing redundant "Optional(...)" wrappers.
///
/// # Example:
/// ```swift
/// prettyDescriptionOfOptional(any: Optional(Optional(42)))        // "42"
/// prettyDescriptionOfOptional(any: Optional<Optional<Int>>.none)  // "nil"
/// prettyDescriptionOfOptional(any: "Hello")                       // "Hello"
/// ```
/// - Parameter any: A value of type `Any`, which may or may not be an optional.
/// - Returns: A String representing the unwrapped value or "nil"
public func prettyDescriptionOfOptional<T>(any: T) -> String {
  if let value = _specialize(any, for: String.self) { return value }
  if let value = _specialize(any, for: Int.self) { return String(value) }
  if let value = _specialize(any, for: UInt.self) { return String(value) }
  
  if let custStr = any as? any CustomStringConvertible {
    return custStr.description
  }
  
  let description = String(describing: any)

  var intermediate = description[...]
  var isModified = false
  while intermediate.hasPrefix("Optional("), intermediate.hasSuffix(")") {
    isModified = true
    intermediate = intermediate.dropFirst(9).dropLast() // Remove "Optional(" from the front and ")" from the back
  }

  return isModified ? String(intermediate) : description
} // inlining has no effect on perfomance

/// Cleans up the string representation of any value (including deeply nested optionals) by removing redundant "Optional(...)" wrappers.
///
/// # Example:
/// ```swift
/// prettyDescriptionOfOptional(any: Optional(Optional(42)))        // "42"
/// prettyDescriptionOfOptional(any: Optional<Optional<Int>>.none)  // "nil"
/// prettyDescriptionOfOptional(any: "Hello")                       // "Hello"
/// ```
/// - Parameter any: A value of type `T?`, which may or may not be an optional.
/// - Returns: A String representing the unwrapped value or "nil"
public func prettyDescriptionOfOptional<T>(any: T?) -> String {
  switch any {
  case .some(let value):
    return prettyDescriptionOfOptional(any: value)
    
  case .none:
    return "nil" // returning hardcoded "nil" is ~2x faster than String(describing: any)
  }
} // inlining has no effect on perfomance
