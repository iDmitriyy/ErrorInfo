//
//  ErrorInfo+ConvenienceSubscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

// Improvement: add keyPrefix arg to withOptions func

// MARK: - Modify With Custom Options

extension ErrorInfo {
  // MARK: - Static initializer
  
  /// Creates a new `ErrorInfo` and performs mutations inside a scoped options context.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// Use this when you want all operations in the `modify` closure to share the same defaults for
  /// duplicate handling, nil preservation and key prefixing.
  ///
  /// - Parameters:
  ///   - duplicatePolicy: How to handle equal values for the same key. Defaults to ``ValueDuplicatePolicy/defaultForAppending``.
  ///   - preserveNilValues: Whether `nil` assignments (typically emplicit) should be recorded as explicit `nil` entries. Defaults to `true`.
  ///   - prefixForKeys: A literal prefix to prepend to all keys added within the scope. Defaults to `nil`.
  ///   - collisionSource: The origin used for collision diagnostics for operations in the scope.
  ///   - modify: A closure that receives a ``ErrorInfo/CustomOptionsView`` to perform mutations.
  ///
  /// - Returns: A new `ErrorInfo` containing the applied changes.
  ///
  /// # Example:
  /// ```swift
  /// let info = ErrorInfo.withOptions(preserveNilValues: false) {
  ///   // Global option preserveNilValues = false, nil values are ignored
  ///   $0["age"] = 30 as Int?
  ///   $0["email"] = nil as String? // ignored because preserveNilValues == false
  ///
  ///   // Override on a per-operation basis: preserve nil values
  ///   0["username", preserveNilValues: true] = nil as String?
  /// }
  ///
  /// // info now contains: ["age": 30, "username": nil]
  /// ```
  public static func withOptions(duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending,
                                 preserveNilValues: Bool = true,
                                 prefixForKeys: StringLiteralKey? = nil,
                                 collisionSource: CollisionSource.Origin,
                                 modify: (consuming CustomOptionsView) -> Void) -> Self {
    var info = Self()
    info.appendWith(duplicatePolicy: duplicatePolicy,
                    preserveNilValues: preserveNilValues,
                    prefixForKeys: prefixForKeys,
                    collisionSource: collisionSource,
                    modify: modify)
    return info
  }
  
  /// Creates a new `ErrorInfo` and performs mutations inside a scoped options context.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// Use this when you want all operations in the `modify` closure to share the same defaults for
  /// duplicate handling, nil preservation and key prefixing.
  ///
  /// This convenience overload records the call site (`#fileID`, `#line`) as the collision origin for operations
  /// executed within the scope.
  ///
  /// - Parameters:
  ///   - duplicatePolicy: How to handle equal values for the same key. Defaults to ``ValueDuplicatePolicy/defaultForAppending``.
  ///   - preserveNilValues: Whether `nil` assignments (typically emplicit) should be recorded as explicit `nil` entries. Defaults to `true`.
  ///   - prefixForKeys: A literal prefix to prepend to all keys added within the scope. Defaults to `nil`.
  ///   - file: File identifier used as collision origin (defaults to `#fileID`).
  ///   - line: Line number used as collision origin (defaults to `#line`).
  ///   - modify: A closure that receives a ``ErrorInfo/CustomOptionsView`` to perform mutations.
  ///
  /// - Returns: A new `ErrorInfo` containing the applied changes.
  ///
  /// - SeeAlso: ``withOptions(duplicatePolicy:preserveNilValues:prefixForKeys:collisionSource:modify:)``
  ///
  /// # Example:
  /// ```swift
  /// let info = ErrorInfo.withOptions(preserveNilValues: false) {
  ///   // Global option preserveNilValues = false, nil values are ignored
  ///   $0["age"] = 30 as Int?
  ///   $0["email"] = nil as String? // ignored because preserveNilValues == false
  ///
  ///   // Override on a per-operation basis: preserve nil values
  ///   0["username", preserveNilValues: true] = nil as String?
  /// }
  ///
  /// // info now contains: ["age": 30, "username": nil]
  /// ```
  public static func withOptions(duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending,
                                 preserveNilValues: Bool = true,
                                 prefixForKeys: StringLiteralKey? = nil,
                                 file: StaticString = #fileID,
                                 line: UInt = #line,
                                 modify: (consuming CustomOptionsView) -> Void) -> Self {
    withOptions(duplicatePolicy: duplicatePolicy,
                preserveNilValues: preserveNilValues,
                prefixForKeys: prefixForKeys,
                collisionSource: .fileLine(file: file, line: line),
                modify: modify)
  }
  
