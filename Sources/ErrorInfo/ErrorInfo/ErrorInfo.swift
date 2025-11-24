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

// ===-------------------------------------------------------------------------------------------------------------------=== //

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
  public subscript<V: ValueType>(key: ErronInfoLiteralKey) -> V? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get {
      allValues(forKey: key.rawValue)?.first.value as? V
    }
    set {
      _add(key: key.rawValue,
           value: newValue,
           preserveNilValues: true,
           insertIfEqual: false,
           addTypeInfo: .default,
           collisionSource: .onSubscript(keyKind: .literalConstant))
    }
  }
  
  @_disfavoredOverload
  public subscript<V: ValueType>(key: String) -> V? {
    @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
    get {
      allValues(forKey: key)?.first.value as? V
    }
    set {
      _add(key: key,
           value: newValue,
           preserveNilValues: true,
           insertIfEqual: false,
           addTypeInfo: .default,
           collisionSource: .onSubscript(keyKind: .dynamic))
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append

// MARK: appendIfNotNil

extension ErrorInfo {
  public mutating func appendIfNotNil(_ value: (any ValueType)?,
                                      forKey literalKey: ErronInfoLiteralKey,
                                      insertIfEqual: Bool = false) {
    guard let value else { return }
    _appendWithDefaultTypeInfo(key: literalKey.rawValue,
                               value: value,
                               preserveNilValues: true, // has no effect in this func
                               insertIfEqual: insertIfEqual,
                               keyKind: .literalConstant)
  }
  
  @_disfavoredOverload
  public mutating func appendIfNotNil(_ value: (any ValueType)?,
                                      forKey dynamicKey: String,
                                      insertIfEqual: Bool = false) {
    guard let value else { return }
    _appendWithDefaultTypeInfo(key: dynamicKey,
                               value: value,
                               preserveNilValues: true, // has no effect in this func
                               insertIfEqual: insertIfEqual,
                               keyKind: .dynamic)
  }
}

// MARK: Append contentsOf

extension ErrorInfo {
  public mutating func append(contentsOf sequence: some Sequence<(String, any ValueType)>, insertIfEqual: Bool = false) {
    for (key, value) in sequence {
      _appendWithDefaultTypeInfo(key: key,
                                 value: value,
                                 preserveNilValues: true, // has no effect in this func
                                 insertIfEqual: insertIfEqual,
                                 keyKind: .dynamic)
    }
  }
}

extension ErrorInfo {
  private mutating func _appendWithDefaultTypeInfo(key: Key,
                                                   value: any ValueType,
                                                   preserveNilValues: Bool, // always true at call sites, need if value become optional
                                                   insertIfEqual: Bool,
                                                   keyKind: CollisionSource.KeyKind) {
    _add(key: key,
         value: value,
         preserveNilValues: preserveNilValues,
         insertIfEqual: insertIfEqual,
         addTypeInfo: .default,
         collisionSource: .onAppend(keyKind: keyKind))
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - All For Key

// MARK: hasValues forKey

extension ErrorInfo {
  public func hasValues(forKey key: ErronInfoLiteralKey) -> Bool {
    _storage.hasValue(forKey: key.rawValue)
  }
  
  @_disfavoredOverload
  public func hasValues(forKey key: Key) -> Bool {
    _storage.hasValue(forKey: key)
  }
}

// MARK: hasNonNilValues forKey

// TODO: implement
//extension ErrorInfo {
//  public func hasNonNilValues(forKey key: ErronInfoLiteralKey) -> Bool {
//    hasNonNilValues(forKey: key.rawValue)
//  }
//  
//  public func hasNonNilValues(forKey key: Key) -> Bool {
//
//  }
//}

// MARK: allValues forKey

extension ErrorInfo {
  // public func allValuesSlice(forKey key: Key) -> (some Sequence<Value>)? {}
  
  public func allValues(forKey key: ErronInfoLiteralKey) -> ValuesForKey<ValueWrapper>? {
    allValues(forKey: key.rawValue)
  }
  
  @_disfavoredOverload
  public func allValues(forKey key: Key) -> ValuesForKey<ValueWrapper>? {
    _storage.allValues(forKey: key)
  }
}

// MARK: removeAllValues forKey

extension ErrorInfo {
  @discardableResult
  public mutating func removeAllValues(forKey key: ErronInfoLiteralKey) -> ValuesForKey<ValueWrapper>? {
    removeAllValues(forKey: key.rawValue)
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func removeAllValues(forKey key: Key) -> ValuesForKey<ValueWrapper>? {
    _storage.removeAllValues(forKey: key)
  }
}

// MARK: replaceAllValues forKey

extension ErrorInfo {
  @discardableResult
  public mutating func replaceAllValues(forKey literalKey: ErronInfoLiteralKey,
                                        by newValue: any ValueType) -> ValuesForKey<ValueWrapper>? {
    let oldValues = _storage.removeAllValues(forKey: literalKey.rawValue)
    _add(key: literalKey.rawValue,
         value: newValue,
         preserveNilValues: true, // has no effect in this func
         insertIfEqual: true, // has no effect in this func
         addTypeInfo: .default,
         collisionSource: .onAppend(keyKind: .literalConstant)) // collisions must never happen using this func
    return oldValues
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func replaceAllValues(forKey dynamicKey: Key, by newValue: any ValueType) -> ValuesForKey<ValueWrapper>? {
    let oldValues = _storage.removeAllValues(forKey: dynamicKey)
    _add(key: dynamicKey,
         value: newValue,
         preserveNilValues: true, // has no effect in this func
         insertIfEqual: true, // has no effect in this func
         addTypeInfo: .default,
         collisionSource: .onAppend(keyKind: .dynamic)) // collisions must never happen using this func
    return oldValues
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Remove All

extension ErrorInfo {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _storage.removeAll(keepingCapacity: keepCapacity)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append KeyValue with all arguments passed explicitly

extension ErrorInfo {
  /// The root appending function for public API imps. The term "_add" is chosen to visually / syntatically differentiate from family of public `append()`functions.
  internal mutating func _add(key: Key,
                              value newValue: (any ValueType)?,
                              preserveNilValues: Bool,
                              insertIfEqual: Bool,
                              addTypeInfo _: TypeInfoOptions,
                              collisionSource: @autoclosure () -> CollisionSource) {
    
    // TODO: put type TypeInfo
    let value: any ValueType
    if let newValue {
      // if let typeDesc = ErrorInfoFuncs.typeDesciptionIfNeeded(for: value, options: addTypeInfo) {}
      value = newValue
    } else if preserveNilValues {
      // if let typeDesc = ErrorInfoFuncs.typeDesciptionIfNeeded(forOptional: optionalValue, options: addTypeInfo) {}
      value = "nil"
      // FIXME: this String instance will be returned by `allValues(forKey:)` function, which is not what we want.
      // There is needed a way to store a nil value value for key. The same is in CustomTypeInfoOptionsView subscript.
      // When omitEqualValue = true, then two nil values should still be stored if their Wrapped type was different.
      // From this point of view "nil" string is also incorrect.
    } else {
      return
    }
    
    _storage.appendResolvingCollisions(key: key,
                                       value: value,
                                       insertIfEqual: insertIfEqual,
                                       collisionSource: collisionSource())
  }
}

extension ErrorInfo {
  internal struct _Value: Sendable {
    let variant: Variant
    
    enum Variant {
      case value(any ErrorInfoValueType)
      case none(type: (any ErrorInfoValueType).Type)
      // check nil instances via AnyHashable
    }
  }
}
