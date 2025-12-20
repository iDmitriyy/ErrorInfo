//
//  OrderedMultiValueDictionary+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/11/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension OrderedMultiValueDictionary {
  @inlinable
  @inline(__always)
  internal var keys: some Collection<Key> & _UniqueCollection {
    _keyToEntryIndices.keys
  }
  
  @inlinable
  @inline(__always)
  internal var allKeys: some Collection<Key> {
    _entries.lazy.map({ entry in entry.key })
  }
}
