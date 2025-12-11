//
//  ErrorInfo+Subscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - Subscript

// ErronInfoLiteralKey with @_disfavoredOverload String-base subscript allows to differemtiate between when it was a
// literal-key subscript and when it was defenitely some string value passed dynamically / at runtime.
// So this cleary separate the subscript access to 2 kinds:
// 1. a literal that can be found in source code or a predefined key which can be also found in sources
// 2. some string value created dynamically
// The same trick with sub-separaation can be done for append() functions
// Dictionary literal can then strictly be created with string literals, and when the key dynamic, another APIs are
// forced to be used.

extension ErrorInfo {
  /// Returns the last value associated with the given literal key.
  ///
  /// - Returns: The last value associated with key, or `nil` if no value is found.
  ///
  /// - Note:
  /// Use `allValues(forKey:)` if you need to access all values for a key.
  ///
  /// # Example:
  /// ```swift
  /// var info = ErrorInfo()
  /// info[.id] = 5
  /// info[.id] = 6
  ///
  /// let id = errorInfo[.id] as? Int // returns 6
  /// ```
  public subscript(_ literalKey: StringLiteralKey) -> (any ValueType)? {
    lastValue(forKey: literalKey)
  }
    
  /// A restricted subscript used to warn against removing values by mistake.
  ///
  /// - Note:
  /// Needed to warn users when they try to pass a nil literal, like `info["key"] = nil`
  ///
  /// - Deprecated: This subscript is deprecated and will show a warning if used. To remove values, use `removeValue(forKey:)`.
  /// - Unavailable: This subscript cannot be used for getting or setting values. Use `removeValue(forKey:)` to remove a value.
  @_disfavoredOverload
  public subscript(_: StringLiteralKey) -> InternalRestrictionToken? {
    @available(*, deprecated,
               message: "To remove value use removeValue(forKey:) function")
    set {}
    @available(*, unavailable, message: "This is a stub subscript. To remove value use removeValue(forKey:) function")
    get { nil }
  }
  
  /// Sets the value associated with the given literal key.
  ///
  /// This is a **set-only** subscript. Attempting to read through this
  /// subscript is unavailable. To retrieve stored values, use `allValues(forKey:)`.
  ///
  /// - If `newValue` is `nil`, the assignment records an explicitly-present
  ///   `nil` value (preserving Wrapped-type information from original optional value).
  /// - Duplicate values for the same key are handled according to
  ///   `ValueDuplicatePolicy.defaultForAppending`.
  /// - Collisions created during assignment are attributed to `CollisionSource.onSubscript`.
  ///
  /// # Example:
  /// ```swift
  /// let price: Double? = nil
  /// let message = "Failed to decode"
  ///
  /// errorInfo[.message] = message
  /// errorInfo["price"] = price // stores `nil` with Wrapped-type `Double`
  /// ```
  public subscript<V: ValueType>(_ literalKey: StringLiteralKey) -> V? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get {
      allValues(forKey: literalKey.rawValue)?.first as? V
    }
    set {
      _add(key: literalKey.rawValue,
           keyOrigin: literalKey.keyOrigin,
           value: newValue,
           preserveNilValues: true,
           duplicatePolicy: .defaultForAppending,
           collisionSource: .onSubscript(origin: nil)) // providing origin for a single key-value is an overhead
    }
  }
}

// TODO: check if there runtime issues with unavailable setter. If yes then make deprecated
