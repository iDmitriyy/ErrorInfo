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
                              dedupeWithinSequence _: Bool = true,
                              file: StaticString = #fileID,
                              line: UInt = #line) {
    append(contentsOf: sequence, duplicatePolicy: duplicatePolicy, origin: .fileLine(file: file, line: line))
  }
  
  /// Appends a sequence of key–value pairs.
  ///
  /// - Parameters:
  ///   - sequence: A sequence of pairs where the first element is a dynamic key (`String`) and the second is a non‑optional value.
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
  public mutating func append(contentsOf sequence: some Sequence<(String, some ValueProtocol)>,
                              duplicatePolicy: ValueDuplicatePolicy = .allowEqualWhenOriginDiffers,
                              origin: WriteProvenance.Origin) {
    for (dynamicKey, value) in sequence {
      withCollisionAndDuplicateResolutionAdd(
        value: value,
        duplicatePolicy: duplicatePolicy,
        forKey: dynamicKey,
        keyOrigin: .fromCollection,
        writeProvenance: .onSequenceConsumption(origin: origin),
      )
    }
  }
}

/*
 /// # Example
 /// ```swift
 /// var info = ErrorInfo()
 /// let pairs: [(String, Int)] = [("id", 1), ("id", 1), ("name", 7)]
 ///
 /// // Skips the second `1` for key "id"
 /// info.append(contentsOf: pairs, duplicatePolicy: .rejectEqual)
 /// ```
 
 var info = ErrorInfo()

 let headers: [(String, String)] = [("request_id", "abc"), ("request_id", "abc")]
 let query:   [(String, String)] = [("request_id", "abc")] // same value, different context

 // Dedupe within each sequence, allow equal across sequences:
 info.append(contentsOf: headers,
             duplicatePolicy: .allowEqualWhenOriginDiffers,
             origin .custom(origin: "headers"))

 1) Single-batch appending: skip duplicates vs keep all
 info.append(contentsOf: query,
             duplicatePolicy: .allowEqualWhenOriginDiffers,
             origin .custom(origin: "query"))
 
 let pairs: [(String, String)] = [("id", "1"), ("id", "1"), ("name", "A")]

 // Default: dedupe inside the batch, regardless of duplicatePolicy
 info.append(contentsOf: pairs,
             duplicatePolicy: .allowEqual,               // cross-batch: keep all
             origin "user-import-batch",
             dedupeWithinSequence: true)                 // intra-batch: skip equal duplicates

 // If you want to preserve raw multiplicity within the same sequence:
 info.append(contentsOf: pairs,
             duplicatePolicy: .allowEqual,               // cross-batch: keep all
             origin "user-import-batch-2",
             dedupeWithinSequence: false)                // intra-batch: keep duplicates
 
 2) Multiple sequences from different contexts: dedupe within each, allow equal across sequences
 This is the sweet spot for .allowEqualWhenOriginDiffers. Give each sequence a distinct, meaningful origin string.
 let headers: [(String, String)] = [("request_id", "abc"), ("request_id", "abc")]
 let query:   [(String, String)] = [("request_id", "abc")] // same value, different context

 // Dedupe within each sequence, allow equal across sequences:
 info.append(contentsOf: headers,
             duplicatePolicy: .allowEqualWhenOriginDiffers,
             origin "headers",
             dedupeWithinSequence: true)

 info.append(contentsOf: query,
             duplicatePolicy: .allowEqualWhenOriginDiffers,
             origin "query",
             dedupeWithinSequence: true)
 - Inside headers, the duplicate is skipped (same origin "headers").
 - The query entry is appended, because its origin "query" differs even though the value is equal.
 
 .allowEqualWhenOriginDiffers:
 “Use this when you are appending multiple sequences and want to dedupe within each sequence
 but allow equal values across sequences. Pass a distinct, meaningful collisionOrigin for each sequence.”

 intial state: no such value in info yet
  Duplicates within sequence:
  - first value will be appended
  - second will be skipped (as value equal, keyOrigin alwayas equal for all elements, and writeOrigin the same for whole sequence)
 
  Append another sequence with 2 values that duplicate inside this sequence and across previous sequence:
  - first value will be appended (❌ not true now, as existing value has no collisionSourece)
  - second will be skipped (yes, but it is because of improper imp)

 // write originless:
 //
 
 */
