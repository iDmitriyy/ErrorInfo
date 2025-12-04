//
//  OrderedMultiValueDictionary+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/11/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension OrderedMultiValueDictionary {
  internal var uniqueKeys: some Collection<Key> & _UniqueCollection { _keyToEntryIndices.keys }
}

