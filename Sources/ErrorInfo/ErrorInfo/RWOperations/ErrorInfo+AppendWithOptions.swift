//
//  ErrorInfo+AppendWithOptions.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

// MARK: - Static initializer with options

extension ErrorInfo {
  /// Creates a new `ErrorInfo` in a scoped options context and performs mutations inside.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// Scopes often represent distinct meaningful contexts (e.g., “initial flow” vs “retry flow”).
  /// Use this when you want all operations in the `modify` closure to share the same prams for
  /// duplicate handling, `nil` preservation and key prefixing.
  ///
  /// You can define custom string origin for a scope.
  /// This convenience overload records the call site (`#fileID`, `#line`) as the collision origin for operations
  /// executed within the scope.
  ///
  /// - Parameters:
  ///   - duplicatePolicy: How to handle equal values for the same key. Defaults to ``ValueDuplicatePolicy/defaultForAppending``.
  ///   - nilPreservation: Whether `nil` assignments (typically emplicit) should be recorded as explicit `nil` entries. Defaults to `true`.
  ///   - prefixForKeys: A literal prefix to prepend to all keys added within the scope. Defaults to `nil`.
  ///   - file: File identifier used as collision origin (defaults to `#fileID`).
  ///   - line: Line number used as collision origin (defaults to `#line`).
  ///   - modify: A closure that receives a ``ErrorInfo/CustomOptionsView`` to perform mutations.
  ///
  /// - Returns: A new `ErrorInfo` containing the applied changes.
  ///
  /// - SeeAlso: ``withOptions(duplicatePolicy:nilPreservation:prefixForKeys:origin:modify:)``
  ///
  /// # Example:
  /// ```swift
  /// let info = ErrorInfo.withOptions(nilPreservation: false) {
  ///   // Global option nilPreservation = false, `nil` values are ignored
  ///   $0["age"] = 30 as Int?
  ///   $0["email"] = `nil` as String? // ignored because nilPreservation == false
  ///
  ///   // Override on a per-operation basis: preserve `nil` values
  ///   0["username", nilPreservation: true] = `nil` as String?
  /// }
  ///
  /// // info now contains: ["age": 30, "username": nil]
  /// ```
  public static func withOptions(duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending,
                                 nilPreservation: Bool = true,
                                 prefixForKeys: StringLiteralKey? = nil,
                                 file: StaticString = #fileID,
                                 line: UInt = #line,
                                 modify: (consuming CustomOptionsView) -> Void) -> Self {
    withOptions(duplicatePolicy: duplicatePolicy,
                nilPreservation: nilPreservation,
                prefixForKeys: prefixForKeys,
                origin: .fileLine(file: file, line: line),
                modify: modify)
  }
  