  // MARK: - Mutating methods
  
  /// Mutates `self` by performing operations inside a scoped options context.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// Use this when you want all operations in the `modify` closure to share the same defaults for
  /// duplicate handling, nil preservation and key prefixing.
  ///
  /// - Parameters:
  ///   - duplicatePolicy: How to handle equal values for the same key. Defaults to ``ValueDuplicatePolicy/defaultForAppending``.
  ///   - preserveNilValues: Whether `nil` assignments (typically emplicit) should be recorded as explicit `nil` entries. Defaults to `true`.
  ///   - prefixForKeys: A literal prefix to prepend to all keys added within the scope. Defaults to `nil`.
  ///   - collisionSource: The origin used for collision diagnostics for operations in the scope.
  ///   - modify: A closure that receives a ``ErrorInfo/CustomOptionsView`` to perform mutations.
  ///
  /// # Example:
  /// ```swift
  /// let info = ErrorInfo.withOptions(preserveNilValues: false) {
  ///   // Global option preserveNilValues = false, nil values are ignored
  ///   $0["age"] = 30 as Int?
  ///   $0["email"] = nil as String? // ignored because preserveNilValues == false
  ///
  ///   // Override on a per-operation basis: preserve nil values
  ///   0["username", preserveNilValues: true] = nil as String?
  /// }
  ///
  /// // info now contains: ["age": 30, "username": nil]
  /// ```
  public mutating func appendWith(duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending,
                                  preserveNilValues: Bool = true,
                                  prefixForKeys: StringLiteralKey? = nil,
                                  collisionSource: CollisionSource.Origin,
                                  modify: (consuming CustomOptionsView) -> Void) {
    withUnsafeMutablePointer(to: &self) { pointer in
      let view = CustomOptionsView(pointer: pointer,
                                   duplicatePolicy: duplicatePolicy,
                                   preserveNilValues: preserveNilValues,
                                   prefixForKeys: prefixForKeys,
                                   collisionOrigin: collisionSource)
      modify(view)
    }
  }
  
