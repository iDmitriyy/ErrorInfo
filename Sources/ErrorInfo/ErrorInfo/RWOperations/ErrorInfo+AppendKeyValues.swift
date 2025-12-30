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
  /// Collisions during appending are tracked with the `WriteProvenance.onDictionaryLiteralConsumption` source.
  /// When consuming dictionary-literal style pairs, you can tag the batch with a human-friendly origin.
  ///
  /// This convenience overload records the call site (`#fileID`, `#line`) as the collision origin for operations
  /// executed within the scope.
  ///
  /// - Parameters:
  ///   - dictionaryLiteral: The key-value pairs to append into the errorInfo.
  ///   - preserveNilValues: Whether `nil` values should be recorded as explicit `nil` entries. Defaults to `true`.
  ///   - file: File identifier used as collision origin (defaults to `#fileID`).
  ///   - line: Line number used as collision origin (defaults to `#line`).
  ///
  /// - Note:
  ///   - Duplicate values for the same key are appended, as the method allows duplicates by design.
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
                                       duplicatePolicy: ValueDuplicatePolicy = .allowEqualWhenOriginDiffers,
                                       file: StaticString = #fileID,
                                       line: UInt = #line) {
    appendKeyValues(dictionaryLiteral,
                    preserveNilValues: preserveNilValues,
                    duplicatePolicy: duplicatePolicy,
                    origin: .fileLine(file: file, line: line))
  }
  
  /// Allows to append key-values from Dictionary literal into the existing `ErrorInfo` instance.
  ///
  /// Collisions during appending are tracked with the `WriteProvenance.onDictionaryLiteralConsumption` source.
  /// When consuming dictionary-literal style pairs, you can tag the batch with a human-friendly origin.
  ///
  /// - Parameters:
  ///   - dictionaryLiteral: The key-value pairs to append into the errorInfo.
  ///   - preserveNilValues: Whether `nil` values should be recorded as explicit `nil` entries. Defaults to `true`.
  ///   - origin: The source of the collision
  ///
  /// - Note:
  ///   - Duplicate values for the same key are appended, as the method allows duplicates by design.
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
                                       duplicatePolicy: ValueDuplicatePolicy = .allowEqualWhenOriginDiffers,
                                       origin: @autoclosure () -> WriteProvenance.Origin) {
    _appendKeyValuesImp(_dictionaryLiteral: dictionaryLiteral,
                        preserveNilValues: preserveNilValues,
                        duplicatePolicy: duplicatePolicy,
                        writeProvenance: .onDictionaryLiteralConsumption(origin: origin()))
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Imp

extension ErrorInfo {
  @usableFromInline
  internal mutating func _appendKeyValuesImp(_dictionaryLiteral elements: some Collection<(key: StringLiteralKey, value: Value)>,
                                             preserveNilValues: Bool,
                                             duplicatePolicy: ValueDuplicatePolicy,
                                             writeProvenance: @autoclosure () -> WriteProvenance) {
    for (literalKey, value) in elements {
      if let value {
        withCollisionAndDuplicateResolutionAdd(
          value: value,
          duplicatePolicy: duplicatePolicy,
          forKey: literalKey.rawValue,
          keyOrigin: literalKey.keyOrigin,
          writeProvenance: writeProvenance(),
        )
      } else if preserveNilValues {
        _addNil(
          typeOfWrapped: ValueExistential.self,
          duplicatePolicy: duplicatePolicy,
          forKey: literalKey.rawValue,
          keyOrigin: literalKey.keyOrigin,
          writeProvenance: writeProvenance(),
        )
      }
    }
  } // inlining has no performance gain for `appendKeyValues` func and make `init(dictionaryLiteral:)` ~2x slower
}
