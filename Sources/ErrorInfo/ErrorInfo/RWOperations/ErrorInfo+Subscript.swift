//
//  ErrorInfo+Subscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

extension ErrorInfo {
  // MARK: - Read access Subscript
  
  public subscript(_ literalKey: StringLiteralKey) -> (ValueExistential)? {
    lastValue(forKey: literalKey)
  }
  
  // MARK: - Mutating subscript
  
  /// Sets the value associated with the given literal key.
  ///
  /// This is a **set-only** subscript. Attempting to read through this
  /// subscript is unavailable. To retrieve stored values, use `allValues(forKey:)`.
  ///
  /// - If `newValue` is `nil`, the assignment records an explicitly-present
  ///   `nil` value (preserving Wrapped-type information from original optional value).
  /// - Duplicate values for the same key are handled according to
  ///   `ValueDuplicatePolicy.defaultForAppending`.
  /// - Collisions created during assignment are attributed to `WriteProvenance.onSubscript`.
  ///
  /// # Example:
  /// ```swift
  /// let message = "Failed to decode"
  /// let price: Double? = nil
  ///
  /// errorInfo[.message] = message
  /// errorInfo["price"] = price // stores `nil` with Wrapped-type `Double`
  /// ```
  public subscript<V: ValueProtocol>(_ literalKey: StringLiteralKey) -> V? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get {
      lastValue(forKey: literalKey) as? V
    }
    set {
      _addDetachedValue(
        newValue,
        shouldPreserveNilValues: true,
        duplicatePolicy: .defaultForAppending,
        forKey: literalKey.rawValue,
        keyOrigin: literalKey.keyOrigin,
        writeProvenance: .onSubscript(origin: nil),
      ) // providing origin for a single key-value is an overhead for binary size
    }
  }
}

// StringLiteralKey with @_disfavoredOverload String-base subscript allows to differemtiate between when it was a
// literal-key subscript and when it was defenitely some string value passed dynamically / at runtime.
// So this cleary separate the subscript access to 2 kinds:
// 1. a literal that can be found in source code or a predefined key which can be also found in sources
// 2. some string value created dynamically
// The same trick with sub-separaation can be done for append() functions
// Dictionary literal can then strictly be created with string literals, and when the key dynamic, another APIs are
// forced to be used.

// TODO: check if there runtime issues with unavailable setter. If yes then make deprecated
