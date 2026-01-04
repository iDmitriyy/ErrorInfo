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
  public typealias Record = (value: OptionalValue, keyOrigin: KeyOrigin, collisionSource: WriteProvenance?)
  public typealias RecordElement = (key: String, record: Record)
  
  // MARK: FullInfo All
  
  /// Returns a sequence of tuples, where each element consists of a key with its origin and a collision-tagged value.
  /// This view provides an enriched sequence of key-value pairs with additional metadata, useful for deep inspection, logging or debugging.
  public var records: some Sequence<RecordElement> {
    _storage.lazy.map { key, annotatedRecord -> RecordElement in
      let record = annotatedRecord.record
      return (key, (record.someValue.instanceOfOptional, record.keyOrigin, annotatedRecord.collisionSource))
    }
  }
  
  // MARK: FullInfo for Key
  
  public func allRecords(forKey literalKey: StringLiteralKey) -> ItemsForKey<Record>? {
    allRecords(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func allRecords(forKey dynamicKey: String) -> ItemsForKey<Record>? {
    guard let annotatedRecords = _storage.allAnnotatedRecords(forKey: dynamicKey) else { return nil }

    return annotatedRecords.map { annotatedRecord -> Record in
      (annotatedRecord.record.someValue.instanceOfOptional, annotatedRecord.record.keyOrigin, annotatedRecord.collisionSource)
    }
  }
}
