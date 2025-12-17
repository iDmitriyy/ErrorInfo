//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

public struct ErrorInfo: Sendable {
  public typealias Element = (key: String, value: ValueType)
  
  public typealias KeyType = String
  public typealias ValueType = any ValueProtocol
  public typealias ValueProtocol = Sendable & Equatable & CustomStringConvertible
  
  @usableFromInline internal typealias BackingStorage = ErrorInfoGeneric<KeyType, EquatableOptionalAnyValue>
  
  @usableFromInline internal var _storage: ErrorInfoGeneric<KeyType, EquatableOptionalAnyValue>
  
  // Improvement: BackingStorage @_specialize(where Self == ...)
  
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

enum ErrorInfoOptional: Sendable, ErrorInfoOptionalRepresentable {
  case value(any ErrorInfoValueType)
  case nilInstance(typeOfWrapped: any Sendable.Type)
  
  var isValue: Bool {
    switch self {
    case .value: true
    case .nilInstance: false
    }
  }
  
  var getWrapped: (any ErrorInfoValueType)? {
    switch self {
    case .value(let value): value
    case .nilInstance: nil
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append KeyValue with all arguments passed explicitly

extension ErrorInfo {
  /// The root appending function for public API imps. The term "_add" is chosen to visually / syntatically differentiate from family of public `append()`functions.
  @usableFromInline
  internal mutating func _add<V: ValueProtocol>(key: String,
                                                keyOrigin: KeyOrigin,
                                                value newValue: V?,
                                                preserveNilValues: Bool,
                                                duplicatePolicy: ValueDuplicatePolicy,
                                                collisionSource: @autoclosure () -> CollisionSource) {
    let optional: EquatableOptionalAnyValue
    if let newValue {
      optional = .value(newValue)
    } else if preserveNilValues {
      optional = .nilInstance(typeOfWrapped: V.self)
    } else {
      return
    }
    
    _storage.__withCollisionresolvingAdd(key: key,
                                         record: BackingStorage.Record(keyOrigin: keyOrigin, someValue: optional),
                                         insertIfEqual: duplicatePolicy.insertIfEqual,
                                         collisionSource: collisionSource())
  }
  
  // SE-0352 Implicitly Opened Existentials
  // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md
  
  // SE-0375 Opening existential arguments to optional parameters
  
  internal mutating func _addExistentialNil(key: String,
                                            keyOrigin: KeyOrigin,
                                            preserveNilValues: Bool,
                                            duplicatePolicy: ValueDuplicatePolicy,
                                            collisionSource: @autoclosure () -> CollisionSource) {
    let optional: EquatableOptionalAnyValue
    if preserveNilValues {
      optional = .nilInstance(typeOfWrapped: ValueType.self)
    } else {
      return
    }
    
    _storage.__withCollisionresolvingAdd(key: key,
                                         record: BackingStorage.Record(keyOrigin: keyOrigin, someValue: optional),
                                         insertIfEqual: duplicatePolicy.insertIfEqual,
                                         collisionSource: collisionSource())
  }
}

// TODO: - add tests for elements ordering stability
// TBD: - add overloads for Sendable AnyObjects & actors
