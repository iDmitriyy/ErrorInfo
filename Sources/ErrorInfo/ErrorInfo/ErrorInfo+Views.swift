//
//  ErrorInfo+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

// MARK: - Keys

extension ErrorInfo {
  public var keys: some Collection<String> & _UniqueCollection { _storage.keys }
  
  public var allKeys: some Collection<String> { _storage.allKeys }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Full Info View

extension ErrorInfo {
  public typealias FullInfoRecord = (value: OptionalAnyValue, keyOrigin: KeyOrigin, collisionSource: CollisionSource?)
  public typealias FullInfoElement = (key: String, record: FullInfoRecord)
  
  /// Returns a sequence of tuples, where each element consists of a key with its origin and a collision-tagged value.
  /// This view provides an enriched sequence of key-value pairs with additional metadata, useful for deep inspection, logging or debugging.
  public var fullInfoView: some Sequence<FullInfoElement> {
    _storage.lazy.map { key, taggedRecord -> FullInfoElement in
      let record = (taggedRecord.record.someValue.maybeValue, taggedRecord.record.keyOrigin, taggedRecord.collisionSource)
      return (key, record)
    }
  }
  
  @inlinable
  @_transparent
  public func fullInfo(forKey literalKey: StringLiteralKey) -> ValuesForKey<FullInfoRecord>? {
    fullInfo(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func fullInfo(forKey dynamicKey: String) -> ValuesForKey<FullInfoRecord>? {
    guard let annotatedRecords = _storage.allAnnotatedRecords(forKey: dynamicKey) else { return nil }

    return annotatedRecords.map { annotatedRecord -> FullInfoRecord in
      (annotatedRecord.record.someValue.maybeValue, annotatedRecord.record.keyOrigin, annotatedRecord.collisionSource)
    }
  }
}
