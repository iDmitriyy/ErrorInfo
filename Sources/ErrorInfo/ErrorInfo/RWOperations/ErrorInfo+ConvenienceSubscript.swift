//
//  ErrorInfo+ConvenienceSubscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

// MARK: - Modify With Custom Options

extension ErrorInfo {
  /// Creates a new `ErrorInfo` instance with custom options that apply to all mutable operations performed on it.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// - Parameters:
  ///   - preserveNilValues: A Boolean value that determines whether nil values should be preserved. Default is true.
  ///   - duplicatePolicy: Specifies the policy for handling duplicate values during modification. The default is .defaultForAppending.
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
  public static func withOptions(preserveNilValues: Bool = true,
                                 duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending,
                                 collisionSource: CollisionSource.Origin = .fileLine(),
                                 modify: (consuming CustomOptionsView) -> Void) -> Self {
    var info = Self()
    info.modifyWithOptions(preserveNilValues: preserveNilValues,
                           duplicatePolicy: duplicatePolicy,
                           collisionSource: collisionSource,
                           modify: modify)
    return info
  }
  
  /// Modifies the current `ErrorInfo` instance with custom options that apply to all mutable operations performed on it.
  /// The provided options can be overridden at the individual operation level (e.g., using subscripts or functions)..
  ///
  /// - Parameters:
  ///   - preserveNilValues: A Boolean value that determines whether nil values should be preserved. Default is true.
  ///   - duplicatePolicy: Specifies the policy for handling duplicate values during modification. The default is .defaultForAppending.
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
  public mutating func modifyWithOptions(preserveNilValues: Bool = true,
                                         duplicatePolicy: ValueDuplicatePolicy = .rejectEqual,
                                         collisionSource: CollisionSource.Origin = .fileLine(),
                                         modify: (consuming CustomOptionsView) -> Void) {
    withUnsafeMutablePointer(to: &self) { pointer in
      let view = CustomOptionsView(pointer: pointer,
                                   duplicatePolicy: duplicatePolicy,
                                   preserveNilValues: preserveNilValues,
                                   collisionOrigin: collisionSource)
      modify(view)
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Subscript

extension ErrorInfo.CustomOptionsView {
  
  /// `omitEqualValue`has higher priority than provided in `appendWith(typeInfoOptions:, omitEqualValue:, append:)` function.
  public subscript<V: ErrorInfoValueType>(
    key literalKey: StringLiteralKey,
    preserveNilValues: Bool? = nil,
    duplicatePolicy: ErrorInfo.ValueDuplicatePolicy? = nil,
  ) -> V? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get {
      pointer.pointee.allValues(forKey: literalKey)?.first as? V
    }
    set {
      pointer.pointee._add(key: literalKey.rawValue,
                           keyOrigin: literalKey.keyOrigin,
                           value: newValue,
                           preserveNilValues: preserveNilValues ?? self.preserveNilValues,
                           duplicatePolicy: duplicatePolicy ?? self.duplicatePolicy,
                           collisionSource: .onSubscript(origin: collisionOrigin))
    }
  }
  
  /// `omitEqualValue`has higher priority than provided in `appendWith(typeInfoOptions:, omitEqualValue:, append:)` function.
  @_disfavoredOverload
  public subscript<V: ErrorInfoValueType>(
    key dynamicKey: String,
    preserveNilValues: Bool? = nil,
    duplicatePolicy: ErrorInfo.ValueDuplicatePolicy? = nil,
  ) -> V? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get {
      pointer.pointee.allValues(forKey: dynamicKey)?.first as? V
    }
    set {
      pointer.pointee._add(key: dynamicKey,
                           keyOrigin: .dynamic,
                           value: newValue,
                           preserveNilValues: preserveNilValues ?? self.preserveNilValues,
                           duplicatePolicy: duplicatePolicy ?? self.duplicatePolicy,
                           collisionSource: .onSubscript(origin: collisionOrigin))
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Replace All Records For Key

extension ErrorInfo.CustomOptionsView {
  @_disfavoredOverload @discardableResult
  public func replaceAllRecords(
    forKey dynamicKey: String,
    by newValue: any ErrorInfoValueType,
    preserveNilValues: Bool? = nil,
    duplicatePolicy: ErrorInfo.ValueDuplicatePolicy? = nil,
  ) -> ValuesForKey<any ErrorInfoValueType>? {
    let oldValues = pointer.pointee._storage.removeAllValues(forKey: dynamicKey)
    // collisions never happens when replacing
    pointer.pointee._add(key: dynamicKey,
                         keyOrigin: .dynamic,
                         value: newValue,
                         preserveNilValues: preserveNilValues ?? self.preserveNilValues,
                         duplicatePolicy: duplicatePolicy ?? self.duplicatePolicy,
                         collisionSource: .onAppend(origin: collisionOrigin))
    return oldValues?._compactMap { $0.value._optional.maybeValue.asOptional }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - CustomOptions View

extension ErrorInfo {
  public struct CustomOptionsView: ~Copyable { // TODO: ~Escapable
    private let pointer: UnsafeMutablePointer<ErrorInfo> // TODO: check CoW not triggered | inplace mutation
    private let duplicatePolicy: ValueDuplicatePolicy
    private let preserveNilValues: Bool
    private let collisionOrigin: CollisionSource.Origin
    
    fileprivate init(pointer: UnsafeMutablePointer<ErrorInfo>,
                     duplicatePolicy: ValueDuplicatePolicy,
                     preserveNilValues: Bool,
                     collisionOrigin: CollisionSource.Origin) {
      self.pointer = pointer
      self.duplicatePolicy = duplicatePolicy
      self.preserveNilValues = preserveNilValues
      self.collisionOrigin = collisionOrigin
    }
  }
}
