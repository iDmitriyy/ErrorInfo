//
//  ErrorInfoAny+AppendKeyValues.swift
//  ErrorInfo
//
//  Created by tmp on 20/12/2025.
//

// MARK: - Append KeyValues literal

extension ErrorInfoAny {
  public mutating func appendKeyValues(_ literal: KeyValuePairs<Key, Value>,
                                       file: StaticString = #fileID,
                                       line: UInt = #line) {
    appendKeyValues(literal, collisionSource: .fileLine(file: file, line: line))
  }
  
  public mutating func appendKeyValues(_ literal: KeyValuePairs<Key, Value>,
                                       collisionSource origin: @autoclosure () -> CollisionSource.Origin) {
    _appendKeyValuesImp(_dictionaryLiteral: literal, collisionSource: .onDictionaryConsumption(origin: origin()))
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Imp

extension ErrorInfoAny {
  internal mutating func _appendKeyValuesImp(_dictionaryLiteral elements: some Collection<(key: Key, value: Value)>,
                                             collisionSource: @autoclosure () -> CollisionSource) {
    // Improvement: try reserve capacity. perfomance tests
    for (literalKey, value) in elements {
      _add(key: literalKey.rawValue,
           keyOrigin: literalKey.keyOrigin,
           value: value,
           preserveNilValues: true,
           duplicatePolicy: .allowEqual,
           collisionSource: collisionSource())
    }
  }
}
