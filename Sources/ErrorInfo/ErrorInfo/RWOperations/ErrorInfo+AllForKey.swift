//
//  ErrorInfo+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: - All For Key

// MARK: AllValues ForKey

extension ErrorInfo {
  // public func allValuesSlice(forKey key: Key) -> (some Sequence<Value>)? {}
  
  public func allValues(forKey key: ErronInfoLiteralKey) -> ValuesForKey<any ValueType>? {
    allValues(forKey: key.rawValue)
  }
  
  @_disfavoredOverload
  public func allValues(forKey key: Key) -> ValuesForKey<any ValueType>? {
    _storage.allValues(forKey: key)?._compactMap { $0.value.optionalValue }
  }
}

// MARK: RemoveAllValues ForKey

extension ErrorInfo {
  @discardableResult
  public mutating func removeAllValues(forKey key: ErronInfoLiteralKey) -> ValuesForKey<any ValueType>? {
    removeAllValues(forKey: key.rawValue)
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func removeAllValues(forKey key: Key) -> ValuesForKey<any ValueType>? {
    _storage.removeAllValues(forKey: key)?._compactMap { $0.value.optionalValue }
  }
}

// MARK: ReplaceAllValues ForKey

extension ErrorInfo {
  @discardableResult
  public mutating func replaceAllValues(forKey literalKey: ErronInfoLiteralKey,
                                        by newValue: any ValueType) -> ValuesForKey<any ValueType>? {
    let oldValues = _storage.removeAllValues(forKey: literalKey.rawValue)
    _add(key: literalKey.rawValue,
         value: newValue,
         preserveNilValues: true, // has no effect in this func
         insertIfEqual: true, // has no effect in this func
         addTypeInfo: .default,
         collisionSource: .onAppend(keyKind: .literalConstant)) // collisions must never happen using this func
    return oldValues?._compactMap { $0.value.optionalValue }
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func replaceAllValues(forKey dynamicKey: Key, by newValue: any ValueType) -> ValuesForKey<any ValueType>? {
    let oldValues = _storage.removeAllValues(forKey: dynamicKey)
    _add(key: dynamicKey,
         value: newValue,
         preserveNilValues: true, // has no effect in this func
         insertIfEqual: true, // has no effect in this func
         addTypeInfo: .default,
         collisionSource: .onAppend(keyKind: .dynamic)) // collisions must never happen using this func
    return oldValues?._compactMap { $0.value.optionalValue }
  }
}
