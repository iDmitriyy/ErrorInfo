//
//  OrderedMultipleValuesForKeyStorage+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/11/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection
import Collections

extension OrderedMultipleValuesForKeyStorage {
  @inlinable
  @inline(__always)
  public var keys: some Collection<Key> & _UniqueCollection {
    switch _variant {
    case .left(let singleValueForKeyDict): AnyCollection(singleValueForKeyDict.keys)
    case .right(let multiValueForKeyDict): AnyCollection(multiValueForKeyDict.keys)
    }
  }
  
  @inlinable
  @inline(__always)
  internal var allKeys: some Collection<Key> {
    switch _variant {
    case .left(let singleValueForKeyDict): AnyCollection(singleValueForKeyDict.keys)
    case .right(let multiValueForKeyDict): AnyCollection(multiValueForKeyDict.allKeys)
    }
  }
}
