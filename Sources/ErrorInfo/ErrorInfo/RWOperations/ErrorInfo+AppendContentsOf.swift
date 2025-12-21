//
//  ErrorInfo+AppendContentsOf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

// MARK: - Append ContentsOf

extension ErrorInfo {
  /// Appends a sequence of key–value pairs.
  ///
  /// This convenience overload captures `#fileID` and `#line` to annotate potential collisions that occur
  /// while consuming the sequence.
  ///
  /// - Parameters:
  ///   - sequence: A sequence of pairs where the first element is a dynamic key (`String`) and the second is a non‑optional value.
  ///   - duplicatePolicy: How to handle equal values for the same key. Use `.rejectEqual` to skip duplicates or `.allowEqual` to store all.
  ///   - file: The file identifier to record as the origin (defaults to `#fileID`).
  ///   - line: The line number to record as the origin (defaults to `#line`).
  ///
  /// - Complexity: O(n) where n is the number of pairs in `sequence`.
  ///
  /// - SeeAlso: ``append(contentsOf:duplicatePolicy:collisionSource:)``
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  /// let pairs: [(String, Int)] = [("id", 1), ("id", 1), ("name", 7)]
  ///
  /// // Skips the second `1` for key "id"
  /// info.append(contentsOf: pairs, duplicatePolicy: .rejectEqual)
  /// ```
  public mutating func append<V: ValueProtocol>(contentsOf sequence: some Sequence<(String, V)>,
                                                duplicatePolicy: ValueDuplicatePolicy,
                                                file: StaticString = #fileID,
                                                line: UInt = #line)  {
    append(contentsOf: sequence, duplicatePolicy: duplicatePolicy, collisionSource: .fileLine(file: file, line: line))
  }
  
  /// Appends a sequence of key–value pairs.
  ///
  /// - Parameters:
  ///   - sequence: A sequence of pairs where the first element is a dynamic key (`String`) and the second is a non‑optional value.
  ///   - duplicatePolicy: How to handle equal values for the same key. Use `.rejectEqual` to skip duplicates or `.allowEqual` to store all.
  ///   - collisionSource: Marks the origin used when collisions occur while consuming the sequence (for diagnostics).
  ///
  /// - Complexity: O(n) where n is the number of pairs in `sequence`.
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  /// let pairs: [(String, Int)] = [("id", 1), ("id", 1), ("name", 7)]
  ///
  /// // Skips the second `1` for key "id"
  /// info.append(contentsOf: pairs, duplicatePolicy: .rejectEqual)
  /// ```
  public mutating func append<V: ValueProtocol>(contentsOf sequence: some Sequence<(String, V)>,
                                                duplicatePolicy: ValueDuplicatePolicy,
                                                collisionSource collisionOrigin: CollisionSource.Origin) {
    for (dynamicKey, value) in sequence {
      _add(key: dynamicKey,
           keyOrigin: .fromCollection,
           value: value,
           preserveNilValues: true, // has no effect here
           duplicatePolicy: duplicatePolicy,
           collisionSource: .onSequenceConsumption(origin: collisionOrigin))
    }
  }
}

