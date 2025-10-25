//
//  ErrorInfo+MergeSelf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

extension ErrorInfo {
  // TODO: minimize CoW
  public mutating func merge(omitEqualValues: Bool = true,
                             with first: Self,
                             _ otherDonators: Self...) {
    // 1. reserve capacity
    // 2.
    
//    for (key, wrappedValue) in first {
//      self._add(key: key,
//                value: wrappedValue.value,
//                omitEqualValue: omitEqualValues,
//                addTypeInfo: , // !! not meaningful here
//                collisionSource: ) // wrappedValue.collisionSource & merge
//    }
  }
}

extension ErrorInfo {
//  public func unverifiedMapKeys(_ transform: (_ key: String) -> String) -> Self {
//
//  }
}

// extension ErrorInfo {
//  
//
//  public static func merge(_ otherInfos: Self..., to errorInfo: inout Self, line: UInt = #line) {
//    ErrorInfoFuncs._mergeErrorInfo(&errorInfo.storage, with: otherInfos.map { $0.storage }, line: line)
//  }
//
//  public static func merge(_ otherInfo: Self,
//                           to errorInfo: inout Self,
//                           addingKeyPrefix keyPrefix: String,
//                           uppercasingFirstLetter uppercasing: Bool = true,
//                           line: UInt = #line) {
//    ErrorInfoFuncs.mergeErrorInfo(otherInfo.storage,
//                                      to: &errorInfo.storage,
//                                      addingKeyPrefix: keyPrefix,
//                                      uppercasingFirstLetter: uppercasing,
//                                      line: line)
//  }
//
//  public static func merged(_ errorInfo: Self, _ otherInfos: Self..., line: UInt = #line) -> Self {
//    var errorInfoRaw = errorInfo.storage
//    ErrorInfoFuncs._mergeErrorInfo(&errorInfoRaw, with: otherInfos.map { $0.storage }, line: line)
//    return Self(storage: errorInfoRaw)
//  }
// }
