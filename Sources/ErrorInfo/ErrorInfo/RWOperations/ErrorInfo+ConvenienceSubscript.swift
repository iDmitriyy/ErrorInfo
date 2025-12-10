//
//  ErrorInfo+ConvenienceSubscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

// MARK: - With Custom TypeInfoOptions

extension ErrorInfo {
  public static func with(preserveNilValues: Bool = true,
                          duplicatePolicy: ValueDuplicatePolicy = .rejectEqual,
                          collisionSource: CollisionSource.Origin = .fileLine(),
                          append: (consuming CustomOptionsView) -> Void) -> Self {
    var info = Self()
    info.appendWith(preserveNilValues: preserveNilValues,
                    duplicatePolicy: duplicatePolicy,
                    collisionSource: collisionSource,
                    append: append)
    return info
  }
  
  ///
  /// - Parameters:
  ///   - typeInfoOptions:
  ///   - omitEqualValue: `omitEqualValue` in subscript has higher priority than this argument
  ///   - append:
  public mutating func appendWith(preserveNilValues: Bool = true,
                                  duplicatePolicy: ValueDuplicatePolicy = .rejectEqual,
                                  collisionSource: CollisionSource.Origin = .fileLine(),
                                  append: (consuming CustomOptionsView) -> Void) {
    withUnsafeMutablePointer(to: &self) { pointer in
      let view = CustomOptionsView(pointer: pointer,
                                   duplicatePolicy: duplicatePolicy,
                                   preserveNilValues: preserveNilValues,
                                   collisionOrigin: collisionSource)
      append(view)
    }
  }
}

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
    
    // MARK: - Subscript
    
    /// `omitEqualValue`has higher priority than provided in `appendWith(typeInfoOptions:, omitEqualValue:, append:)` function.
    public subscript<V: ValueType>(key literalKey: StringLiteralKey,
                                   preserveNilValues: Bool? = nil,
                                   duplicatePolicy: ValueDuplicatePolicy? = nil) -> V? {
      // TODO: ? borrowing get set
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
    public subscript<V: ValueType>(key dynamicKey: String,
                                   preserveNilValues: Bool? = nil,
                                   duplicatePolicy: ValueDuplicatePolicy? = nil) -> V? {
      // TODO: ? borrowing get set
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
    
    // MARK: - Replace AllValues ForKey
    
    @discardableResult
    public mutating func replaceAllValues(forKey dynamicKey: String,
                                          by newValue: any ValueType,
                                          preserveNilValues: Bool? = nil,
                                          duplicatePolicy: ValueDuplicatePolicy? = nil) -> ValuesForKey<any ValueType>? {
      let oldValues = pointer.pointee._storage.removeAllValues(forKey: dynamicKey)
      // collisions never happens when replacing
      pointer.pointee._add(key: dynamicKey,
                           keyOrigin: .dynamic,
                           value: newValue,
                           preserveNilValues: preserveNilValues ?? self.preserveNilValues,
                           duplicatePolicy: duplicatePolicy ?? self.duplicatePolicy,
                           collisionSource: .onAppend(origin: collisionOrigin))
      return oldValues?._compactMap { $0.value.optional.optionalValue }
    }
  }
}
