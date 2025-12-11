//
//  IsEqualAnyEqatable.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

extension ErrorInfoFuncs {
  /// Including optional. | Any that can be an Optional
  internal static func isEqualAnyEqatable<A: Equatable>(a: A, b: some Equatable) -> Bool {
    // FIXME: optional values
    // + https://forums.swift.org/t/comparing-two-any-values-for-equality-is-this-the-simplest-implementation/73816/8
    // Try use AnyHashable to compare nested optionals
    guard let b = b as? A else { return false }
    return a == b
  }
}

// public func prettyDescriptionOfOptional(any: Any) -> String {
//   // Check if `any` is an Optional type
//   if let optional = any as? Optional<Any> {
//     // Recursively unwrap the Optional
//     switch optional {
//     case .some(let value):
//       return prettyDescriptionOfOptional(any: value) // Continue unwrapping
//     case .none:
//       return "nil" // Return "nil" if the optional is nil
//     }
//   }
//
//   // Return the string representation of the value (not optional)
//   return String(describing: any)
// }
