//
//  ErrorInfo+DictionaryLiteral.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

// MARK: - Expressible By Dictionary Literal

extension ErrorInfo: ExpressibleByDictionaryLiteral {
  public typealias Key = StringLiteralKey
  public typealias Value = ValueExistential? // allows to initialize by dictionary literal with optional values
    
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
    _appendKeyValuesImp(_dictionaryLiteral: elements, collisionSource: .onCreateWithDictionaryLiteral)
  }
}
