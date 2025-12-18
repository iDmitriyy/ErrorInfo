//
//  ErrorInfoAny+AllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

extension ErrorInfoAny {
  public func allValues(forKey literalKey: StringLiteralKey) -> ValuesForKey<ValueExistential>? {
    allValues(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func allValues(forKey dynamicKey: String) -> ValuesForKey<ValueExistential>? {
    _storage.allNonNilValues(forKey: dynamicKey)
  }
}
