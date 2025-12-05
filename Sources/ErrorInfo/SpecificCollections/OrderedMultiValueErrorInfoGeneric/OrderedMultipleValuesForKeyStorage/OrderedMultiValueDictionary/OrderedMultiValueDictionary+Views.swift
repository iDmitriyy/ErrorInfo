//
//  OrderedMultiValueDictionary+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/11/2025.
//

internal import protocol InternalCollectionsUtilities._UniqueCollection

extension OrderedMultiValueDictionary {
  internal var keys: some Collection<Key> & _UniqueCollection { _keyToEntryIndices.keys }
  
  internal var allKeys: some Collection<Key> {
    _keyToEntryIndices.map { $0.key } // Improvement: eliminate allocation
  }
}

