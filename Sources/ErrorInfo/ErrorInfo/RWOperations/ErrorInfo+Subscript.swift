//
//  ErrorInfo+Subscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - Subscript

// TODO: check if there runtime issues with unavailable setter. If yes then make deprecated
// TODO: ? make subscript as a defualt imp in protocol, providing a way to override implementation at usage site
// ErronInfoLiteralKey with @_disfavoredOverload String-base subscript allows to differemtiate betwee when it was a literal-key subscript
// and when it was defenitely some string value passed dynamically / at runtime.
// so this cleary separate the subscript access to 2 kinds:
// 1. exact literal that can be found in source code or predefined key which also can be found i source
// 2. some string value created dynamically
// The same trick with sub-separaation can be done for append() functions
// Dictionary literal can then strictly be created with string literals, and when dynamic for strings another APIs are forced to be used.
extension ErrorInfo {
  // TODO: is it good idea to return .first as a default? In most cases it is what expected, as normally there will 1 va;ue for key
  
  // First value for a given key.
  // public subscript(key: ErronInfoLiteralKey) -> (any ValueType)? {
  //   allValues(forKey: key)?.first
  // }
  //
  // First value for a given key.
  // @_disfavoredOverload
  // public subscript(key: String) -> (any ValueType)? {
  //   allValues(forKey: key)?.first
  // }
  
  public subscript<V: ValueType>(key literalKey: StringLiteralKey) -> V? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get {
      allValues(forKey: literalKey.rawValue)?.first as? V
    }
    set {
      _add(key: literalKey.rawValue,
           keyOrigin: literalKey.keyOrigin,
           value: newValue,
           preserveNilValues: true,
           insertIfEqual: false,
           addTypeInfo: .default,
           collisionSource: .onSubscript)
    }
  }
  
  @available(*, deprecated, message: "make autocomplete pollution")
  @_disfavoredOverload
  public subscript<V: ValueType>(key dynamicKey: String) -> V? { // dynamicKey key:
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get {
      allValues(forKey: dynamicKey)?.first as? V
    }
    set {
      _add(key: dynamicKey,
           keyOrigin: .dynamic,
           value: newValue,
           preserveNilValues: true,
           insertIfEqual: false,
           addTypeInfo: .default,
           collisionSource: .onSubscript)
    }
  }
  
  mutating func foo(key _: String) {
    // self[.debug + .message + .id] = 2
  }
}
