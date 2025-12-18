//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

public struct ErrorInfo: Sendable, ErrorInfoOperationsProtocol {  
  public typealias Element = (key: String, value: ValueExistential)
  
  public typealias KeyType = String
  public typealias ValueExistential = any ValueProtocol
  
  /// This approach addresses several important concerns:
  /// - Thread Safety: The Sendable requirement is essential to prevent data races and ensure safe concurrent access.
  /// - String Representation: Requiring CustomStringConvertible forces developers to provide meaningful string representations for stored values, which is invaluable for debugging and logging. It also prevents unexpected results when converting values to strings.
  /// - Collision Resolution: The Equatable requirement allows to detect and potentially resolve collisions if different values are associated with the same key. This adds a layer of robustness.
  public typealias ValueProtocol = Sendable & Equatable & CustomStringConvertible
  
  @usableFromInline internal typealias BackingStorage = ErrorInfoGeneric<KeyType, EquatableOptionalAnyValue>
  
  @usableFromInline internal var _storage: ErrorInfoGeneric<KeyType, EquatableOptionalAnyValue>
  
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

extension ErrorInfo {
  
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
      optional = .nilInstance(typeOfWrapped: ValueExistential.self)
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
