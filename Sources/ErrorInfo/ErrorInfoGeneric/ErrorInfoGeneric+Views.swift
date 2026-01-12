//
//  ErrorInfoGeneric+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension ErrorInfoGeneric {
  @inlinable
  @inline(__always) // 1.14x speedup when keys inlined from on all levels from most deep storage
  public var keys: some Collection<Key> & _UniqueCollection {
    switch _variant {
    case .left(let singleValueForKeyDict): AnyCollection(singleValueForKeyDict.keys)
    case .right(let multiValueForKeyDict): AnyCollection(multiValueForKeyDict.keys)
    }
  }

  @inlinable
  @inline(__always) // 1.14x speedup when allKeys inlined from on all levels from most deep storage
  public var allKeys: some Collection<Key> {
    switch _variant {
    case .left(let singleValueForKeyDict): AnyCollection(singleValueForKeyDict.keys)
    case .right(let multiValueForKeyDict): AnyCollection(multiValueForKeyDict.allKeys)
    }
  }
}
