//
//  ErrorInfoGeneric.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

/// ### Configurable
/// - Value Type: any ErrorInfo | Any | ...
/// - Optionality: yes custom | yes regular | non-optional
/// - Key Type (typically String) | may be ASCIIString, StaticString
///
/// ### Builtin / non configurable:
/// - collisionSource
/// - keyOrigin
/// - StringLiteralKey
public struct ErrorInfoGeneric<Key: Hashable, GValue: Equatable>: Sequence {
  public typealias Element = (key: Key, value: AnnotatedRecord)
  public typealias AnnotatedRecord = CollisionTaggedValue<Record, CollisionSource>
  
  @usableFromInline internal typealias BackingStorage = OrderedMultipleValuesForKeyStorage<Key, Record, CollisionSource>
  
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
  public struct Record {
    public let keyOrigin: KeyOrigin
    public let someValue: GValue
  }
}

extension ErrorInfoGeneric: Sendable where Key: Sendable, GValue: Sendable {}

extension ErrorInfoGeneric.Record: Sendable where GValue: Sendable {}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append KeyValue with all arguments passed explicitly

extension ErrorInfoGeneric where GValue: ErrorInfoOptionalRepresentable {
  /// The root appending function for public API imps. The term "_add" is chosen to visually / syntatically differentiate from family of public `append()`functions.
  internal mutating func _add(key: Key,
                              keyOrigin: KeyOrigin,
                              optionalValue newValue: GValue.Wrapped?,
                              typeOfWrapped: GValue.TypeOfWrapped,
                              preserveNilValues: Bool,
                              duplicatePolicy: ValueDuplicatePolicy,
                              collisionSource: @autoclosure () -> CollisionSource) {
    let optional: GValue
    if let newValue {
      optional = .value(newValue)
    } else if preserveNilValues {
      optional = .nilInstance(typeOfWrapped: typeOfWrapped)
    } else {
      return
    }

    __withCollisionresolvingAdd(key: key,
                                record: Record(keyOrigin: keyOrigin, someValue: optional),
                                insertIfEqual: duplicatePolicy.insertIfEqual,
                                collisionSource: collisionSource())
  }
}

extension ErrorInfoGeneric {
  internal mutating func _add(key: Key,
                              keyOrigin: KeyOrigin,
                              someValue: GValue,
                              duplicatePolicy: ValueDuplicatePolicy,
                              collisionSource: @autoclosure () -> CollisionSource) {
    __withCollisionresolvingAdd(key: key,
                                record: Record(keyOrigin: keyOrigin, someValue: someValue),
                                insertIfEqual: duplicatePolicy.insertIfEqual,
                                collisionSource: collisionSource())
  }
}

extension ErrorInfoGeneric {
  internal mutating func __withCollisionresolvingAdd(key: Key,
                                                     record newRecord: Record,
                                                     insertIfEqual: Bool,
                                                     collisionSource: @autoclosure () -> CollisionSource) {
    if insertIfEqual {
      _storage.append(key: key, value: newRecord, collisionSource: collisionSource())
    } else {
      if let currentValues = _storage.allValuesSlice(forKey: key) {
        // TODO: perfomace Test: _storage.containsValues(forKey:, where:) might be faster than allValuesSlice(forKey:).contains
        let isEqualToOneOfCurrent = currentValues.contains(where: { currentTaggedRecord in
          newRecord.someValue == currentTaggedRecord.value.someValue
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
