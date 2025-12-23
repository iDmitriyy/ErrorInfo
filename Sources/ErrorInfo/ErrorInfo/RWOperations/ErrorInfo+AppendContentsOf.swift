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
  /// - SeeAlso: ``append(contentsOf:duplicatePolicy:origin)``
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
    append(contentsOf: sequence, duplicatePolicy: duplicatePolicy, origin: .fileLine(file: file, line: line))
  }
  
  /// Appends a sequence of key–value pairs.
  ///
  /// - Parameters:
  ///   - sequence: A sequence of pairs where the first element is a dynamic key (`String`) and the second is a non‑optional value.
  ///   - duplicatePolicy: How to handle equal values for the same key. Use `.rejectEqual` to skip duplicates or `.allowEqual` to store all.
  ///   - origin Marks the origin used when collisions occur while consuming the sequence (for diagnostics).
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
                                                origin: WriteProvenance.Origin) {
    for (dynamicKey, value) in sequence {
      _add(key: dynamicKey,
           keyOrigin: .fromCollection,
           value: value,
           preserveNilValues: true, // has no effect here
           duplicatePolicy: duplicatePolicy,
           writeProvenance: .onSequenceConsumption(origin: origin))
    }
  }
}

/*
 var info = ErrorInfo()

 let headers: [(String, String)] = [("request_id", "abc"), ("request_id", "abc")]
 let query:   [(String, String)] = [("request_id", "abc")] // same value, different context

 // Dedupe within each sequence, allow equal across sequences:
 info.append(contentsOf: headers,
             duplicatePolicy: .allowEqualWhenOriginDiffers,
             origin .custom(origin: "headers"))

 1) Single-batch ingestion: skip duplicates vs keep all
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
 
 3) Pitfall
 // Both calls capture the same file/line origin
 
 func foo() {
   info.append(contentsOf: query, duplicatePolicy: .allowEqualWhenOriginDiffers, origin "request")
   info.append(contentsOf: params,   duplicatePolicy: .allowEqualWhenOriginDiffers, origin "request")
 }
 // Equal values may be rejected across calls unintentionally.

 4) Scoped writes with withOptions and string-literal origins
 Scopes often represent meaningful loci (e.g., “initial flow” vs “retry flow”).
 Use string origins to allow the same values to coexist when they come from different scopes.
 let info = ErrorInfo.withOptions(duplicatePolicy: .allowEqualWhenOriginDiffers,
                                  origin "initial-flow") { view in
   view[.message] = "Timeout"   // recorded with origin "initial-flow"
   view[.message] = "Timeout"   // skipped (same scope, same value)
 }

 // Later, another scope with a different origin:
 var info2 = info
 info2.appendWith(duplicatePolicy: .allowEqualWhenOriginDiffers,
                  origin "retry-flow") { view in
   view[.message] = "Timeout"   // allowed (different origin), coexists with the first
 }
 • Within the same scope "initial-flow", equal values are rejected.
 • From a different scope "retry-flow", equal values are allowed (different origin).
 
 5) Merging with a string-literal origin
 Merges preserve duplicates by design (.allowEqual internally). You can still annotate the merge’s origin with a string literal:
 var base: ErrorInfo = [.message: "Timeout"]
 let extra: ErrorInfo = [.message: "Timeout"]
 // Annotate the merge origin for diagnostics:
 let merged = base.merged(with: extra, origin "merge:network+cache")
 

  
 
 .allowEqualWhenOriginDiffers:
 “Use this when you are appending multiple sequences and want to dedupe within each sequence
 but allow equal values across sequences. Pass a distinct, meaningful collisionOrigin for each sequence.”

 • Single batch ingestion (headers from a response, a mapped array of pairs, a DB row): duplicates within that batch are usually an accident or noise. Two options suffice:
    • .rejectEqual to keep the batch clean
    • .allowEqual if you want to preserve raw
 multiplicity
 • Multiple sequences from distinct contexts (e.g., “request headers” then “response headers”, or “query params” then “resolved params”):
    - Equal values can be meaningful across contexts.
    - You often want “dedupe inside each sequence, but allow equal across sequences.”
    - That’s exactly what .allowEqualWhenOriginDiffers offer, if each sequence uses a distinct collisionOrigin.
 
 dedupeWithinSequence: Bool = true
 
 
 - “duplicatePolicy: Defines how the incoming value is compared against values already stored for the same key (across previous operations or batches).”
 - “dedupeWithinSequence: When true, equal (key, value) pairs inside this call are skipped before applying duplicatePolicy.”
 public mutating func append<V: ValueProtocol>(contentsOf sequence: some Sequence<(String, V)>,
                                               duplicatePolicy: ValueDuplicatePolicy,
                                               dedupeWithinSequence: Bool = true
                                               origin: WriteProvenance.Origin,
                                               ) {
   // When `dedupeWithinSequence` is enabled, skip equal (key, value) duplicates inside this batch,
   // while leaving cross-batch behavior to the chosen `duplicatePolicy` and `collisionOrigin`.
   if dedupeWithinSequence {
     var seen: [String: [V]] = [:]
     for (dynamicKey, value) in sequence {
       if let values = seen[dynamicKey], values.contains(value) {
         continue
       }
       seen[dynamicKey, default: []].append(value)
       _add(key: dynamicKey,
            keyOrigin: .fromCollection,
            value: value,
            preserveNilValues: true, // has no effect here
            duplicatePolicy: duplicatePolicy,
            writeProvenance: .onSequenceConsumption(origin: origin))
     }
   } else {
     for (dynamicKey, value) in sequence {
       _add(key: dynamicKey,
            keyOrigin: .fromCollection,
            value: value,
            preserveNilValues: true, // has no effect here
            duplicatePolicy: duplicatePolicy,
            writeProvenance: .onSequenceConsumption(origin: origin))
     }
   }
 }
 */
