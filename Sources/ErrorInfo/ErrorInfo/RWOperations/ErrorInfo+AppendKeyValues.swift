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
  /// Collisions during appending are tracked with the `WriteProvenance.onDictionaryConsumption` source.
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
  /// // Appending multiple key-value pairs from a dictionary literal
  /// errorInfo.appendKeyValues([
  ///   .sessionID: 1234,
  ///   .requestID: 42,
  ///   .lastLogin: "2023-12-20T10:00:00Z"
  /// ])
  /// ```
  public mutating func appendKeyValues(_ dictionaryLiteral: KeyValuePairs<Key, Value>,
                                       preserveNilValues: Bool = true,
                                       file: StaticString = #fileID,
                                       line: UInt = #line) {
    appendKeyValues(dictionaryLiteral,
                    preserveNilValues: preserveNilValues,
                    origin: .fileLine(file: file, line: line))
  }
  
  /// Allows to append key-values from Dictionary literal into the existing `ErrorInfo` instance.
  ///
  /// Collisions during appending are tracked with the `WriteProvenance.onDictionaryLiteralConsumption` source.
  ///
  /// - Parameters:
  ///   - dictionaryLiteral: The key-value pairs to append into the errorInfo.
  ///   - origin: The source of the collision
  ///
  /// - Note:
  ///   - If `nil` values are provided, they are explicitly stored.
  ///   - Duplicate values for the same key are appended, as the method allows duplicates by default.
  ///
  /// When consuming dictionary-literal style pairs, you can tag the batch with a human-friendly origin.
  ///
  /// # Example:
  /// ```swift
  /// // Custom origin for the appended key-value pairs
  /// errorInfo.appendKeyValues([
  ///   .transactionID: "TXN123456",
  ///   .amount: 99.99
  /// ], origin: "TransactionProcessor")
  /// ```
  public mutating func appendKeyValues(_ dictionaryLiteral: KeyValuePairs<Key, Value>,
                                       preserveNilValues: Bool = true,
                                       origin: @autoclosure () -> WriteProvenance.Origin) {
    _appendKeyValuesImp(_dictionaryLiteral: dictionaryLiteral,
                        preserveNilValues: preserveNilValues,
                        writeProvenance: .onDictionaryLiteralConsumption(origin: origin()))
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Imp

extension ErrorInfo {
  internal mutating func _appendKeyValuesImp(_dictionaryLiteral elements: some Collection<(key: StringLiteralKey, value: Value)>,
                                             preserveNilValues: Bool,
                                             writeProvenance: @autoclosure () -> WriteProvenance) {
    let duplicatePolicy: ValueDuplicatePolicy = .defaultForAppendingDictionaryLiteral
    
    for (literalKey, value) in elements {
      if let value {
        // TBD: _add() with optional value is used
        _add(key: literalKey.rawValue,
             keyOrigin: literalKey.keyOrigin,
             value: value,
             preserveNilValues: true,
             duplicatePolicy: duplicatePolicy,
             writeProvenance: writeProvenance())
      } else if preserveNilValues {
        _addNil(key: literalKey.rawValue,
                keyOrigin: literalKey.keyOrigin,
                typeOfWrapped: ValueExistential.self,
                duplicatePolicy: duplicatePolicy,
                writeProvenance: writeProvenance())
      }
    }
  }
}
