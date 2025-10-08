//
//  ErrorInfo+ConvenienceSubscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

// MARK: - With Custom TypeInfoOptions

extension ErrorInfo {
  ///
  /// - Parameters:
  ///   - typeInfoOptions:
  ///   - omitEqualValue: `omitEqualValue` in subscript has higher priority than this argument
  ///   - append:
  public mutating func appendWith(typeInfoOptions: TypeInfoOptions,
                                  omitEqualValue: Bool = true,
                                  append: (consuming CustomTypeInfoOptionsView) -> Void) {
    withUnsafeMutablePointer(to: &self) { pointer in
      let view = CustomTypeInfoOptionsView(pointer: pointer, omitEqualValue: omitEqualValue, typeInfoOptions: typeInfoOptions)
      append(view)
    }
  }
}

extension ErrorInfo {
  public struct CustomTypeInfoOptionsView: ~Copyable { // TODO: ~Escapable
    private let pointer: UnsafeMutablePointer<ErrorInfo> // TODO: check CoW not triggered | inplace mutation
    private let omitEqualValue: Bool
    private let typeInfoOptions: TypeInfoOptions
    
    fileprivate init(pointer: UnsafeMutablePointer<ErrorInfo>, omitEqualValue: Bool, typeInfoOptions: TypeInfoOptions) {
      self.pointer = pointer
      self.omitEqualValue = omitEqualValue
      self.typeInfoOptions = typeInfoOptions
    }
    
    /// `omitEqualValue`has higher priority than provided in `appendWith(typeInfoOptions:, omitEqualValue:, append:)` function.
    public subscript(key: Key, omitEqualValue omitEqualValueFromSubscript: Bool? = nil) -> (any ValueType)? {
      // TODO: ? borrowing get set
      @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
      get {
        pointer.pointee.allValues(forKey: key)?.first.value
      }
      set {
        let effectiveOmitEqualValue: Bool = omitEqualValueFromSubscript ?? omitEqualValue
        pointer.pointee._add(key: key,
                             value: newValue,
                             omitEqualValue: effectiveOmitEqualValue,
                             addTypeInfo: typeInfoOptions,
                             collisionSource: .onSubscript)
      }
    }
  }
}

// MARK: - With Predefined ErronInfoKey

extension ErrorInfo {
  public subscript(key: ErronInfoKey, omitEqualValue: Bool = true) -> (any ValueType)? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get { allValues(forKey: key.rawValue)?.first.value }
    set { self[key.rawValue] = newValue }
  }
}
