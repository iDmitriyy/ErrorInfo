//
//  ErrorInfo+DictionaryLiteral.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

// MARK: Expressible By Dictionary Literal

extension ErrorInfo: ExpressibleByDictionaryLiteral {
  public typealias Value = (any ErrorInfoValueType)?
  public typealias Key = StringLiteralKey
  
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init()
    // Improvement: try reserve capacity. perfomance tests
    for (literalKey, value) in elements {
      if let value {
        // TODO: _add() with optional value is used
        _add(key: literalKey.rawValue,
             keyOrigin: literalKey.keyOrigin,
             value: value,
             preserveNilValues: true,
             duplicatePolicy: .allowEqual,
             collisionSource: .onCreateWithDictionaryLiteral)
      } else {
        _addExistentialNil(key: literalKey.rawValue,
                           keyOrigin: literalKey.keyOrigin,
                           preserveNilValues: true,
                           duplicatePolicy: .allowEqual,
                           collisionSource: .onCreateWithDictionaryLiteral)
      }
    }
  }
}

extension ErrorInfo {
  // TODO: literal or function builder
  
  // func mutating appendKeyValues(_ literal: KeyValuePairs<Key, Value>) {
  //
  // }
}
