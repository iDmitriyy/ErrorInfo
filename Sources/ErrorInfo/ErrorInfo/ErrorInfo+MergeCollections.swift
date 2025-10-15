//
//  ErrorInfo+MergeCollections.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 08/10/2025.
//

extension ErrorInfo {
  // TODO: - merge method with consuming generics instead of variadic ...
  
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
