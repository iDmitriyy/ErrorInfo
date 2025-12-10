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
    _mergeKeyValues(_literal: elements, collisionSource: .onCreateWithDictionaryLiteral)
  }
}

extension ErrorInfo {
  public mutating func mergeKeyValues(_ literal: KeyValuePairs<Key, Value>,
                                      collisionSource origin: @autoclosure () -> CollisionSource.Origin = .fileLine()) {
    _mergeKeyValues(_literal: literal, collisionSource: .onDictionaryConsumption(origin: origin()))
  }
}

extension ErrorInfo {
  private mutating func _mergeKeyValues(_literal elements: some Collection<(key: Key, value: Value)>,
                                        collisionSource: @autoclosure () -> CollisionSource) {
    // Improvement: try reserve capacity. perfomance tests
    for (literalKey, value) in elements {
      if let value {
        // TODO: _add() with optional value is used
        _add(key: literalKey.rawValue,
             keyOrigin: literalKey.keyOrigin,
             value: value,
             preserveNilValues: true,
             duplicatePolicy: .allowEqual,
             collisionSource: collisionSource())
      } else {
        _addExistentialNil(key: literalKey.rawValue,
                           keyOrigin: literalKey.keyOrigin,
                           preserveNilValues: true,
                           duplicatePolicy: .allowEqual,
                           collisionSource: collisionSource())
      }
    }
  }
}
