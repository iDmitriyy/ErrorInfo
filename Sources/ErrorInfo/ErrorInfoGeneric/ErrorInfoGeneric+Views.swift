//
//  ErrorInfoGeneric+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension ErrorInfoGeneric {
  public var keys: some Collection<Key> & _UniqueCollection { _storage.keys }

  public var allKeys: some Collection<Key> { _storage.allKeys }
}
