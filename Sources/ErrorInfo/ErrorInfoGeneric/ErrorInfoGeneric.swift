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
  
  @usableFromInline internal typealias BackingStorage = OrderedMultipleValuesForKeyStorage<Key, Record>
  
  @usableFromInline internal var _storage: BackingStorage
    
  private init(storage: BackingStorage) {
    _storage = storage
  }
  
  /// Creates an empty `ErrorInfo` instance.
  public init() {
    self.init(storage: BackingStorage())
  }
  
  /// Creates an empty `ErrorInfo` instance with a specified minimum capacity.
  public init(minimumCapacity: Int) {
    self.init(storage: BackingStorage(minimumCapacity: minimumCapacity))
  }
  
  /// An empty instance of `ErrorInfo`.
  public static var empty: Self { Self() }
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
    
    @usableFromInline
    internal init(keyOrigin: KeyOrigin, someValue: RecordValue) {
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
  /// - Collisions are annotated using the provided `collisionSource`.
  internal mutating func _add(key: Key,
                              keyOrigin: KeyOrigin,
                              optionalValue newValue: RecordValue.Wrapped?,
                              typeOfWrapped: RecordValue.TypeOfWrapped,
                              preserveNilValues: Bool,
                              duplicatePolicy: ValueDuplicatePolicy,
                              collisionSource: @autoclosure () -> CollisionSource) {
    let optional: RecordValue
    if let newValue {
      optional = .value(newValue)
    } else if preserveNilValues {
      optional = .nilInstance(typeOfWrapped: typeOfWrapped)
    } else {
      return
    }

    _addWithCollisionResolution(record: Record(keyOrigin: keyOrigin, someValue: optional),
                                forKey: key,
                                duplicatePolicy: duplicatePolicy,
                                collisionSource: collisionSource())
  }
}

extension ErrorInfoGeneric where RecordValue: Equatable {
  /// Adds a value (optional or not depending on generic context) for a key, honoring the duplicate policy and collision source.
  /// - Availability: Only when `RecordValue` conforms to `Equatable`.
  internal mutating func _add(key: Key,
                              keyOrigin: KeyOrigin,
                              someValue: RecordValue,
                              duplicatePolicy: ValueDuplicatePolicy,
                              collisionSource: @autoclosure () -> CollisionSource) {
    _addWithCollisionResolution(record: Record(keyOrigin: keyOrigin, someValue: someValue),
                                forKey: key,
                                duplicatePolicy: duplicatePolicy,
                                collisionSource: collisionSource())
  }
}

extension ErrorInfoGeneric where RecordValue: Equatable {
  /// Appends `newRecord` for `key` according to `duplicatePolicy`, and annotates the record with `collisionSource`
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
  ///   - collisionSource: Describes the origin of a collision; evaluated lazily.
  internal mutating func _addWithCollisionResolution(record newRecord: Record,
                                                     forKey key: Key,
                                                     duplicatePolicy: ValueDuplicatePolicy,
                                                     collisionSource: @autoclosure () -> CollisionSource) {
    let comparator: (AnnotatedRecord) -> Bool
    let currentValues: ValuesForKey<AnnotatedRecord>?
    switch duplicatePolicy.kind {
    case .rejectEqualValue:
      currentValues = _storage.allValues(forKey: key)
      comparator = { current in newRecord.someValue == current.record.someValue }
      // FIXME: - .rejectEqual is x3 more fast than other on append
    case .rejectEqualValueWhenEqualOrigin:
      currentValues = _storage.allValues(forKey: key)
      let collisionSource = collisionSource() // Improvement: collisionSource() called twice
      comparator = { current in
        let isEqualValue = newRecord.someValue == current.record.someValue
        let isEqualKeyOrigin = { newRecord.keyOrigin == current.record.keyOrigin }
        
        let isEqualCollisionSource = {
          if let currentCollisionSource = current.collisionSource {
            currentCollisionSource == collisionSource
          } else { // if no collisionSource (typically for first value), nothing to compare, and can make no assumptions.
            true // pass true to logically exclude from equality comparison
          }
        }
        return isEqualValue && isEqualKeyOrigin() && isEqualCollisionSource()
      }
      
    case .allowEqual:
      _storage.append(key: key, value: newRecord, collisionSource: collisionSource())
      return // early exit
    }
    
    if let currentValues {
      // TODO: perfomace Test: _storage.containsValues(forKey:, where:) might be faster than allValuesSlice(forKey:).contains
      if currentValues.contains(where: comparator) {
        return
      } else {
        _storage.append(key: key, value: newRecord, collisionSource: collisionSource())
      }
    } else {
      _storage.append(key: key, value: newRecord, collisionSource: collisionSource())
    }
  }
}

// Improvement: ErrorInfoGeneric @_specialize(where Self == ...)
