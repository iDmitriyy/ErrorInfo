//
//  OrderedMultiValueErrorInfoGeneric+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/11/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension OrderedMultiValueErrorInfoGeneric {
  public var keys: some Collection<Key> & _UniqueCollection {
    _storage.keys
  }
}
