//
//  ErrorInfo+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: - AllValues ForKey

extension ErrorInfo {
  // TBD: public func allValuesSlice(forKey key: Key) -> (some Sequence<Value>)? {}
  // replace usage of allValues(forKey:) for better perfomance | reduce allocations
  
  
  public func allValues(forKey literalKey: StringLiteralKey) -> ValuesForKey<any ValueType>? {
    allValues(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func allValues(forKey dynamicKey: String) -> ValuesForKey<any ValueType>? {
    _storage.allValues(forKey: dynamicKey)?._compactMap { $0.value._optional.maybeValue.asOptional }
  }
}
