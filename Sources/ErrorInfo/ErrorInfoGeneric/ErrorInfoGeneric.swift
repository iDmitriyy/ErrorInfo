//
//  ErrorInfoGeneric.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

private import InternalCollectionsUtilities

/// A generic container for error information with per‑key multi‑value support.
///
/// `ErrorInfoGeneric` is used as a backing storage for `ErrorInfo` types. It preserves insertion order, tracks collisions, and can store multiple
/// values per key.
/// The generic `RecordValue` controls the stored value representation (e.g. an optional-capable / non-optional / equatable etc. wrapper).
/// Duplicate handling based on equality is enabled only when `RecordValue` conforms to `Equatable`.
///
/// - Key: Any `Hashable` (commonly `String`).
/// - Value: `RecordValue` determines comparison semantics for duplicate handling when it conforms to `Equatable`.
public struct ErrorInfoGeneric<Key: Hashable, RecordValue>: Sequence {
  public typealias Element = (key: Key, value: AnnotatedRecord)
  public typealias AnnotatedRecord = CollisionAnnotatedRecord<Record>
  
  @inlinable
  @inline(__always)
  internal var _variant: Variant { _mutableVariant._variant }
  
  // FIXME: private set
  @usableFromInline internal var _mutableVariant: _Variant
    
  private init(_variant: _Variant) {
    _mutableVariant = _variant
  }
  
  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    _mutableVariant = _Variant(.left(OrderedDictionary(minimumCapacity: minimumCapacity)))
  }
  
  public static var empty: Self {
    Self(_variant: _Variant(.left(OrderedDictionary())))
  } // inlining has no performance gain
  
  @inlinable @inline(__always)
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _mutableVariant.mutateUnderlying(singleValueForKey: { singleValueForKeyDict in
      singleValueForKeyDict.reserveCapacity(minimumCapacity)
    }, multiValueForKey: { multiValueForKeyDict in
      multiValueForKeyDict.reserveCapacity(minimumCapacity)
    })
  }
}

extension ErrorInfoGeneric {
  /// A single stored record combining the key origin with the value representation.
  ///
  /// - `keyOrigin`: Where the key came from (literal, dynamic, modified, etc.).
  /// - `someValue`: The stored value in `RecordValue` form.
  @frozen
  public struct Record: CustomDebugStringConvertible {
    public let keyOrigin: KeyOrigin
    public let someValue: RecordValue
    
    @inlinable @inline(__always)
    public init(keyOrigin: KeyOrigin, someValue: consuming RecordValue) {
      // consuming keyOrigin worsen performance
      self.keyOrigin = keyOrigin
      self.someValue = someValue
    }
    
    public var debugDescription: String {
      "keyOrigin: \(String(reflecting: keyOrigin)) someValue: \(String(reflecting: someValue))"
    }
  }
}

extension ErrorInfoGeneric: Sendable where Key: Sendable, RecordValue: Sendable {}

extension ErrorInfoGeneric.Record: Sendable where RecordValue: Sendable {}