  /// Mutates `self` by performing operations inside a scoped options context.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// Use this when you want all operations in the `modify` closure to share the same defaults for
  /// duplicate handling, nil preservation and key prefixing.
  ///
  /// This convenience overload records the call site (`#fileID`, `#line`) as the collision origin for operations
  /// executed within the scope.
  ///
  /// - Parameters:
  ///   - duplicatePolicy: How to handle equal values for the same key. Defaults to ``ValueDuplicatePolicy/defaultForAppending``.
  ///   - preserveNilValues: Whether `nil` assignments (typically emplicit) should be recorded as explicit `nil` entries. Defaults to `true`.
  ///   - prefixForKeys: A literal prefix to prepend to all keys added within the scope. Defaults to `nil`.
  ///   - file: File identifier used as collision origin (defaults to `#fileID`).
  ///   - line: Line number used as collision origin (defaults to `#line`).
  ///   - modify: A closure that receives a ``ErrorInfo/CustomOptionsView`` to perform mutations.
  ///
  /// - SeeAlso: ``appendWith(duplicatePolicy:preserveNilValues:prefixForKeys:collisionSource:modify:)``
  ///
  /// # Example:
  /// ```swift
  /// let info = ErrorInfo.withOptions(preserveNilValues: false) {
  ///   // Global option preserveNilValues = false, nil values are ignored
  ///   $0["age"] = 30 as Int?
  ///   $0["email"] = nil as String? // ignored because preserveNilValues == false
  ///
  ///   // Override on a per-operation basis: preserve nil values
  ///   0["username", preserveNilValues: true] = nil as String?
  /// }
  ///
  /// // info now contains: ["age": 30, "username": nil]
  /// ```
  public mutating func appendWith(duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending,
                                  preserveNilValues: Bool = true,
                                  prefixForKeys: StringLiteralKey? = nil,
                                  file: StaticString = #fileID,
                                  line: UInt = #line,
                                  modify: (consuming CustomOptionsView) -> Void) {
    appendWith(duplicatePolicy: duplicatePolicy,
               preserveNilValues: preserveNilValues,
               prefixForKeys: prefixForKeys,
               collisionSource: .fileLine(file: file, line: line),
               modify: modify)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Subscript

extension ErrorInfo.CustomOptionsView {
  /// Sets a value for a literal key using the surrounding options context.
  ///
  /// Read access is unavailable; use ``ErrorInfo/allValues(forKey:)`` or other query APIs instead.
  ///
  /// - Parameters:
  ///   - literalKey: The literal key to set.
  ///   - preserveNilValues: Overrides the context’s `preserveNilValues` for this operation when provided.
  ///   - duplicatePolicy: Overrides the context’s `duplicatePolicy` for this operation when provided.
  ///
  /// - Note: The effective key may be prefixed if the context was created with `prefixForKeys`.
  ///
  /// # Example
  /// ```swift
  /// ErrorInfo.withOptions(prefixForKeys: .debug) { view in
  ///   view[.message] = "Timeout" // stored under "debug_message"
  /// }
  /// ```
  public subscript<V: ErrorInfo.ValueProtocol>(
    _ literalKey: StringLiteralKey,
    preserveNilValues: Bool? = nil,
    duplicatePolicy: ValueDuplicatePolicy? = nil,
  ) -> V? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get { pointer.pointee.lastValue(forKey: literalKey) as? V }
    nonmutating set {
      let resolvedKey = Self.resolveKey(literalKey: literalKey, prefixForKeys: prefixForKeys)
      pointer.pointee._add(key: resolvedKey.rawValue,
                           keyOrigin: resolvedKey.keyOrigin,
                           value: newValue,
                           preserveNilValues: preserveNilValues ?? self.preserveNilValues,
                           duplicatePolicy: duplicatePolicy ?? self.duplicatePolicy,
                           collisionSource: .onSubscript(origin: collisionOrigin))
    }
  }
  
  private static func resolveKey(literalKey: StringLiteralKey,
                                 prefixForKeys: StringLiteralKey?) -> (rawValue: String, keyOrigin: KeyOrigin) {
    let keyString: String
    let keyOrigin: KeyOrigin
    if let prefixForKeys {
      let combinedLiteralKey = prefixForKeys + literalKey
      keyString = combinedLiteralKey.rawValue
      keyOrigin = .modified(original: combinedLiteralKey.keyOrigin)
    } else {
      keyString = literalKey.rawValue
      keyOrigin = literalKey.keyOrigin
    }
    return (keyString, keyOrigin)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - CustomOptions View

extension ErrorInfo {
  /// A lightweight, non‑escaping view that applies scoped options to mutations.
  ///
  /// Instances of `CustomOptionsView` are created by
  /// - ``ErrorInfo/withOptions(duplicatePolicy:preserveNilValues:prefixForKeys:collisionSource:modify:)``
  /// - ``ErrorInfo/appendWith(duplicatePolicy:preserveNilValues:prefixForKeys:collisionSource:modify:)``
  ///
  /// and are valid only within the lifetime of the `modify` closure.
  ///
  /// Values set through the view inherit the context options unless explicitly overridden per operation.
  public struct CustomOptionsView: ~Copyable, ~Escapable {
    private let pointer: UnsafeMutablePointer<ErrorInfo> // TODO: check CoW not triggered | inplace mutation
    private let duplicatePolicy: ValueDuplicatePolicy
    private let preserveNilValues: Bool
    private let prefixForKeys: StringLiteralKey?
    private let collisionOrigin: CollisionSource.Origin
    
    @_lifetime(borrow pointer)
    fileprivate init(pointer: UnsafeMutablePointer<ErrorInfo>,
                     duplicatePolicy: ValueDuplicatePolicy,
                     preserveNilValues: Bool,
                     prefixForKeys: StringLiteralKey?,
                     collisionOrigin: CollisionSource.Origin) {
      self.pointer = pointer
      self.duplicatePolicy = duplicatePolicy
      self.preserveNilValues = preserveNilValues
      self.prefixForKeys = prefixForKeys
      self.collisionOrigin = collisionOrigin
    }
  }
}
