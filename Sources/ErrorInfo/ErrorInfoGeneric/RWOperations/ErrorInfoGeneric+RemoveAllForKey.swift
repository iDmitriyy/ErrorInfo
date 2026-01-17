//
//  ErrorInfoGeneric+RemoveAllForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 15/01/2026.
//

// MARK: - Remove All Records For Key

// FIXME: - @discardableResult remove operations – check performance
// may it is better to make 2 overloads – pure remove and remove with result

extension ErrorInfoGeneric where RecordValue: ErrorInfoOptionalRepresentableEquatable {
  @discardableResult
  public mutating func removeAllRecordsReturningOptionalInstances(forKey key: Key)
    -> ItemsForKey<RecordValue.OptionalInstanceType>? {
    _mutableVariant.withResultMutateUnderlying(singleValueForKey: { singleValueForKeyDict in
      if let oldValue = singleValueForKeyDict.removeValue(forKey: key) {
        ItemsForKey(element: oldValue.someValue.instanceOfOptional)
      } else {
        nil
      }
    }, multiValueForKey: { multiValueForKeyDict in
      multiValueForKeyDict.removeAllValues(forKey: key, transform: { $0.record.someValue.instanceOfOptional })
    })
  } // inlining worsen performance
  
  public mutating func removeAllRecords(forKey key: Key) {
    _mutableVariant.mutateUnderlying(singleValueForKey: { singleValueForKeyDict in
      singleValueForKeyDict.removeValue(forKey: key)
    }, multiValueForKey: { multiValueForKeyDict in
      multiValueForKeyDict.removeAllValues(forKey: key)
    })
  }
}
