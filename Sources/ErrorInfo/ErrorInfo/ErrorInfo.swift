//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

import struct OrderedCollections.OrderedDictionary

// TODO: - add tests for elements ordering stability
// TODO: - add overloads for Sendable AnyObjects & actors

public struct ErrorInfo: Sendable { // ErrorInfoCollection
  public typealias ValueType = ErrorInfoValueType
  public typealias CollisionSource = StringBasedCollisionSource
  
  // TODO: should CollisionSource be stored in BackingStorage? mostly always CollisionSource is nil
  // may be BackingStorage should keep a separate dict for keeping CollisionSource instances
  // check memory consuption for both cases.
  // Do it after all Slices will be comlpeted, askeeping collisionSource in separate dict need a way to somehow
  // store relation between values in slice and collision sources.
  // Another one case is with TypeInfo. Simply type info can be stored as a Bool flag or Empty() instance.
  internal typealias BackingStorage = OrderedMultiValueErrorInfoGeneric<String, any ValueType>
  public typealias ValueWrapper = ValueWithCollisionWrapper<any ValueType, CollisionSource>
  
  // FIXME: private(set)
  internal var _storage: BackingStorage
  
  private init(storage: BackingStorage) {
    _storage = storage
  }
  
  public init() {
    self.init(storage: BackingStorage())
  }
  
  public init(minimumCapacity: Int) {
    self.init(storage: BackingStorage(minimumCapacity: minimumCapacity))
  }
  
  public static let empty: Self = Self()
}

// TODO: check if there runtime issues with unavailable setter. If yes then make deprecated
// TODO: ? make subscript as a defualt imp in protocol, providing a way to override implementation at usage site
// ErronInfoKey with @_disfavoredOverload String-base subscript allows to differemtiate betwee when it was a literal-key subscript
// and when it was defenitely some string value passed dynamically / at runtime.
// so this cleary separate the subscript access to 2 kinds:
// 1. exact literal that can be found in source code or predefined key which also can be found i source
// 2. some string value created dynamically
// The same trick with sub-separaation can be done for append() functions
// Dictionary literal can then strictly be created with string literals, and when dynamic for strings another APIs are forced to be used.
extension ErrorInfo {
  public subscript(key: ErronInfoKey, insertIfEqual: Bool = false) -> (any ValueType)? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get {
      allValues(forKey: key.rawValue)?.first.value
    }
    set {
      _add(key: key.rawValue,
           value: newValue,
           insertIfEqual: insertIfEqual,
           addTypeInfo: .default,
           collisionSource: .onSubscript(keyKind: .stringLiteralConstant))
    }
  }
  
  @_disfavoredOverload
  public subscript(key: String, insertIfEqual: Bool = false) -> (any ValueType)? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get {
      allValues(forKey: key)?.first.value
    }
    set {
      _add(key: key,
           value: newValue,
           insertIfEqual: insertIfEqual,
           addTypeInfo: .default,
           collisionSource: .onSubscript(keyKind: .dynamic))
    }
  }
}

// MARK: All Values For Key

extension ErrorInfo {
  // public func allValuesSlice(forKey key: Key) -> (some Sequence<Value>)? {}
  
  public func allValues(forKey key: Key) -> ValuesForKey<ValueWrapper>? {
    _storage.allValues(forKey: key)
  }
  
  @discardableResult
  public mutating func removeAllValues(forKey key: Key) -> ValuesForKey<ValueWrapper>? {
    _storage.removeAllValues(forKey: key)
  }
}

// MARK: Append KeyValue

extension ErrorInfo {
  /// For copying values with Collection / Sequence types.
  public mutating func append(element newElement: (String, any ValueType), insertIfEqual: Bool = false) {
    appendWithDefaultTypeInfo(key: newElement.0, value: newElement.1, insertIfEqual: insertIfEqual, keyKind: .dynamic)
  }
  
  public mutating func append(key: ErronInfoKey, valueIfNotNil value: (any ValueType)?, insertIfEqual: Bool = false) {
    guard let value else { return }
    appendWithDefaultTypeInfo(key: key.rawValue, value: value, insertIfEqual: insertIfEqual, keyKind: .stringLiteralConstant)
  }
  
  @_disfavoredOverload
  public mutating func append(key dynamicKey: String, valueIfNotNil value: (any ValueType)?, insertIfEqual: Bool = false) {
    guard let value else { return }
    appendWithDefaultTypeInfo(key: dynamicKey, value: value, insertIfEqual: insertIfEqual, keyKind: .dynamic)
  }
  
  private mutating func appendWithDefaultTypeInfo(key: Key,
                                                  value: any ValueType,
                                                  insertIfEqual: Bool,
                                                  keyKind: CollisionSource.KeyKind) {
    _add(key: key,
         value: value,
         insertIfEqual: insertIfEqual,
         addTypeInfo: .default,
         collisionSource: .onAppend(keyKind: keyKind))
  }
}

extension ErrorInfo {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _storage.removeAll(keepingCapacity: keepCapacity)
  }
}

// MARK: Append KeyValue with all arguments passed explicitly

extension ErrorInfo {
  /// The root appending function for public API imps. The term "_add" is chosen to visually / syntatically differentiate from family of public `append()`functions.
  internal mutating func _add(key: Key,
                              value newValue: (any ValueType)?,
                              insertIfEqual: Bool,
                              addTypeInfo: TypeInfoOptions,
                              collisionSource: @autoclosure () -> CollisionSource) {
    // TODO: put type TypeInfo
    let value: any ValueType = if let newValue {
      // if let typeDesc = ErrorInfoFuncs.typeDesciptionIfNeeded(for: value, options: addTypeInfo) {}
      newValue
    } else {
      // if let typeDesc = ErrorInfoFuncs.typeDesciptionIfNeeded(forOptional: optionalValue, options: addTypeInfo) {}
      "nil"
      // FIXME: this String instance will be returned by `allValues(forKey:)` function, which is not what we want.
      // There is needed a way to store a nil value value for key. The same is in CustomTypeInfoOptionsView subscript.
      // When omitEqualValue = true, then two nil values should still be stored if their Wrapped type was different.
      // From this point of view "nil" string is also incorrect.
    }
    
    _storage.appendResolvingCollisions(key: key,
                                       value: value,
                                       insertIfEqual: insertIfEqual,
                                       collisionSource: collisionSource())
  }
}


