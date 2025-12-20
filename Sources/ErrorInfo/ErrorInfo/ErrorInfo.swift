//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

public struct ErrorInfo: Sendable, ErrorInfoOperationsProtocol {
  @usableFromInline internal var _storage: ErrorInfoGeneric<KeyType, EquatableOptionalAnyValue>
  
  private init(storage: BackingStorage) {
    _storage = storage
  }
  
  public init() {
    self.init(storage: BackingStorage())
  }
  
  public init(minimumCapacity: Int) {
    self.init(storage: BackingStorage(minimumCapacity: minimumCapacity))
  }
  
  public static var empty: Self { Self() }
}

extension ErrorInfo {
  /// A single (key, value) pair element yielded during iteration.
  public typealias Element = (key: String, value: ValueExistential)
  
  /// The key type used by `ErrorInfo`.
  public typealias KeyType = String
  
  /// The existential used to store values that conform to ``ErrorInfo/ValueProtocol``.
  public typealias ValueExistential = any ValueProtocol
  
  /// `Sendable & Equatable & CustomStringConvertible`
  ///
  /// This approach addresses several important concerns:
  /// - **Thread Safety**: The Sendable requirement is essential to prevent data races and ensure safe concurrent access.
  /// - **String Representation**: Requiring CustomStringConvertible forces developers to provide values with meaningful string representations for stored values,
  ///   which is invaluable for debugging and logging. It also prevents unexpected results when converting values to strings.
  /// - **Collision Resolution**: The Equatable requirement allows to detect and potentially resolve collisions if different values are associated with the same key.
  ///   This adds a layer of robustness.
  public typealias ValueProtocol = Sendable & Equatable & CustomStringConvertible
  
  @usableFromInline internal typealias BackingStorage = ErrorInfoGeneric<KeyType, EquatableOptionalAnyValue>
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
    
    _storage._addWithCollisionResolution(record: BackingStorage.Record(keyOrigin: keyOrigin, someValue: optional),
                                         forKey: key,
                                         insertIfEqual: duplicatePolicy.insertIfEqual,
                                         collisionSource: collisionSource())
  }
  
  // SE-0352 Implicitly Opened Existentials
  // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md
  
  // SE-0375 Opening existential arguments to optional parameters
  
  /// Appends an explicit `nil` for a value of existential type.
  ///
  /// Use when the concrete value is not available but you need to record the presence of a `nil` entry
  /// (subject to `preserveNilValues`). The entry participates in collision tracking and ordering.
  ///
  /// - Parameters:
  ///   - key: The key to add.
  ///   - keyOrigin: The origin metadata for the key.
  ///   - preserveNilValues: When `true`, the `nil` is stored; otherwise the call is a no‑op.
  ///   - duplicatePolicy: How to handle duplicates for subsequent non‑nil inserts.
  ///   - collisionSource: The collision origin for diagnostics.
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
    
    _storage._addWithCollisionResolution(record: BackingStorage.Record(keyOrigin: keyOrigin, someValue: optional),
                                         forKey: key,
                                         insertIfEqual: duplicatePolicy.insertIfEqual,
                                         collisionSource: collisionSource())
  }
}

// TODO: - add tests for elements ordering stability
// TBD: - add overloads for Sendable AnyObjects & actors
