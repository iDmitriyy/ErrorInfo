//
//  ErrorInfoAny+AppendKeyValues.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 20/12/2025.
//

// MARK: - Append KeyValues literal

extension ErrorInfoAny {
  public mutating func appendKeyValues(_ literal: KeyValuePairs<Key, Value>,
                                       file: StaticString = #fileID,
                                       line: UInt = #line) {
    appendKeyValues(literal, origin: .fileLine(file: file, line: line))
  }
  
  public mutating func appendKeyValues(_ literal: KeyValuePairs<Key, Value>,
                                       origin: @autoclosure () -> WriteProvenance.Origin) {
    _appendKeyValuesImp(_dictionaryLiteral: literal, writeProvenance: .onDictionaryConsumption(origin: origin()))
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Imp

extension ErrorInfoAny {
  internal mutating func _appendKeyValuesImp(_dictionaryLiteral elements: some Collection<(key: Key, value: Value)>,
                                             writeProvenance: @autoclosure () -> WriteProvenance) {
    // Improvement: try reserve capacity. perfomance tests
    for (literalKey, value) in elements {
      _add(key: literalKey.rawValue,
           keyOrigin: literalKey.keyOrigin,
           value: value,
           preserveNilValues: true,
           duplicatePolicy: .allowEqual,
           writeProvenance: writeProvenance())
    }
  }
}
