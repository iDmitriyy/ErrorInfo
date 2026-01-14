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
  /// Collisions during the merge are tracked with the `WriteProvenance.onCreateWithDictionaryLiteral` source.
  ///
  /// - Parameter elements: The key-value pairs to initialize the `ErrorInfo` with.
  ///
  /// - Note:
  ///   - If the value is `nil`, it is explicitly stored as a `nil` instance with `Wrapped` type.
  ///   - Duplicate values for the same key are appended, as the method allows duplicates by default.
  ///
  /// # Example:
  /// ```
  /// let info: ErrorInfo = [
  ///   .taskID: "com.example.app.backgroundSync",
  ///   .taskStatus: "Failure",
  ///   .durationInSeconds: 1800,
  /// ]
  /// ```
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo: ErrorInfo = [
  ///   .fileName: "userSettings.json",
  ///   .operation: "Save",
  ///   .status: "Failure",
  ///   .operation: "Save", // duplicate skipped
  /// ]
  /// ```
  public init(dictionaryLiteral elements: (Key, Value)...) {
    if elements.isEmpty {
      self.init(storage: BackingStorage.empty) // create empty instance without preallocated capacity
    } else {
      self.init(storage: BackingStorage(minimumCapacity: elements.count))

      for (literalKey, value) in elements {
        if let value {
          withCollisionAndDuplicateResolutionAdd_inlined(
            value: value,
            duplicatePolicy: .allowEqual,
            forKey: literalKey.rawValue,
            keyOrigin: literalKey.keyOrigin,
            writeProvenance: .onCreateWithDictionaryLiteral,
          )
        } else {
          withCollisionAndDuplicateResolutionAddNilInstance(
            typeOfWrapped: ValueExistential.self,
            duplicatePolicy: .allowEqual,
            forKey: literalKey.rawValue,
            keyOrigin: literalKey.keyOrigin,
            writeProvenance: .onCreateWithDictionaryLiteral,
          )
        }
      }
    }
    
    // Call to function below is significantly slower no matter of using inlining
    // _appendKeyValuesImp(_dictionaryLiteral: elements,
    //                     preserveNilValues: true,
    //                     duplicatePolicy: .allowEqual,
    //                     writeProvenance: .onCreateWithDictionaryLiteral)
  } // inlining worsen performance
}
