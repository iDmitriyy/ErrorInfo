//
//  ErrorInfo+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: - AllValues ForKey

extension ErrorInfo {
  // DEFERRED: public func allValuesSlice(forKey key: Key) -> (some Sequence<Value>)? {}
  // replace usage of allValues(forKey:) for better perfomance | reduce allocations
  
  public func allValues(forKey literalKey: StringLiteralKey) -> ValuesForKey<ValueExistential>? {
    allValues(forKey: literalKey.rawValue)
  }
  
  public func allValues(forKey dynamicKey: String) -> ValuesForKey<ValueExistential>? {
    _storage.allNonNilValues(forKey: dynamicKey)
  }
}
