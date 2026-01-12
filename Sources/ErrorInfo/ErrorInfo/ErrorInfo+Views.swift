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

// MARK: - Records View

extension ErrorInfo {
  // MARK: All Records
  
  public var records: some Sequence<RecordElement> {
    _storage.lazy.map { key, annotatedRecord -> RecordElement in
      let record = annotatedRecord.record
      return (key, (record.someValue.instanceOfOptional, record.keyOrigin, annotatedRecord.collisionSource))
    }
  }
  
  // MARK: AllRecords for Key
  
  public func allRecords(forKey key: String) -> ItemsForKey<Record>? {
    _storage.allAnnotatedRecords(forKey: key, transform: { annotatedRecord -> Record in
      (annotatedRecord.record.someValue.instanceOfOptional, annotatedRecord.record.keyOrigin, annotatedRecord.collisionSource)
    })
  }
}
