//
//  ErrorInfo+ConvenienceSubscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

// MARK: - With Custom TypeInfoOptions

extension ErrorInfo {
  public static func with(preserveNilValues: Bool = true,
                          insertIfEqual: Bool = false,
                          append: (consuming CustomOptionsView) -> Void) -> Self {
    var info = Self()
    info.appendWith(preserveNilValues: preserveNilValues,
                    insertIfEqual: insertIfEqual,
                    append: append)
    return info
  }
  
  ///
  /// - Parameters:
  ///   - typeInfoOptions:
  ///   - omitEqualValue: `omitEqualValue` in subscript has higher priority than this argument
  ///   - append:
  public mutating func appendWith(preserveNilValues: Bool = true,
                                  insertIfEqual: Bool = false,
                                  append: (consuming CustomOptionsView) -> Void) {
    withUnsafeMutablePointer(to: &self) { pointer in
      let view = CustomOptionsView(pointer: pointer,
                                   insertIfEqual: insertIfEqual,
                                   preserveNilValues: preserveNilValues)
      append(view)
    }
  }
}

extension ErrorInfo {
  public struct CustomOptionsView: ~Copyable { // TODO: ~Escapable
    private let pointer: UnsafeMutablePointer<ErrorInfo> // TODO: check CoW not triggered | inplace mutation
    private let insertIfEqual: Bool
    private let preserveNilValues: Bool
    
    fileprivate init(pointer: UnsafeMutablePointer<ErrorInfo>,
                     insertIfEqual: Bool,
                     preserveNilValues: Bool) {
      self.pointer = pointer
      self.insertIfEqual = insertIfEqual
      self.preserveNilValues = preserveNilValues
    }
    
    // MARK: - Subscript
    
    /// `omitEqualValue`has higher priority than provided in `appendWith(typeInfoOptions:, omitEqualValue:, append:)` function.
    public subscript<V: ValueType>(key literalKey: StringLiteralKey,
                                   preserveNilValues: Bool? = nil,
                                   insertIfEqual: Bool? = nil) -> V? {
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
                             insertIfEqual: insertIfEqual ?? self.insertIfEqual,
                             collisionSource: .onSubscript)
      }
    }
    
    /// `omitEqualValue`has higher priority than provided in `appendWith(typeInfoOptions:, omitEqualValue:, append:)` function.
    @_disfavoredOverload
    public subscript<V: ValueType>(key dynamicKey: String,
                                   preserveNilValues: Bool? = nil,
                                   insertIfEqual: Bool? = nil) -> V? {
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
                             insertIfEqual: insertIfEqual ?? self.insertIfEqual,
                             collisionSource: .onSubscript)
      }
    }
    
    // MARK: - Replace AllValues ForKey
    
    @discardableResult
    public mutating func replaceAllValues(forKey dynamicKey: String,
                                          by newValue: any ValueType,
                                          preserveNilValues: Bool? = nil,
                                          insertIfEqual: Bool? = nil) -> ValuesForKey<any ValueType>? {
      let oldValues = pointer.pointee._storage.removeAllValues(forKey: dynamicKey)
      // collisions never happens when replacing
      pointer.pointee._add(key: dynamicKey,
                           keyOrigin: .dynamic,
                           value: newValue,
                           preserveNilValues: preserveNilValues ?? self.preserveNilValues,
                           insertIfEqual: insertIfEqual ?? self.insertIfEqual,
                           collisionSource: .onAppend)
      return oldValues?._compactMap { $0.value.optional.optionalValue }
    }
  }
}

// CustomTypeInfoOptionsView initializble with DictionaryLiteral using params, e.g.:
/*
 ErrorInfo.with(typeInfoOptions: ...) {
   $0 = ["key": value]
 }
 */
