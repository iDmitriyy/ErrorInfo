//
//  ErrorInfo+AppendKeyValues.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 19/12/2025.
//

// MARK: - Append KeyValues literal

extension ErrorInfo {
  /// Allows to append key-values from Dictionary literal into the existing `ErrorInfo` instance.
  ///
  /// Collisions during appending are tracked with the `CollisionSource.onDictionaryConsumption` source.
  /// This convenience overload records the call site (`#fileID`, `#line`) as the collision origin for operations
  /// executed within the scope.
  ///
  /// - Parameters:
  ///   - dictionaryLiteral: The key-value pairs to append into the errorInfo.
  ///   - file: File identifier used as collision origin (defaults to `#fileID`).
  ///   - line: Line number used as collision origin (defaults to `#line`).
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
  public mutating func appendKeyValues(_ dictionaryLiteral: KeyValuePairs<Key, Value>,
                                       file: StaticString = #fileID,
                                       line: UInt = #line) {
    appendKeyValues(dictionaryLiteral, collisionSource: .fileLine(file: file, line: line))
  }
  
  /// Allows to append key-values from Dictionary literal into the existing `ErrorInfo` instance.
  ///
  /// Collisions during appending are tracked with the `CollisionSource.onDictionaryConsumption` source.
  ///
  /// - Parameters:
  ///   - dictionaryLiteral: The key-value pairs to append into the errorInfo.
  ///   - origin: The source of the collision
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
  public mutating func appendKeyValues(_ dictionaryLiteral: KeyValuePairs<Key, Value>,
                                       collisionSource origin: @autoclosure () -> CollisionSource.Origin) {
    _appendKeyValuesImp(_dictionaryLiteral: dictionaryLiteral, collisionSource: .onDictionaryConsumption(origin: origin()))
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Imp

extension ErrorInfo {
  internal mutating func _appendKeyValuesImp(_dictionaryLiteral elements: some Collection<(key: StringLiteralKey, value: Value)>,
                                             collisionSource: @autoclosure () -> CollisionSource) {
    
    
    let duplicatePolicy: ValueDuplicatePolicy = .defaultForAppendingDictionaryLiteral
    
    for (literalKey, value) in elements {
      if let value {
        // TBD: _add() with optional value is used
        _add(key: literalKey.rawValue,
             keyOrigin: literalKey.keyOrigin,
             value: value,
             preserveNilValues: true,
             duplicatePolicy: duplicatePolicy,
             collisionSource: collisionSource())
      } else {
        _addNil(key: literalKey.rawValue,
                keyOrigin: literalKey.keyOrigin,
                typeOfWrapped: ValueExistential.self,
                duplicatePolicy: duplicatePolicy,
                collisionSource: collisionSource())
      }
    }
  }
}
