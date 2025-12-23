//
//  ErrorInfoAny+DictionaryLiteral.swift
//  ErrorInfo
//
//  Created by tmp on 20/12/2025.
//

// MARK: - Expressible By Dictionary Literal

extension ErrorInfoAny: ExpressibleByDictionaryLiteral {
  public typealias Key = StringLiteralKey
  public typealias Value = Any? // allows to initialize by dictionary literal with optional values
  
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(minimumCapacity: elements.count)
    _appendKeyValuesImp(_dictionaryLiteral: elements, writeProvenance: .onCreateWithDictionaryLiteral)
  }
}
