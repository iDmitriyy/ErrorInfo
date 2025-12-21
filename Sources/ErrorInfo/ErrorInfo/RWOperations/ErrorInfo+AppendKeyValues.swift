//
//  ErrorInfo+AppendKeyValues.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 19/12/2025.
//

// MARK: - Append KeyValues literal

extension ErrorInfo {
  public mutating func appendKeyValues(_ literal: KeyValuePairs<Key, Value>,
                                       file: StaticString = #fileID,
                                       line: UInt = #line) {
    appendKeyValues(literal, collisionSource: .fileLine(file: file, line: line))
  }
  
  /// Allows to append key-value pairs from Dictionary literal into the existing `ErrorInfo` instance.
  /// Collisions during appending are tracked with the `CollisionSource.onDictionaryConsumption` source.
  ///
  /// - Parameters:
  ///   - literal: The key-value pairs to merge into the errorInfo.
  ///   - origin: The source of the collision (default is `.fileLine()`).
  ///
  /// - Note:
  ///   - If `nil` values are provided, they are explicitly stored.
  ///   - Duplicate values for the same key are appended, as the method allows duplicates by default.
  ///
  /// # Example:
  /// ```swift
  /// errorInfo.appendKeyValues([
  ///   .id: 0,
  ///   .count: 2,
  ///   .request + .id = 3
  /// ])
  /// ```
  public mutating func appendKeyValues(_ literal: KeyValuePairs<Key, Value>,
                                       collisionSource origin: @autoclosure () -> CollisionSource.Origin) {
    _appendKeyValuesImp(_dictionaryLiteral: literal, collisionSource: .onDictionaryConsumption(origin: origin()))
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Imp

extension ErrorInfo {
  internal mutating func _appendKeyValuesImp(_dictionaryLiteral elements: some Collection<(key: StringLiteralKey, value: Value)>,
                                             collisionSource: @autoclosure () -> CollisionSource) {
    // Improvement: try reserve capacity. perfomance tests
    for (literalKey, value) in elements {
      if let value {
        // TBD: _add() with optional value is used
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
