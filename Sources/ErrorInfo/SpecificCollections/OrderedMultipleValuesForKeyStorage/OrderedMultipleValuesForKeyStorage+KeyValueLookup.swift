//
//  OrderedMultipleValuesForKeyStorage+KeyValueLookup.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 14/12/2025.
//

extension OrderedMultipleValuesForKeyStorage {
  internal func hasValue(forKey key: Key) -> Bool {
    switch _variant {
    case .left(let singleValueForKeyDict): singleValueForKeyDict.hasValue(forKey: key)
    case .right(let multiValueForKeyDict): multiValueForKeyDict.hasValue(forKey: key)
    }
  }
  
  internal func hasMultipleValues(forKey key: Key) -> Bool {
    switch _variant {
    case .left: false
    case .right(let multiValueForKeyDict): multiValueForKeyDict.hasMultipleValues(forKey: key)
    }
  }
  
  internal var hasMultipleValuesForAtLeastOneKey: Bool {
    switch _variant {
    case .left: false
    case .right(let multiValueForKeyDict): multiValueForKeyDict.hasMultipleValuesForAtLeastOneKey
    }
  }
}
