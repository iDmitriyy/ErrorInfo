//
//  OperationOtput.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 26/11/2025.
//

extension Merge { // uncomment of someone need
  /// Tracks and manages collisions during a merge operation, recording the affected keys and their associated values.
  ///
  /// The `CollisionTracker` handles collisions that occur when merging data from multiple sources.
  /// It tracks which keys have collided and records the associated values and collision types.
  /// Collisions can be classified as either "cross-source" (when the same key appears in different sources)
  /// or "within-source" (when a key appears multiple times within the same source).
  /// You can pass an empty instance of `CollisionTracker()`  to mege function and inspect
  /// gathered information after merge operation.
  ///
  /// # Example:
  /// ```swift
  /// var tracker = CollisionTracker<String>()
  /// tracker.addCollisionRecord(key: "key1", value: "value1", typeOfCollision: .crossSource)
  /// tracker.addCollisionRecord(key: "key1", value: "value2", typeOfCollision: .withinSource)
  ///
  /// print(tracker.collisionRecords["key1"]?.mergedRecords)
  /// // Output: ["value1", "value2"]
  ///
  /// print(tracker.collisionRecords["key1"]?.typeOfCollision)
  /// // Output: .both
  /// ```
  ///
  /// - Parameter Value: The type of the values associated with the keys being tracked.
  /// - Properties:
  ///   - `collisionRecords`: A dictionary of key-collision pairs, where each key is associated with its collision records and the type of collision that occurred.
  
  // public final class CollisionTracker<Value> {
  //   public private(set) var collisionRecords: OrderedDictionary<String, CollisionRecord>
  //
  //   public init() { collisionRecords = [:] }
  //
  //   public struct CollisionRecord {
  //     public fileprivate(set) var records: [(value: Value, sourceSignature: String?)]
  //     let collisionKind: CollisionKind
  //
  //     fileprivate init(record: Value, sourceSignature: String?, collisionKind: CollisionKind) {
  //       records = Array(minimumCapacity: 2)
  //       records.append((record, sourceSignature))
  //       self.collisionKind = collisionKind
  //     }
  //   }
  //
  //   internal func _addRecord(key: String,
  //                            value: Value,
  //                            keyHasCollisionAcross: Bool,
  //                            keyHasCollisionWithin: Bool,
  //                            sourceSignature: String?) {
  //     let collisionKind: Merge.CollisionKind
  //
  //     switch (keyHasCollisionAcross, keyHasCollisionWithin) {
  //     case (false, false): return // early exit
  //     case (true, false): collisionKind = .crossSource
  //     case (false, true): collisionKind = .withinSource
  //     case (true, true): collisionKind = .both
  //     }
  //
  //     if let index = collisionRecords.index(forKey: key) {
  //       collisionRecords.values[index].records.append((value, sourceSignature))
  //     } else {
  //       collisionRecords[key] = CollisionRecord(record: value, sourceSignature: sourceSignature, collisionKind: collisionKind)
  //     }
  //   }
  // }
  //
  // public enum CollisionKind: Sendable {
  //   case crossSource
  //   case withinSource
  //   case both
  // }
}
