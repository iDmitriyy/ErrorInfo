//
//  ErrorInfo+DictionaryLiteral.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

// MARK: Expressible By Dictionary Literal

extension ErrorInfo: ExpressibleByDictionaryLiteral {
  public typealias Value = (any ErrorInfoValueType)?
  public typealias Key = StringLiteralKey
    
  /// Allows initializing an `ErrorInfo` instance directly from a dictionary literal.
  /// Collisions during the merge are tracked with the `CollisionSource.onCreateWithDictionaryLiteral` source.
  ///
  /// - Parameter elements: The key-value pairs to initialize the `ErrorInfo` with.
  ///
  /// - Note:
  ///   - If the value is `nil`, it is explicitly stored as a `nil` value.
  ///   - Duplicate values for the same key are appended, as the method allows duplicates by default.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo: ErrorInfo = [
  ///   .errorCode: 404,
  ///   .errorMessage: "Not Found",
  ///   .errorCode: 404,
  /// ]
  /// // contains key-value ("error_code": 404) twice
  /// ```
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(minimumCapacity: elements.count)
    _mergeKeyValues(_dictionaryLiteral: elements, collisionSource: .onCreateWithDictionaryLiteral)
  }
}

extension ErrorInfo {
  /// Allows merging key-value Dictionary literal into the existing `ErrorInfo` instance.
  /// Collisions during the merge are tracked with the `CollisionSource.onDictionaryConsumption` source.
  ///
  /// - Parameters:
  ///   - literal: The key-value pairs to merge into the errorInfo.
  ///   - origin: The source of the collision (default is `.fileLine()`).
  ///
  /// - Note:
  ///   - If `nil` values are provided, they are explicitly stored.
  ///   - Duplicate values for the same key are appended, as the method allows duplicates by default.
  ///
  /// # Example:
  /// ```swift
  /// errorInfo.appendKeyValues([
  ///   .id: 0,
  ///   .count: 2,
  /// ])
  /// ```
  public mutating func appendKeyValues(_ literal: KeyValuePairs<Key, Value>,
                                       collisionSource origin: @autoclosure () -> CollisionSource.Origin = .fileLine()) {
    _mergeKeyValues(_dictionaryLiteral: literal, collisionSource: .onDictionaryConsumption(origin: origin()))
  }
}

extension ErrorInfo {
  internal mutating func _mergeKeyValues(_dictionaryLiteral elements: some Collection<(key: Key, value: Value)>,
                                         collisionSource: @autoclosure () -> CollisionSource) {
    // Improvement: try reserve capacity. perfomance tests
    for (literalKey, value) in elements {
      if let value {
        // TODO: _add() with optional value is used
        _add(key: literalKey.rawValue,
             keyOrigin: literalKey.keyOrigin,
             value: value,
             preserveNilValues: true,
             duplicatePolicy: .allowEqual,
             collisionSource: collisionSource())
      } else {
        _addExistentialNil(key: literalKey.rawValue,
                           keyOrigin: literalKey.keyOrigin,
                           preserveNilValues: true,
                           duplicatePolicy: .allowEqual,
                           collisionSource: collisionSource())
      }
    }
  }
}
