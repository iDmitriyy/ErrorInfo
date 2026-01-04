//
//  ErrorInfo+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

// MARK: - Keys

extension ErrorInfo {
  @inlinable
  @inline(__always)
  public var keys: some Collection<String> & _UniqueCollection { _storage.keys }
  
  @inlinable
  @inline(__always)
  public var allKeys: some Collection<String> { _storage.allKeys }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Full Info View

extension ErrorInfo {
  public typealias FullInfoRecord = (value: OptionalValue, keyOrigin: KeyOrigin, collisionSource: WriteProvenance?)
  public typealias FullInfoElement = (key: String, record: FullInfoRecord)
  
  // MARK: FullInfo All
  
  /// Returns a sequence of tuples, where each element consists of a key with its origin and a collision-tagged value.
  /// This view provides an enriched sequence of key-value pairs with additional metadata, useful for deep inspection, logging or debugging.
  public var fullInfoView: some Sequence<FullInfoElement> {
    _storage.lazy.map { key, annotatedRecord -> FullInfoElement in
      let record = annotatedRecord.record
      return (key, (record.someValue.instanceOfOptional, record.keyOrigin, annotatedRecord.collisionSource))
    }
  }
  
  // MARK: FullInfo for Key
  
  public func fullInfo(forKey literalKey: StringLiteralKey) -> ValuesForKey<FullInfoRecord>? {
    allRecords(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func allRecords(forKey dynamicKey: String) -> ValuesForKey<FullInfoRecord>? {
    guard let annotatedRecords = _storage.allAnnotatedRecords(forKey: dynamicKey) else { return nil }

    return annotatedRecords.map { annotatedRecord -> FullInfoRecord in
      (annotatedRecord.record.someValue.instanceOfOptional, annotatedRecord.record.keyOrigin, annotatedRecord.collisionSource)
    }
  }
}
