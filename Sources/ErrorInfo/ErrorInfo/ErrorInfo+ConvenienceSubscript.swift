//
//  ErrorInfo+ConvenienceSubscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

// MARK: - With Custom TypeInfoOptions

extension ErrorInfo {
  public static func with(typeInfoOptions: TypeInfoOptions,
                          preserveNilValues: Bool = true,
                          insertIfEqual: Bool = false,
                          append: (consuming CustomTypeInfoOptionsView) -> Void) -> Self {
    var info = Self()
    info.appendWith(typeInfoOptions: typeInfoOptions,
                    preserveNilValues: preserveNilValues,
                    insertIfEqual: insertIfEqual,
                    append: append)
    return info
  }
  
  ///
  /// - Parameters:
  ///   - typeInfoOptions:
  ///   - omitEqualValue: `omitEqualValue` in subscript has higher priority than this argument
  ///   - append:
  public mutating func appendWith(typeInfoOptions: TypeInfoOptions,
                                  preserveNilValues: Bool = true,
                                  insertIfEqual: Bool = false,
                                  append: (consuming CustomTypeInfoOptionsView) -> Void) {
    withUnsafeMutablePointer(to: &self) { pointer in
      let view = CustomTypeInfoOptionsView(pointer: pointer,
                                           insertIfEqual: insertIfEqual,
                                           typeInfoOptions: typeInfoOptions,
                                           preserveNilValues: preserveNilValues)
      append(view)
    }
  }
}

extension ErrorInfo {
  public struct CustomTypeInfoOptionsView: ~Copyable { // TODO: ~Escapable
    private let pointer: UnsafeMutablePointer<ErrorInfo> // TODO: check CoW not triggered | inplace mutation
    private let insertIfEqual: Bool
    private let preserveNilValues: Bool
    private let typeInfoOptions: TypeInfoOptions
    
    fileprivate init(pointer: UnsafeMutablePointer<ErrorInfo>,
                     insertIfEqual: Bool,
                     typeInfoOptions: TypeInfoOptions,
                     preserveNilValues: Bool) {
      self.pointer = pointer
      self.insertIfEqual = insertIfEqual
      self.preserveNilValues = preserveNilValues
      self.typeInfoOptions = typeInfoOptions
    }
    
    // MARK: - Subscript
    
    /// `omitEqualValue`has higher priority than provided in `appendWith(typeInfoOptions:, omitEqualValue:, append:)` function.
    public subscript(key literalKey: ErronInfoLiteralKey,
                     preserveNilValues: Bool? = nil,
                     insertIfEqual: Bool? = nil) -> (any ValueType)? {
      // TODO: ? borrowing get set
      @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
      get {
        pointer.pointee.allValues(forKey: literalKey)?.first.value
      }
      set {
        pointer.pointee._add(key: literalKey.rawValue,
                             value: newValue,
                             preserveNilValues: preserveNilValues ?? self.preserveNilValues,
                             insertIfEqual: insertIfEqual ?? self.insertIfEqual,
                             addTypeInfo: typeInfoOptions,
                             collisionSource: .onSubscript(keyKind: .stringLiteralConstant))
      }
    }
    
    /// `omitEqualValue`has higher priority than provided in `appendWith(typeInfoOptions:, omitEqualValue:, append:)` function.
    @_disfavoredOverload
    public subscript(key dynamicKey: String,
                     preserveNilValues: Bool? = nil,
                     insertIfEqual: Bool? = nil) -> (any ValueType)? {
      // TODO: ? borrowing get set
      @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
      get {
        pointer.pointee.allValues(forKey: dynamicKey)?.first.value
      }
      set {
        pointer.pointee._add(key: dynamicKey,
                             value: newValue,
                             preserveNilValues: preserveNilValues ?? self.preserveNilValues,
                             insertIfEqual: insertIfEqual ?? self.insertIfEqual,
                             addTypeInfo: typeInfoOptions,
                             collisionSource: .onSubscript(keyKind: .dynamic))
      }
    }
    
    // MARK: - Replace AllValues ForKey
    
    @discardableResult
    public mutating func replaceAllValues(forKey dynamicKey: Key,
                                          by newValue: any ValueType,
                                          preserveNilValues: Bool? = nil,
                                          insertIfEqual: Bool? = nil) -> ValuesForKey<ValueWrapper>? {
      let oldValues = pointer.pointee._storage.removeAllValues(forKey: dynamicKey)
      // collisions never happens when replacing
      pointer.pointee._add(key: dynamicKey,
                           value: newValue,
                           preserveNilValues: preserveNilValues ?? self.preserveNilValues,
                           insertIfEqual: insertIfEqual ?? self.insertIfEqual,
                           addTypeInfo: typeInfoOptions,
                           collisionSource: .onAppend(keyKind: .dynamic))
      return oldValues
    }
  }
}

// CustomTypeInfoOptionsView initializble with DictionaryLiteral using params, e.g.:
/*
 ErrorInfo.with(typeInfoOptions: ...) {
   $0 = ["key": value]
 }
 */
