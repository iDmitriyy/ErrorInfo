//
//  ErrorInfo+Subscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

extension ErrorInfo {
  // MARK: - User Guidance Subscript
  
  /// A guidance-only subscript that prevents accidental removal by `nil` assignment.
  ///
  /// This subscript exists to catch patterns like `info[.key] = nil`, which can look like
  /// “remove the value” in legacy dictionaries. In ErrorInfo, removal is explicit and
  /// `nil` can be recorded as a meaningful entry. Use dedicated removal APIs instead.
  ///
  /// - Get: Unavailable.
  /// - Set: Deprecated. Use ``removeAllRecords(forKey:)`` (or other explicit removal APIs) instead.
  ///
  /// Rationale: Keeping removal explicit avoids silent loss of earlier context and aligns with
  /// ErrorInfo’s multi-record model.
  @_disfavoredOverload
  public subscript(_: StringLiteralKey) -> InternalRestrictionToken? {
    @available(*, unavailable, message: "This is a stub subscript. To remove value use removeValue(forKey:) function")
    get { nil }
    
    @available(*, deprecated, message: "To remove value use removeValue(forKey:) function")
    set {}
  }
  
  // MARK: - Read access Subscript
  
  /// Returns the last non‑nil value associated with the given literal key.
  ///
  /// This subscript is the ergonomic read path and surfaces the latest meaningful value.
  /// Explicit `nil` entries are preserved for auditing but are skipped here. Use
  /// ``fullInfo(forKey:)`` or `lastRecorded(forKey:)`to inspect the last
  /// recorded entry including `nil`, its ``KeyOrigin``, and ``CollisionSource``.
  ///
  /// ## Rationale:
  /// From a usability standpoint, the subscript is the ergonomic read path and should surface the last meaningful value by default.
  /// ErrorInfo intentionally separates “removal” from “explicitly recorded `nil`” so you don’t accidentally lose a meaningful prior value.
  /// Returning `nil` just because a later stage wrote a `nil` would reintroduce the classic “silent overwrite” pitfall ``ErrorInfo`` is trying to avoid.
  /// - Subscript is returning the last non‑nil value.
  ///   This matches how most callers read “the latest meaningful value” and prevents a trailing `nil`
  ///   from blanking useful context.
  /// - Iteration and the firstValue/lastValue APIs already operate on non‑nil values;
  ///   the subscript should remain consistent with that model for predictability and ergonomics.
  /// - Explicit `nil` is still preserved as a record for auditing and legacy‑style “removal” semantics.
  ///   When you need to know that the last write was `nil`, use `fullInfo(forKey:)` or
  ///   a convenience  `lastRecorded(forKey:)` to inspect the final record including `nil`
  ///   and its provenance (``KeyOrigin``, ``CollisionSource``).
  /// - This approach balances resilience (no silent loss of a good value due to a late `nil`)
  ///   with precision (you can still detect and reason about `nil` writes when you care).
  ///
  /// - Parameter literalKey: The literal key to read.
  /// - Returns: The last non‑nil value for the key, or `nil` if none exists.
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  /// info[.id] = 5
  /// info[.id] = 6
  /// info[.id] = nil as Int?
  ///
  /// info[.id] // 6
  /// ```
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
  /// - Collisions created during assignment are attributed to `CollisionSource.onSubscript`.
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
      _add(key: literalKey.rawValue,
           keyOrigin: literalKey.keyOrigin,
           value: newValue,
           preserveNilValues: true,
           duplicatePolicy: .defaultForAppending,
           collisionSource: .onSubscript(origin: nil)) // providing origin for a single key-value is an overhead for binary size
    }
  }
}

// ErronInfoLiteralKey with @_disfavoredOverload String-base subscript allows to differemtiate between when it was a
// literal-key subscript and when it was defenitely some string value passed dynamically / at runtime.
// So this cleary separate the subscript access to 2 kinds:
// 1. a literal that can be found in source code or a predefined key which can be also found in sources
// 2. some string value created dynamically
// The same trick with sub-separaation can be done for append() functions
// Dictionary literal can then strictly be created with string literals, and when the key dynamic, another APIs are
// forced to be used.

// TODO: check if there runtime issues with unavailable setter. If yes then make deprecated

