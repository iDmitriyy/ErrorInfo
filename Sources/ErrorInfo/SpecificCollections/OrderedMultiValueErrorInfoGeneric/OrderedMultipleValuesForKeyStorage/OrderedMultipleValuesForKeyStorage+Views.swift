//
//  OrderedMultipleValuesForKeyStorage+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/11/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection
import Collections

extension OrderedMultipleValuesForKeyStorage {
  public var keys: some Collection<Key> & _UniqueCollection {
    // TODO: OrderedSet initialization can be eliminated
    // make AnyUniqueCollection
    switch _variant {
    case .left(let singleValueForKeyDict): OrderedSet(singleValueForKeyDict.keys)
    case .right(let multiValueForKeyDict): OrderedSet(multiValueForKeyDict.keys)
    }
  }
  
  // public var allKeys: some Collection | naming: allKeys, keys
}
