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

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append KeyValue with all arguments passed explicitly

extension ErrorInfoGeneric {
  /// The root appending function for public API imps. The term "_add" is chosen to visually / syntatically differentiate from family of public `append()`functions.
//  internal mutating func _add<V: ValueType>(key: String,
//                                            keyOrigin: KeyOrigin,
//                                            value newValue: V?,
//                                            preserveNilValues: Bool,
//                                            duplicatePolicy: ValueDuplicatePolicy,
//                                            collisionSource: @autoclosure () -> CollisionSource) {
//    let optional: _Optional
//    if let newValue {
//      optional = .value(newValue)
//    } else if preserveNilValues {
//      optional = .nilInstance(typeOfWrapped: V.self)
//    } else {
//      return
//    }
//
//    _storage.appendResolvingCollisions(key: key,
//                                       value: _Record(_optional: optional, keyOrigin: keyOrigin),
//                                       insertIfEqual: duplicatePolicy.insertIfEqual,
//                                       collisionSource: collisionSource())
//  }
  
  // SE-0352 Implicitly Opened Existentials
  // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md
  
  // SE-0375 Opening existential arguments to optional parameters
  
//  internal mutating func _addExistentialNil(key: String,
//                                            keyOrigin: KeyOrigin,
//                                            preserveNilValues: Bool,
//                                            duplicatePolicy: ValueDuplicatePolicy,
//                                            collisionSource: @autoclosure () -> CollisionSource) {
//    let optional: _Optional
//    if preserveNilValues {
//      optional = .nilInstance(typeOfWrapped: (any ErrorInfoValueType).self)
//    } else {
//      return
//    }
//
//    _storage.appendResolvingCollisions(key: key,
//                                       value: _Record(_optional: optional, keyOrigin: keyOrigin),
//                                       insertIfEqual: duplicatePolicy.insertIfEqual,
//                                       collisionSource: collisionSource())
//  }
}

extension ErrorInfoGeneric {
  public struct Record {
    let keyOrigin: KeyOrigin
    let maybeValue: GValue
  }
  
  internal mutating func appendResolvingCollisions(key: Key,
                                                   record newRecord: Record,
                                                   insertIfEqual: Bool,
                                                   collisionSource: @autoclosure () -> CollisionSource) {
    if insertIfEqual {
      _storage.append(key: key, value: newRecord, collisionSource: collisionSource())
    } else {
      if let currentValues = _storage.allValuesSlice(forKey: key) {
        // TODO: perfomace Test: _storage.containsValues(forKey:, where:) might be faster than allValuesSlice(forKey:).contains
        let isEqualToOneOfCurrent = currentValues.contains(where: { currentTaggedRecord in
          newRecord.maybeValue == currentTaggedRecord.value.maybeValue
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

//public enum MaybeValue<Value, TypeContainer> {
//  case value(Value)
//  case nilInstance // (typeOfWrapped: M)
//  
//  public var asOptional: Value? {
//    switch self {
//    case .value(let value): value
//    case .nilInstance: nil
//    }
//  } // inlining has no effect on perfomance
//  
//  public var isValue: Bool {
//    switch self {
//    case .value: true
//    case .nilInstance: false
//    }
//  } // inlining has no effect on perfomance
//  
//  public var isNil: Bool {
//    switch self {
//    case .value: false
//    case .nilInstance: true
//    }
//  } // inlining has no effect on perfomance
//  
//  public static func == (lhs: Self, rhs: Self) -> Bool {
//    switch (lhs, rhs) {
//    case (.value, .nilInstance),
//         (.nilInstance, .value):
//      false
//      
//    case let (.value(lhsInstance), .value(rhsInstance)):
//      ErrorInfoFuncs.isEqualEqatableExistential(a: lhsInstance, b: rhsInstance)
//      
//    case let (.nilInstance(lhsType), .nilInstance(rhsType)):
//      lhsType == rhsType
//    }
//  } // inlining has 5% perfomance gain. Will not be called often in practice
//}

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

enum ErrorInfoOptionalAny: ErrorInfoOptionalProtocol {
  case value(Any)
  case nilInstance(typeOfWrapped: any Any.Type)
  
  var isValue: Bool {
    switch self {
    case .value: true
    case .nilInstance: false
    }
  }
  
  var getValue: Any? {
    switch self {
    case .value(let value): value
    case .nilInstance: nil
    }
  }
}

enum ErrorInfoOptional: Sendable, ErrorInfoOptionalProtocol {
  case value(any ErrorInfoValueType)
  case nilInstance(typeOfWrapped: any Sendable.Type)
  
  var isValue: Bool {
    switch self {
    case .value: true
    case .nilInstance: false
    }
  }
  
  var getValue: (any ErrorInfoValueType)? {
    switch self {
    case .value(let value): value
    case .nilInstance: nil
    }
  }
}
