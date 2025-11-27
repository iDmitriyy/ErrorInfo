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
  // FIXME: can optional ErrorInfoValueType be used without conflict with ErrorInfoIterable protocol
  // Alternative: if optionals are impossible for DictionaryLiteral usage, then add functionBuilder initialization that allows
  // optional values
  
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init()
    // TODO: OrderedMultipleValuesDictionaryLiteral(dictionaryLiteral: elements) or appropriate init
    // TODO: try reserve capacity. perfomance tests
    // Make Key = ErronInfoLiteralKey instead of String
    
    for (literalKey, value) in elements {
      if let value {
        // TODO: _add() with optional value is used
        _add(key: literalKey.rawValue,
             keyOrigin: literalKey.keyOrigin,
             value: value,
             preserveNilValues: true,
             insertIfEqual: true,
             addTypeInfo: .default,
             collisionSource: .onCreateWithDictionaryLiteral)
      } else {
        _addExistentialNil(key: literalKey.rawValue,
                           keyOrigin: literalKey.keyOrigin,
                           preserveNilValues: true,
                           insertIfEqual: true,
                           collisionSource: .onCreateWithDictionaryLiteral)
      }
    }
  }
}
