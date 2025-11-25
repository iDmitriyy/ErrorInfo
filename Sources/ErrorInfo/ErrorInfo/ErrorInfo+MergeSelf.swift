//
//  ErrorInfo+MergeSelf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

extension ErrorInfo {
  // Here keeping equal values has 2 variants:
  // 1. keep duplicates for inside of each info, but deny duplucates between them
  // 2. remove duplicates from everywhere, finally on value is kept
  // 3. keep duplicates, if any
  
  // 3d variant seems the most reasonable.
  // If there are 2 equal values in an ErrorInfo, someone explicitly added it. If so, these 2 instances should not be
  // deduplicated by default making a merge.
  // If there 2 equal values across several ErrorInfo & there is no collision of values inside errorinfo, then
  // the should be deduplicated.
  
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
