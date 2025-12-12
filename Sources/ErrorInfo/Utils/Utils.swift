//
//  Utils.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

/// This is a workaround to cast Sendable existential to existential of another type.
///
/// https://forums.swift.org/t/runtime-casts-of-sendable-type-to-another-sendable-type-not-possible/82070/2
///
/// # WARNING
/// The code below will return non nil value, and nonSendable is succesfuly casted.
/// Use when value is known to be Sendable.
/// ```swift
/// let nonSendable = NonSendable()
///
/// if let nonSendable = conditionalCast(nonSendable, to: (any Sendable).self) {
///    print(nonSendable) // ! succesfully casted even nonSendable as non Sendable
/// }
/// ```
@inlinable @inline(__always)
internal func __conditionalCast<T, U>(_ value: T, to _: U.Type) -> U? {
  value as? U
}
