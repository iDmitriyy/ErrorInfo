//
//  ErrorInfo+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

// MARK: - Keys

extension ErrorInfo {
  /// Returns a collection of unique keys from the ErrorInfo instance.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo: ErrorInfo = ["a": 0, "b": 1, "c": 3, "b": 2]
  ///
  /// let keys = errorInfo.keys // ["a", "b", "c"]
  /// ```
  public var keys: some Collection<String> & _UniqueCollection { _storage.keys }
  
  /// Returns a collection of all keys in the ErrorInfo instance. Unlike `keys`, this does not enforce uniqueness, so it may contain duplicate entries.
  ///
  /// # Example:
  /// ```swift
  /// let errorInfo: ErrorInfo = ["a": 0, "b": 1, "c": 3, "b": 2]
  ///
  /// let allKeys = errorInfo.allKeys // ["a", "b", "c", "b"]
  /// ```
  public var allKeys: some Collection<String> { _storage._storage.allKeys }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Full Info View

extension ErrorInfo {
  public typealias FullInfoRecord = (keyOrigin: KeyOrigin, value: OptionalWithTypedNil, collisionSource: CollisionSource?)
  public typealias FullInfoElement = (key: String, record: FullInfoRecord)
  
  /// Returns a sequence of tuples, where each element consists of a key with its origin and a collision-tagged value.
  /// This view provides an enriched sequence of key-value pairs with additional metadata, useful for deep inspection, logging or debugging.
  public var fullInfoView: some Sequence<FullInfoElement> {
    _storage.lazy.map { key, taggedRecord -> FullInfoElement in
      let record = (taggedRecord.value.keyOrigin, taggedRecord.value._optional, taggedRecord.collisionSource)
      return (key, record)
    }
  }
  
  public func fullInfo(forKey literalKey: StringLiteralKey) -> ValuesForKey<FullInfoRecord>? {
    fullInfo(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func fullInfo(forKey dynamicKey: String) -> ValuesForKey<FullInfoRecord>? {
    guard let taggedRecords = _storage.allValues(forKey: dynamicKey) else { return nil }

    return taggedRecords.map { taggedRecord -> FullInfoRecord in
      (taggedRecord.value.keyOrigin, taggedRecord.value._optional, taggedRecord.collisionSource)
    }
  }
}
