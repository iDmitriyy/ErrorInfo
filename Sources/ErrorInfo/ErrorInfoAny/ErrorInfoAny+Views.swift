//
//  ErrorInfoAny+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 17/12/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension ErrorInfoAny {
  public var keys: some _UniqueCollection & Collection<String> { _storage.keys }
  
  public var allKeys: some Collection<String> { _storage.allKeys }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Full Info View

extension ErrorInfoAny {
  public typealias FullInfoRecord = (value: ErrorInfoOptionalAny, keyOrigin: KeyOrigin, collisionSource: WriteProvenance?)
  public typealias FullInfoElement = (key: String, record: FullInfoRecord)
  
  // MARK: FullInfo All
  
  public var fullInfoView: some Sequence<FullInfoElement> {
    _storage.lazy.map { key, annotatedRecord -> FullInfoElement in
      let record = annotatedRecord.record
      return (key, (record.someValue.instanceOfOptional, record.keyOrigin, annotatedRecord.collisionSource))
    }
  }
  
  // MARK: FullInfo for Key
  
  public func fullInfo(forKey literalKey: StringLiteralKey) -> ItemsForKey<FullInfoRecord>? {
    fullInfo(forKey: literalKey.rawValue)
  }
  
  @_disfavoredOverload
  public func fullInfo(forKey dynamicKey: String) -> ItemsForKey<FullInfoRecord>? {
    guard let annotatedRecords = _storage.allAnnotatedRecords(forKey: dynamicKey) else { return nil }

    return annotatedRecords.map { annotatedRecord -> FullInfoRecord in
      (annotatedRecord.record.someValue.instanceOfOptional, annotatedRecord.record.keyOrigin, annotatedRecord.collisionSource)
    }
  }
}
