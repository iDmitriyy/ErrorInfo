//
//  ErrorInfoGeneric+RemoveAll.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

extension ErrorInfoGeneric {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool) {
    _mutableVariant.mutateUnderlying(singleValueForKey: { singleValueForKeyDict in
      singleValueForKeyDict.removeAll(keepingCapacity: keepCapacity)
    }, multiValueForKey: { multiValueForKeyDict in
      multiValueForKeyDict.removeAll(keepingCapacity: keepCapacity)
    })
  }
}