  /// Creates a new `ErrorInfo` in a scoped options context and performs mutations inside.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// Scopes often represent distinct meaningful contexts (e.g., “initial flow” vs “retry flow”).
  /// Use this when you want all operations in the `modify` closure to share the same prams for
  /// duplicate handling, `nil` preservation and key prefixing.
  ///
  /// You can define custom string origin for a scope.
  ///
  /// - Parameters:
  ///   - duplicatePolicy: How to handle equal values for the same key. Defaults to ``ValueDuplicatePolicy/defaultForAppending``.
  ///   - nilPreservation: Whether `nil` assignments (typically emplicit) should be recorded as explicit `nil` entries. Defaults to `true`.
  ///   - prefixForKeys: A literal prefix to prepend to all keys added within the scope. Defaults to `nil`.
  ///   - origin: The origin used for collision diagnostics for operations in the scope.
  ///   - modify: A closure that receives a ``ErrorInfo/CustomOptionsView`` to perform mutations.
  ///
  /// - Returns: A new `ErrorInfo` containing the applied changes.
  ///
  /// # Example:
  /// ```swift
  /// var info = ErrorInfo.withOptions(nilPreservation: false, origin: "adminOverride") {
  ///   // Global option nilPreservation = false, `nil` values are ignored
  ///   $0["age"] = 30 as Int?
  ///   $0["email"] = nil as String? // ignored because nilPreservation == false
  ///
  ///   // Override on a per-operation basis: preserve `nil` values
  ///   0["username", nilPreservation: true] = nil as String?
  /// }
  ///
  /// // info now contains: ["age": 30, "username": nil]
  /// ```
  public static func withOptions(duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending,
                                 nilPreservation: Bool = true,
                                 prefixForKeys: StringLiteralKey? = nil,
                                 origin: WriteProvenance.Origin,
                                 modify: (consuming CustomOptionsView) -> Void) -> Self {
    var info = Self()
    info.appendWith(duplicatePolicy: duplicatePolicy,
                    nilPreservation: nilPreservation,
                    prefixForKeys: prefixForKeys,
                    origin: origin,
                    modify: modify)
    return info
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Mutating methods

extension ErrorInfo {
  /// Mutates `self` in a scoped options context  by performing the given operations.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// Scopes often represent distinct meaningful contexts (e.g., “initial flow” vs “retry flow”).
  /// Use this when you want all operations in the `modify` closure to share the same prams for
  /// duplicate handling, `nil` preservation and key prefixing.
  ///
  /// You can define custom string origin for a scope.
  /// This convenience overload records the call site (`#fileID`, `#line`) as the collision origin for operations
  /// executed within the scope.
  ///
  /// - Parameters:
  ///   - duplicatePolicy: How to handle equal values for the same key. Defaults to ``ValueDuplicatePolicy/defaultForAppending``.
  ///   - nilPreservation: Whether `nil` assignments (typically implicit) should be recorded as explicit `nil` entries. Defaults to `true`.
  ///   - prefixForKeys: A literal prefix to prepend to all keys added within the scope. Defaults to `nil`.
  ///   - file: File identifier used as collision origin (defaults to `#fileID`).
  ///   - line: Line number used as collision origin (defaults to `#line`).
  ///   - modify: A closure that receives a ``ErrorInfo/CustomOptionsView`` to perform mutations.
  ///
  /// - SeeAlso: ``appendWith(duplicatePolicy:nilPreservation:prefixForKeys:origin:modify:)``
  ///
  /// # Example:
  /// ```swift
  /// var info = ErrorInfo()
  ///
  /// info.appendWith(nilPreservation: false) {
  ///   // Global option nilPreservation = false, `nil` values are ignored
  ///   $0["age"] = 30 as Int?
  ///   $0["email"] = nil as String? // ignored because nilPreservation == false
  ///
  ///   // Override on a per-operation basis: preserve `nil` values
  ///   0["username", nilPreservation: true] = nil as String?
  /// }
  /// // info now contains: ["age": 30, "username": nil]
  ///
  /// info.appendWith(prefixForKeys: "transaction") {
  ///   $0[.errorMessage] = "Card declined"
  ///   $0[.transactionID] = "ae953b20-bc6e-4f90-961f-2364ae6d497b"
  /// }
  /// ```
  public mutating func appendWith(duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending,
                                  nilPreservation: Bool = true,
                                  prefixForKeys: StringLiteralKey? = nil,
                                  file: StaticString = #fileID,
                                  line: UInt = #line,
                                  modify: (consuming CustomOptionsView) -> Void) {
    appendWith(duplicatePolicy: duplicatePolicy,
               nilPreservation: nilPreservation,
               prefixForKeys: prefixForKeys,
               origin: .fileLine(file: file, line: line),
               modify: modify)
  }
  
  /// Mutates `self` in a scoped options context  by performing the given operations.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// Scopes often represent distinct meaningful contexts (e.g., “initial flow” vs “retry flow”).
  /// Use this when you want all operations in the `modify` closure to share the same prams for
  /// duplicate handling, `nil` preservation and key prefixing.
  ///
  /// You can define custom string origin for a scope.
  ///
  /// - Parameters:
  ///   - duplicatePolicy: How to handle equal values for the same key. Defaults to ``ValueDuplicatePolicy/defaultForAppending``.
  ///   - nilPreservation: Whether `nil` assignments (typically implicit) should be recorded as explicit `nil` entries. Defaults to `true`.
  ///   - prefixForKeys: A literal prefix to prepend to all keys added within the scope. Defaults to `nil`.
  ///   - origin: The origin used for collision diagnostics for operations in the scope.
  ///   - modify: A closure that receives a ``ErrorInfo/CustomOptionsView`` to perform mutations.
  ///
  /// # Example:
  /// ```swift
  /// var info = ErrorInfo()
  ///
  /// info.appendWith(nilPreservation: false) {
  ///   // Global option nilPreservation = false, `nil` values are ignored
  ///   $0["age"] = 30 as Int?
  ///   $0["email"] = nil as String? // ignored because nilPreservation == false
  ///
  ///   // Override on a per-operation basis: preserve `nil` values
  ///   0["username", nilPreservation: true] = nil as String?
  /// }
  /// // info now contains: ["age": 30, "username": nil]
  ///
  /// info.appendWith(prefixForKeys: "transaction", origin: "purchase") {
  ///   $0[.errorMessage] = "Card declined"
  ///   $0[.transactionID] = "ae953b20-bc6e-4f90-961f-2364ae6d497b"
  /// }
  /// ```
  public mutating func appendWith(duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending,
                                  nilPreservation: Bool = true,
                                  prefixForKeys: StringLiteralKey? = nil,
                                  origin: WriteProvenance.Origin,
                                  modify: (consuming CustomOptionsView) -> Void) {
    withUnsafeMutablePointer(to: &self) { pointer in
      let view = CustomOptionsView(pointer: pointer,
                                   duplicatePolicy: duplicatePolicy,
                                   nilPreservation: nilPreservation,
                                   prefixForKeys: prefixForKeys,
                                   origin: origin)
      modify(view)
    }
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
  ///   - nilPreservation: Overrides the context’s `nilPreservation` for this operation when provided.
  ///   - duplicatePolicy: Overrides the context’s `duplicatePolicy` for this operation when provided.
  ///
  /// - Note: The effective key may be prefixed if the context was created with `prefixForKeys`.
  ///
  /// # Example
  /// ```swift
  /// ErrorInfo.withOptions(prefixForKeys: .debug) {
  ///   $0[.message] = "Timeout" // stored under "debug_message"
  /// }
  /// // results in: ["debug_message": "Timeout"]
  /// ```
  public subscript<V: ErrorInfo.ValueProtocol>(
    _ literalKey: StringLiteralKey,
    nilPreservation: Bool? = nil,
    duplicatePolicy: ValueDuplicatePolicy? = nil,
  ) -> V? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get { pointer.pointee.lastValue(forKey: literalKey) as? V }
    nonmutating set {
      let resolvedKey = Self.resolveKey(literalKey: literalKey, prefixForKeys: prefixForKeys)
      pointer.pointee._addDetachedValue(
        newValue,
        shouldPreserveNilValues: nilPreservation ?? self.nilPreservation,
        duplicatePolicy: duplicatePolicy ?? self.duplicatePolicy,
        forKey: resolvedKey.rawValue,
                                        keyOrigin: resolvedKey.keyOrigin,
                                        writeProvenance: .onSubscript(origin: origin)
      )
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

// MARK: - CustomOptions View Imp

extension ErrorInfo {
  /// A view that applies scoped options to mutations.
  ///
  /// Instances of `CustomOptionsView` are created by
  /// - ``ErrorInfo/withOptions(duplicatePolicy:nilPreservation:prefixForKeys:origin:modify:)``
  /// - ``ErrorInfo/appendWith(duplicatePolicy:nilPreservation:prefixForKeys:origin:modify:)``
  ///
  /// and are valid only within the lifetime of the `modify` closure.
  ///
  /// Values set through the view inherit the context options unless explicitly overridden per operation.
  public struct CustomOptionsView: ~Copyable, ~Escapable {
    private let pointer: UnsafeMutablePointer<ErrorInfo> // TODO: check CoW not triggered | inplace mutation
    private let duplicatePolicy: ValueDuplicatePolicy
    private let nilPreservation: Bool
    private let prefixForKeys: StringLiteralKey?
    private let origin: WriteProvenance.Origin
    
    @_lifetime(borrow pointer)
    fileprivate init(pointer: UnsafeMutablePointer<ErrorInfo>,
                     duplicatePolicy: ValueDuplicatePolicy,
                     nilPreservation: Bool,
                     prefixForKeys: StringLiteralKey?,
                     origin: WriteProvenance.Origin) {
      self.pointer = pointer
      self.duplicatePolicy = duplicatePolicy
      self.nilPreservation = nilPreservation
      self.prefixForKeys = prefixForKeys
      self.origin = origin
    }
  }
}
