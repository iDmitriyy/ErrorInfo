//
//  ErrorInfo+ConvenienceSubscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

// Improvement: add keyPrefix arg to withOptions func

// MARK: - Modify With Custom Options

extension ErrorInfo {
  /// Creates a new `ErrorInfo` instance with custom options that apply to all mutable operations performed on it.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// - Parameters:
  ///   - preserveNilValues: A Boolean value that determines whether nil values should be preserved. Default is true.
  ///   - duplicatePolicy: Specifies the policy for handling duplicate values during modification. The default is .defaultForAppending.
  ///   - prefixForKeys: An optional prefix to prepend to all keys added. Default is nil.
  ///   - collisionSource: Defines the origin of any collisions for debugging and tracking purposes. The default is `.fileLine()`.
  ///   - modify: A closure that provides a `CustomOptionsView` to perform mutable operations on the `ErrorInfo` instance.
  ///     The closure receives a mutable reference to the `CustomOptionsView`, which can then be used to perform operations
  ///     like adding or modifying values.
  ///
  /// - Returns: A new ErrorInfo instance, modified according to the provided options.
  ///
  /// # Example:
  /// ```swift
  /// let info = ErrorInfo.withOptions(preserveNilValues: false) {
  ///   // Global option preserveNilValues = false, nil values are ignored
  ///   $0["age"] = 30 as Int?
  ///   $0["username"] = nil as String?
  ///
  ///   // Override on a per-operation basis: preserve nil values
  ///   0["email", preserveNilValues: true] = nil as String?
  /// }
  ///
  /// // info now contains: ["age": 30, "email": nil]
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
  
  /// Modifies the current `ErrorInfo` instance with custom options that apply to all mutable operations performed on it.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// - Parameters:
  ///   - preserveNilValues: A Boolean value that determines whether nil values should be preserved. Default is true.
  ///   - duplicatePolicy: Specifies the policy for handling duplicate values during modification. The default is .defaultForAppending.
  ///   - prefixForKeys: An optional prefix to prepend to all keys added. Default is nil.
  ///   - collisionSource: Defines the origin of any collisions for debugging and tracking purposes. The default is `.fileLine()`.
  ///   - modify: A closure that provides a `CustomOptionsView` to perform mutable operations on the `ErrorInfo` instance.
  ///     The closure receives a mutable reference to the `CustomOptionsView`, which can then be used to perform operations
  ///     like adding or modifying values.
  ///
  /// - Returns: A new ErrorInfo instance, modified according to the provided options.
  ///
  /// # Example:
  /// ```swift
  /// var info = ErrorInfo()
  /// info.modifyWithOptions(preserveNilValues: false) {
  ///   // Global option preserveNilValues = false, nil values are ignored
  ///   $0["age"] = 30 as Int?
  ///   $0["username"] = nil as String?
  ///
  ///   // Override on a per-operation basis: preserve nil values
  ///   0["email", preserveNilValues: true] = nil as String?
  /// }
  ///
  /// // info now contains: ["age": 30, "email": nil]
  /// ```
  public mutating func appendWith(duplicatePolicy: ValueDuplicatePolicy = .rejectEqual,
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
  
  public mutating func appendWith(duplicatePolicy: ValueDuplicatePolicy = .rejectEqual,
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
  /// `duplicatePolicy`has higher priority than provided in `appendWith(typeInfoOptions:, omitEqualValue:, append:)` function.
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
