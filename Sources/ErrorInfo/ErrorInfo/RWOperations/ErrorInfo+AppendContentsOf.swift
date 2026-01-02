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
  ///   - duplicatePolicy: Defines how the incoming value is compared against values already stored  in `ErrorInfo` for the
  ///     same key.
  ///   - dedupeWithinSequence: When true, equal `(key, value)` pairs inside this call are skipped before applying `duplicatePolicy`.
  ///   - file: The file identifier to record as the origin (defaults to `#fileID`).
  ///   - line: The line number to record as the origin (defaults to `#line`).
  ///
  /// - Complexity: O(n) where n is the number of pairs in `sequence`.
  ///
  /// - SeeAlso: ``append(contentsOf:duplicatePolicy:dedupeWithinSequence:origin)``
  ///
  /// # Example
  /// ```swift
  /// var info = ErrorInfo()
  /// let pairs: [(String, Int)] = [("id", 1), ("id", 1), ("name", 7)]
  ///
  /// // Skips the second `1` for key "id"
  /// info.append(contentsOf: pairs, duplicatePolicy: .rejectEqual)
  /// ```
  public mutating func append(contentsOf sequence: some Sequence<(String, some ValueProtocol)>,
                              duplicatePolicy: ValueDuplicatePolicy = .allowEqualWhenOriginDiffers,
                              file: String = #fileID,
                              line: UInt = #line) {
    append(contentsOf: sequence, duplicatePolicy: duplicatePolicy, origin: .fileLine(file: file, line: line))
  }
  
  /// Appends a sequence of key–value pairs.
  ///
  /// - Parameters:
  ///   - newKeyValues: A sequence of pairs where the first element is a dynamic key (`String`) and the second is a non‑optional value.
  ///   - duplicatePolicy: Defines how the incoming value is compared against values already stored  in `ErrorInfo` for the
  ///     same key.
  ///   - dedupeWithinSequence: When true, equal `(key, value)` pairs inside this call are skipped before applying `duplicatePolicy`.
  ///   - origin: Marks the origin used when collisions occur while consuming the sequence (for diagnostics).
  ///
  /// - Complexity: O(n) where n is the number of pairs in `sequence`.
  ///
  /// - Note:
  ///   - **Multiplicity**:
  ///     Multiple sequences from distinct contexts (e.g., “request headers” or “query params”)
  ///     - Equal values can be meaningful across contexts.
  ///     - You often want “dedupe inside each sequence, but allow equal across sequences.”
  ///     - That’s exactly what default values for `duplicatePolicy` and `dedupeWithinSequence` params offer,
  ///       if each sequence uses a distinct `origin`.
  ///   - **Single batch ingestion**:
  ///       Duplicates within that batch are usually an accident or noise. Two options suffice:
  ///     - `dedupeWithinSequence = true` to keep the batch clean
  ///     - `dedupeWithinSequence = false` if you want to preserve raw
  ///
  /// # Example (pitfall)
  /// ```
  /// // Both calls capture the same file/line origin
  /// func foo() {
  ///   info.append(contentsOf: query, origin: "request")
  ///   info.append(contentsOf: params, origin: "request")
  /// }
  /// // As `origin` is the same, equal `key-value` pairs across `query` and `params`
  /// // will be rejected, which may be unexpected.
  /// ```
  public mutating func append(contentsOf newKeyValues: some Sequence<(String, some ValueProtocol)>,
                              duplicatePolicy: ValueDuplicatePolicy = .allowEqualWhenOriginDiffers,
                              origin: @autoclosure () -> WriteProvenance.Origin) {
    func add(key: String, value: some ValueProtocol) {
      withCollisionAndDuplicateResolutionAdd(
        value: value,
        duplicatePolicy: duplicatePolicy,
        forKey: key,
        keyOrigin: .fromCollection,
        writeProvenance: .onSequenceConsumption(origin: origin()),
      )
    }
    
    let done: Void? = newKeyValues.withContiguousStorageIfAvailable { new in
      let newCount = new.count
      
      switch newCount {
      case 0:
        return Void()
        
      case 1:
        let (key, value) = new[0]
        add(key: key, value: value)
        return Void()
      
      default:
        _storage.reserveCapacity(self.count + newCount)
        for index in new.indices {
          let (key, value) = new[index]
          add(key: key, value: value)
        }
        return Void()
      }
    }
    
    if done == nil {
      newKeyValues.forEach { key, value in
        add(key: key, value: value)
      }
    }
  }
}
