//
//  ErrorInfoGeneric.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

public struct ErrorInfoGeneric<Key: Hashable, GValue: Equatable>: Sequence {
  public typealias Element = (key: Key, value: TaggedValue)
  public typealias TaggedValue = CollisionTaggedValue<Record, CollisionSource>
  
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
    let keyOrigin: KeyOrigin
    let someValue: GValue
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append KeyValue with all arguments passed explicitly

extension ErrorInfoGeneric where GValue: ErrorInfoOptionalProtocol {
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

    __addImp(key: key,
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
    __addImp(key: key,
             record: Record(keyOrigin: keyOrigin, someValue: someValue),
             insertIfEqual: duplicatePolicy.insertIfEqual,
             collisionSource: collisionSource())
  }
}

extension ErrorInfoGeneric {
  internal mutating func __addImp(key: Key,
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

/*
 Configurable
 - Value Type: any ErrorInfo | Any | ...
 - Optionality: yes custom | yes regular | non-optional
 - Key Type (typically String) | may be ASCIIString, StaticString
 
 Builtin / non configurable:
 - collisionSource
 - keyOrigin
 - StringLiteralKey
 
 subscript(_:)
 
 hasValue(forKey:)                        <> hasNonNilValue(forKey:)
 hasMultipleRecords(forKey:)
 keyValueLookupResult(forKey:)            <> keyOptionalValueLookupResult(forKey:) | keyNonOptionalValueLookupResult(forKey:)
 hasMultipleRecordsForAtLeastOneKey()
 
 firstValue(forKey:)                      <> firstNonNilValue(forKey:)
 
 allValues(forKey:)                       <> allNonNilValues(forKey:)
 removeAllRecords(forKey:)
 replaceAllRecords(forKey:, by:)          <> replaceAllRecords(forKey:, byNonNilValue:)
 
 append(key:, value:)                     <> append(key:, nonNilValue:) append(key:, optionalValue:)
 append(key:, value:)                     <> append(key:, nonNilValue:) append(key:, optionalValue:)
 
 init(dictionaryLiteral:)
 appendKeyValues(_ literal:)
 
 merge(with: ...)   appendResolvingCollisions(key:, value: valueWrapper.record)
 
 Element(key: Key, record: )
 
 // Non-optional storage
 hasEntry(forKey:)

 // Optional storage
 hasSomeEntry(forKey:)
 hasNonNilEntry(forKey:)
 hasNilEntry(forKey:)
 */
