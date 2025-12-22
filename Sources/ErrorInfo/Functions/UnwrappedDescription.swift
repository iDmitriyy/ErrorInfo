//
//  PrettyDescription.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

// MARK: - Pretty Description for Any & Optional<T>

/// Returns a string representation of an optional value removing redundant `Optional( )` wrappers from result string.
///
/// It removes all occurrences of `Optional(...)` from the string representation, leaving only the unwrapped value.
/// If the value is `nil`, it returns `"nil"`.
/// It works with any values, including deeply nested optionals.
///
/// # Example:
/// ```swift
/// unwrappedDescription(of: Optional(Optional(42))) as Any        // "42"
/// unwrappedDescription(of: Optional<Optional<Int>>.none) as Any  // "nil"
/// unwrappedDescription(of: "Hello" as Any)                       // "Hello"
/// unwrappedDescription(of: Optional("World") as Any)             // "World"
/// ```
///
/// - Parameter any: A value of any type, which may or may not be `nil` or wrapped in multiple `Optional` layers.
/// - Returns: A string representation of the unwrapped value, or `"nil"` if the value is `nil`.
public func unwrappedDescription(of any: some Any) -> String {
  if let value = _specialize(any, for: String.self) { return value }
  if let value = _specialize(any, for: Int.self) { return String(value) }
  if let value = _specialize(any, for: Bool.self) { return String(value) }
  if let value = _specialize(any, for: Double.self) { return String(value) }
  
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

/// Returns a string representation of an optional value removing redundant `Optional( )` wrappers from result string.
///
/// It removes all occurrences of `Optional(...)` from the string representation, leaving only the unwrapped value.
/// If the value is `nil`, it returns `"nil"`.
/// It works with any values, including deeply nested optionals.
///
/// # Example:
/// ```swift
/// unwrappedDescription(of: Optional(Optional(42))) as Any        // "42"
/// unwrappedDescription(of: Optional<Optional<Int>>.none) as Any  // "nil"
/// unwrappedDescription(of: "Hello" as Any)                       // "Hello"
/// unwrappedDescription(of: Optional("World") as Any)             // "World"
/// ```
///
/// - Parameter any: An optional value of any type, which may or may not be `nil` or wrapped in multiple `Optional` layers.
/// - Returns: A string representation of the unwrapped value, or `"nil"` if the value is `nil`.
public func unwrappedDescription<T>(of optionalAny: T?) -> String {
  switch optionalAny {
  case .some(let value):
     // if let value = _specialize(any, for: String.self) { return value } – _specialize has no effect here.
     // However, there is significant perfomance gain when adding _specialize
     // inside (some Any) overload of `unwrappedDescription(of:)` above.
    return unwrappedDescription(of: value)
    
  case .none:
    return "nil" // returning hardcoded "nil" is ~2x faster than String(describing: any)
  }
} // inlining has no effect on perfomance
