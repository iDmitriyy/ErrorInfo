//
//  ErrorInfoGeneric+FirstLastForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

extension ErrorInfoGeneric {
  func lastInstance(forKey key: Key) -> GValue? {
    guard let allRecordsForKey = _storage.allValues(forKey: key) else { return nil }
    return allRecordsForKey.last.record.maybeValue
  }
}

extension ErrorInfoGeneric where GValue: ErrorInfoOptionalProtocol {
  func lastNonNilValue(forKey key: Key) -> GValue.Value? {
    guard let allRecordsForKey = _storage.allValues(forKey: key) else { return nil }
    
    let reversedRecords: ReversedCollection<_> = allRecordsForKey.reversed()
    for record in reversedRecords {
      if let value = record.record.maybeValue.getValue {
        return value
      }
    }
    return nil
  }
}

extension ErrorInfoGeneric {
//  public func firstValue(forKey literalKey: StringLiteralKey) -> (any ValueType)? {
//    firstValue(forKey: literalKey.rawValue)
//  }
//
//  @_disfavoredOverload
//  public func firstValue(forKey dynamicKey: String) -> (any ValueType)? {
//    guard let allRecordsForKey = _storage.allValues(forKey: dynamicKey) else { return nil }
//
//    for record in allRecordsForKey {
//      if let value = record.value._optional.maybeValue.asOptional {
//        return value
//      }
//    }
//    return nil
//  }
}
