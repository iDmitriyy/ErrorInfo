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
  
  public func allValues(forKey literalKey: StringLiteralKey) -> ValuesForKey<any ValueType>? {
    allValues(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func allValues(forKey dynamicKey: String) -> ValuesForKey<any ValueType>? {
    _storage.allValues(forKey: dynamicKey)?._compactMap { $0.value.optional.optionalValue }
  }
}

// MARK: RemoveAllValues ForKey

extension ErrorInfo {
  @discardableResult
  public mutating func removeAllValues(forKey literalKey: StringLiteralKey) -> ValuesForKey<any ValueType>? {
    removeAllValues(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func removeAllValues(forKey dynamicKey: String) -> ValuesForKey<any ValueType>? {
    _storage.removeAllValues(forKey: dynamicKey)?._compactMap { $0.value.optional.optionalValue }
  }
}

// MARK: ReplaceAllValues ForKey

extension ErrorInfo {
  @discardableResult
  public mutating func replaceAllValues(forKey literalKey: StringLiteralKey,
                                        by newValue: any ValueType) -> ValuesForKey<any ValueType>? {
    let oldValues = _storage.removeAllValues(forKey: literalKey.rawValue)
    _add(key: literalKey.rawValue,
         keyOrigin: literalKey.keyOrigin,
         value: newValue,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: .allowEqual, // has no effect in this func
         collisionSource: .onAppend(origin: nil)) // collisions must never happen using this func
    return oldValues?._compactMap { $0.value.optional.optionalValue }
  }
  
  @_disfavoredOverload @discardableResult
  public mutating func replaceAllValues(forKey dynamicKey: String, by newValue: any ValueType) -> ValuesForKey<any ValueType>? {
    let oldValues = _storage.removeAllValues(forKey: dynamicKey)
    _add(key: dynamicKey,
         keyOrigin: .dynamic,
         value: newValue,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: .allowEqual, // has no effect in this func
         collisionSource: .onAppend(origin: nil)) // collisions must never happen using this func
    return oldValues?._compactMap { $0.value.optional.optionalValue }
  }
}
