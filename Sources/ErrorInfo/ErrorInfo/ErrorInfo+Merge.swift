//
//  ErrorInfo+Merge.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

// MARK: Merge

extension ErrorInfo {
  public mutating func merge<each D>(_: repeat each D,
                                     collisionSource: @autoclosure () -> StringBasedCollisionSource.MergeOrigin = .fileLine())
    where repeat each D: ErrorInfoCollection {
      fatalError()
//    ErrorInfoDictFuncs.Merge._mergeErrorInfo
    }
  
  public consuming func merging<each D>(_ donators: repeat each D,
                                        collisionSource _: @autoclosure () -> StringBasedCollisionSource.MergeOrigin = .fileLine())
    -> Self where repeat each D: ErrorInfoCollection {
      merge(repeat each donators)
      return self
    }
}

// extension ErrorInfo {
//  // TODO: - merge method with consuming generics instead of variadic ...
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