extension ErrorInfoGeneric: CustomDebugStringConvertible {
  public var debugDescription: String {
    _dictionaryDescription(for: self)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append KeyValue with all arguments passed explicitly

extension ErrorInfoGeneric where RecordValue: Equatable & ErrorInfoOptionalRepresentable {
  /// Adds a value for a key, handling optional preservation and duplicate policy.
  /// - Availability: Only when `RecordValue` conforms to `Equatable`.
  ///
  /// - If `newValue` is `nil` and `preserveNilValues == true`, an explicit `nil` record is stored for `typeOfWrapped`.
  /// - If `duplicatePolicy == .rejectEqual`, equal values for the same key are skipped.
  /// - Collisions are annotated using the provided `writeProvenance`.
  internal mutating func _add(key: Key,
                              keyOrigin: KeyOrigin,
                              optionalValue newValue: RecordValue.Wrapped?,
                              typeOfWrapped: RecordValue.TypeOfWrapped,
                              preserveNilValues: Bool,
                              duplicatePolicy: ValueDuplicatePolicy,
                              writeProvenance: @autoclosure () -> WriteProvenance) {
    let optional: RecordValue
    if let newValue {
      optional = .value(newValue)
    } else if preserveNilValues {
      optional = .nilInstance(typeOfWrapped: typeOfWrapped)
    } else {
      return
    }

    withCollisionAndDuplicateResolutionAdd(record: Record(keyOrigin: keyOrigin, someValue: optional),
                                           forKey: key,
                                           duplicatePolicy: duplicatePolicy,
                                           writeProvenance: writeProvenance())
  }
}

extension ErrorInfoGeneric where RecordValue: Equatable {
  /// Adds a value (optional or not depending on generic context) for a key, honoring the duplicate policy and collision source.
  /// - Availability: Only when `RecordValue` conforms to `Equatable`.
  internal mutating func _add(key: Key,
                              keyOrigin: KeyOrigin,
                              someValue: RecordValue,
                              duplicatePolicy: ValueDuplicatePolicy,
                              writeProvenance: @autoclosure () -> WriteProvenance) {
    withCollisionAndDuplicateResolutionAdd(record: Record(keyOrigin: keyOrigin, someValue: someValue),
                                           forKey: key,
                                           duplicatePolicy: duplicatePolicy,
                                           writeProvenance: writeProvenance())
  }
}

extension ErrorInfoGeneric where RecordValue: Equatable {
  /// Appends `newRecord` for `key` according to `duplicatePolicy`, and annotates the record with `writeProvenanceForCollision`
  /// when the same key is written more than once.
  ///
  /// Behavior by policy:
  /// - `.rejectEqual`: Skips insertion if any existing value for `key` has an equal `record.someValue`. Otherwise appends.
  /// - `.allowEqualWhenOriginDiffers`: Skips insertion only when an existing value for `key` matches all of the following:
  ///   the same `record.someValue`, the same `record.keyOrigin`, and — when present — the same `collisionSource`.
  ///   If an existing record has no `collisionSource`, this dimension is ignored. Otherwise, the new record is appended.
  /// - `.allowEqual`: Always appends without comparing to existing values.
  ///
  /// - Time complexity is O(n) in the number of existing values for `key`.
  ///
  /// - Parameters:
  ///   - newRecord: The record to insert.
  ///   - key: The key under which to store the record.
  ///   - duplicatePolicy: Policy that defines when equal values are rejected or allowed.
  ///   - writeProvenance: Describes the origin of a collision; evaluated lazily.
  @usableFromInline
  internal mutating func withCollisionAndDuplicateResolutionAdd(
    record newRecord: consuming Record,
    forKey key: consuming Key,
    duplicatePolicy: ValueDuplicatePolicy,
    writeProvenance: @autoclosure () -> WriteProvenance,
  ) {
    switch duplicatePolicy.kind {
    case .rejectEqualValue:
      appendIfNotPresent(key: key,
                         value: newRecord,
                         writeProvenance: writeProvenance(),
                         andRejectWhenExistingMatches: { current in
                           Self.isEqualValue(newRecord: newRecord, current: current.record)
                         })
      
    case .rejectEqualValueWhenEqualOrigin:
      appendIfNotPresent(key: key,
                         value: newRecord,
                         writeProvenance: writeProvenance(),
                         andRejectWhenExistingMatches: { current in
                           Self.isEqualValueKeyOriginAndCollisionSource_A(newRecord: newRecord,
                                                                          writeProvenance: writeProvenance(),
                                                                          current: current)
                         })
      
    case .allowEqual:
      appendUnconditionally(key: key, value: newRecord, writeProvenance: writeProvenance())
    }
  }
  
  // Improvement: add ownership when == become borrowing in stdlib
  
  @inlinable @inline(__always)
  internal static func isEqualValue(newRecord: Record, current: Record) -> Bool {
    newRecord.someValue == current.someValue
  }
  
  @inlinable @inline(__always)
  internal static func isEqualValueKeyOriginAndCollisionSource_A(newRecord: Record,
                                                                 writeProvenance: @autoclosure () -> WriteProvenance,
                                                                 current: AnnotatedRecord) -> Bool {
    newRecord.someValue == current.record.someValue
      && newRecord.keyOrigin == current.record.keyOrigin
      && {
        if let currentCollisionSource = current.collisionSource {
          currentCollisionSource == writeProvenance()
        } else { // do not create writeProvenance() if current.collisionSource == nil
          // if no collisionSource (typically for first value), nothing to compare, and can make no assumptions.
          true // pass true to logically exclude from equality comparison
        }
      }()
  }
  
//  @inlinable @inline(__always)
//  internal static func isEqualValueKeyOriginAndCollisionSource_B(newRecord: Record,
//                                                                 writeProvenance: @autoclosure () -> WriteProvenance,
//                                                                 current: AnnotatedRecord) -> Bool {
//    newRecord.someValue == current.record.someValue
//      && newRecord.keyOrigin == current.record.keyOrigin
//      && {
//        if let currentCollisionSource = current.collisionSource {
//          currentCollisionSource == writeProvenance()
//        } else {
//          false
//        }
//      }()
//  }
}

// MARK: Append KeyValue

extension ErrorInfoGeneric {
  @usableFromInline
  internal mutating func appendIfNotPresent(key newKey: consuming Key,
                                            value newValue: Record,
                                            writeProvenance: @autoclosure () -> WriteProvenance,
                                            andRejectWhenExistingMatches decideToReject: (_ existing: borrowing AnnotatedRecord) -> Bool) {
    _mutableVariant.appendIfNotPresent(key: newKey,
                                       value: newValue,
                                       writeProvenance: writeProvenance(),
                                       rejectWhenExistingMatches: decideToReject)
  }
  
  @usableFromInline
  internal mutating func appendUnconditionally(key newKey: Key,
                                               value newValue: Record,
                                               writeProvenance: @autoclosure () -> WriteProvenance) {
    _mutableVariant.appendUnconditionally(key: newKey, value: newValue, writeProvenance: writeProvenance())
  }
}

extension ErrorInfoGeneric where RecordValue: Equatable & ErrorInfoOptionalRepresentable {
  mutating func append(contentsOf sequence: some Sequence<(Key, RecordValue.Wrapped)>,
                       duplicatePolicy: ValueDuplicatePolicy,
                       origin: WriteProvenance.Origin) {
    for (dynamicKey, value) in sequence {
      _addValue_2(
        value,
        shouldPreserveNilValues: true, // has no effect here
        duplicatePolicy: duplicatePolicy,
        forKey: dynamicKey,
        keyOrigin: .fromCollection,
        writeProvenance: .onSequenceConsumption(origin: origin),
      )
    }
  }

  internal mutating func _addValue_2(_ newValue: RecordValue.Wrapped?,
                                     shouldPreserveNilValues: Bool,
                                     duplicatePolicy: ValueDuplicatePolicy,
                                     forKey key: Key,
                                     keyOrigin: KeyOrigin,
                                     writeProvenance: @autoclosure () -> WriteProvenance) {
    let optional: RecordValue
    if let newValue {
      optional = .value(newValue)
    } else if shouldPreserveNilValues {
      optional = .nilInstance(typeOfWrapped: RecordValue.TypeOfWrapped.self as! RecordValue.TypeOfWrapped)
    } else {
      return
    }

    withCollisionAndDuplicateResolutionAdd(
      record: Record(keyOrigin: keyOrigin, someValue: optional),
      forKey: key,
      duplicatePolicy: duplicatePolicy,
      writeProvenance: writeProvenance(),
    )
  }
}

@inline(never) @_optimize(none)
public func blackHole<T>(_ thing: T) {
  _ = thing
}
