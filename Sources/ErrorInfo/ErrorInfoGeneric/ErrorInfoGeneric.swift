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
  public struct Record: CustomDebugStringConvertible {
    public let keyOrigin: KeyOrigin
    public let someValue: RecordValue
    
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
                                insertIfEqual: duplicatePolicy.insertIfEqual,
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
                                insertIfEqual: duplicatePolicy.insertIfEqual,
                                collisionSource: collisionSource())
  }
}

extension ErrorInfoGeneric where RecordValue: Equatable {
  /// Core insertion routine that enforces duplicate policy and tags collisions.
  /// - Availability: Only when `RecordValue` conforms to `Equatable`.
  ///
  /// - If `insertIfEqual` is `false`, the new record is compared against existing values for the key using `RecordValue`'s `Equatable`.
  ///   The insertion is skipped when an equal value already exists.
  /// - Otherwise the record is always appended.
  internal mutating func _addWithCollisionResolution(record newRecord: Record,
                                                     forKey key: Key,
                                                     insertIfEqual: Bool,
                                                     collisionSource: @autoclosure () -> CollisionSource) {
    if insertIfEqual {
      _storage.append(key: key, value: newRecord, collisionSource: collisionSource())
    } else {
      if let currentValues = _storage.allValues(forKey: key) {
        // TODO: perfomace Test: _storage.containsValues(forKey:, where:) might be faster than allValuesSlice(forKey:).contains
        let isEqualToOneOfCurrent = currentValues.contains(where: { currentAnnotatedRecord in
          newRecord.someValue == currentAnnotatedRecord.record.someValue
        })
        
        if isEqualToOneOfCurrent {
          return
        } else {
          _storage.append(key: key, value: newRecord, collisionSource: collisionSource())
        }
      } else {
        _storage.append(key: key, value: newRecord, collisionSource: collisionSource())
      }
    }
  }
}

// Improvement: ErrorInfoGeneric @_specialize(where Self == ...)
