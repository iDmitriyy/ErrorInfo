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
  let description = String(describing: any)

  var intermediate = description[...]
  var isModified = false
  while intermediate.hasPrefix("Optional("), intermediate.hasSuffix(")") {
    isModified = true
    intermediate = intermediate.dropFirst(9).dropLast() // Remove "Optional(" from the front and ")" from the back
  }

  return isModified ? String(intermediate) : description
 }

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
    let description = String(describing: value)
    
    var intermediate = description[...]
    var isModified = false
    while intermediate.hasPrefix("Optional("), intermediate.hasSuffix(")") {
      intermediate = intermediate.dropFirst(9).dropLast()
      isModified = true
    }
    
    return isModified ? String(intermediate) : description
  case .none:
    return String(describing: any) // "nil"
  }
}
